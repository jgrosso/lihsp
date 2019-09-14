{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Axel.Haskell.Stack where

import Axel.Prelude

import Axel.Eff.Console (putStrLn)
import qualified Axel.Eff.Console as Effs
import Axel.Eff.Error (Error(ProjectError), fatal)
import qualified Axel.Eff.FileSystem as FS
import qualified Axel.Eff.FileSystem as Effs
import Axel.Eff.Process
  ( ProcessRunner
  , StreamSpecification(CreateStreams, InheritStreams)
  , execProcess
  )
import qualified Axel.Eff.Process as Effs
import Axel.Haskell.Error (processErrors)
import Axel.Parse (Parser)
import Axel.Sourcemap (ModuleInfo)
import Axel.Utils.FilePath (takeFileName)

import Control.Lens (op)
import Control.Lens.Operators ((%~))
import Control.Monad (void)

import Data.Aeson.Lens (_Array, key)
import Data.Function ((&))
import Data.List (foldl')
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Data.Vector (cons)
import Data.Version (showVersion)
import qualified Data.Yaml as Yaml

import Paths_axel (version)

import qualified Polysemy as Sem
import qualified Polysemy.Error as Sem

import System.Exit (ExitCode(ExitFailure, ExitSuccess))

import qualified Text.Megaparsec as P
import qualified Text.Megaparsec.Char as P

type ProjectPath = FilePath

type StackageId = Text

type StackageResolver = Text

type Target = Text

type Version = Text

stackageResolverWithAxel :: StackageResolver
stackageResolverWithAxel = "nightly"

axelStackageVersion :: Version
axelStackageVersion = T.pack $ showVersion version

axelStackageId :: StackageId
axelStackageId = "axel"

getStackProjectTargets ::
     (Sem.Members '[ Effs.FileSystem, Effs.Process] effs)
  => ProjectPath
  -> Sem.Sem effs [Target]
getStackProjectTargets projectPath =
  FS.withCurrentDirectory projectPath $ do
    (_, _, stderr) <- execProcess @'CreateStreams "stack ide targets" ""
    pure $ T.lines stderr

addStackDependency ::
     (Sem.Member Effs.FileSystem effs)
  => StackageId
  -> ProjectPath
  -> Sem.Sem effs ()
addStackDependency dependencyId projectPath =
  FS.withCurrentDirectory projectPath $ do
    let packageConfigPath = FilePath "package.yaml"
    packageConfigContents <- FS.readFile packageConfigPath
    case Yaml.decodeEither' $ T.encodeUtf8 packageConfigContents of
      Right contents ->
        let newContents :: Yaml.Value =
              contents & key "dependencies" . _Array %~
              cons (Yaml.String dependencyId)
            encodedContents = T.decodeUtf8 $ Yaml.encode newContents
         in FS.writeFile packageConfigPath encodedContents
      Left _ -> fatal "addStackDependency" "0001"

buildStackProject ::
     (Sem.Members '[ Effs.Console, Sem.Error Error, Effs.FileSystem, Effs.Process] effs)
  => ModuleInfo
  -> ProjectPath
  -> Sem.Sem effs ()
buildStackProject moduleInfo projectPath = do
  putStrLn ("Building " <> op FilePath (takeFileName projectPath) <> "...")
  result <-
    FS.withCurrentDirectory projectPath $
    execProcess @'CreateStreams "stack build --ghc-options='-ddump-json'" ""
  case result of
    (ExitSuccess, _, _) -> pure ()
    (ExitFailure _, _, stderr) ->
      Sem.throw $
      ProjectError
        ("Project failed to build.\n\n" <> processErrors moduleInfo stderr)

createStackProject ::
     (Sem.Members '[ Effs.FileSystem, Effs.Process] effs)
  => Text
  -> Sem.Sem effs ()
createStackProject projectName = do
  void $
    execProcess
      @'CreateStreams
      ("stack new " <> projectName <> " new-template")
      ""
  setStackageResolver (FilePath projectName) stackageResolverWithAxel

runStackProject ::
     (Sem.Members '[ Effs.Console, Sem.Error Error, Effs.FileSystem, Effs.Process] effs)
  => ProjectPath
  -> Sem.Sem effs ()
runStackProject projectPath = do
  targets <- getStackProjectTargets projectPath
  case findExeTargets targets of
    [target] -> do
      putStrLn $ "Running " <> target <> "..."
      void $ execProcess @'InheritStreams ("stack exec " <> target)
    _ ->
      Sem.throw $ ProjectError "No executable target was unambiguously found!"
  where
    exeTarget :: Parser Text
    exeTarget =
      P.many (P.anySingleBut ':') *> P.string ":exe:" *>
      (T.pack <$> P.many (P.anySingleBut ':'))
    findExeTargets =
      foldl'
        (\acc target ->
           case P.parseMaybe exeTarget target of
             Just targetName -> targetName : acc
             Nothing -> acc)
        []

setStackageResolver ::
     (Sem.Members '[ Effs.FileSystem, Effs.Process] effs)
  => ProjectPath
  -> StackageResolver
  -> Sem.Sem effs ()
setStackageResolver projectPath resolver =
  void $ FS.withCurrentDirectory projectPath $
  execProcess @'CreateStreams ("stack config set resolver " <> resolver) ""

includeAxelArguments :: Text
includeAxelArguments =
  T.unwords
    ["--resolver", stackageResolverWithAxel, "--package", axelStackageId]

compileFile ::
     forall (streamSpec :: StreamSpecification) effs.
     (Sem.Member Effs.Process effs)
  => FilePath
  -> ProcessRunner streamSpec (Sem.Sem effs)
compileFile (FilePath filePath) =
  let cmd = T.unwords ["stack", "ghc", includeAxelArguments, "--", filePath]
   in execProcess @streamSpec @effs cmd

interpretFile ::
     forall (streamSpec :: StreamSpecification) effs.
     (Sem.Member Effs.Process effs)
  => FilePath
  -> ProcessRunner streamSpec (Sem.Sem effs)
interpretFile (FilePath filePath) =
  let cmd = T.unwords ["stack", "runghc", includeAxelArguments, "--", filePath]
   in execProcess @streamSpec @effs cmd
