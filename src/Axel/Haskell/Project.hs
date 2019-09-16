{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}

module Axel.Haskell.Project where

import Axel.Prelude

import qualified Axel.Eff.Console as Effs (Console)
import Axel.Eff.Error (Error)
import Axel.Eff.FileSystem
  ( copyFile
  , getCurrentDirectory
  , getDirectoryContentsRec
  , removeFile
  )
import qualified Axel.Eff.FileSystem as Effs (FileSystem)
import qualified Axel.Eff.Ghci as Effs (Ghci)
import qualified Axel.Eff.Ghci as Ghci
import qualified Axel.Eff.Log as Effs (Log)
import qualified Axel.Eff.Process as Effs (Process)
import Axel.Eff.Resource (getResourcePath, newProjectTemplate)
import qualified Axel.Eff.Resource as Effs (Resource)
import Axel.Haskell.File
  ( convertFileInPlace
  , formatFileInPlace
  , readModuleInfo
  , transpileFileInPlace
  )
import Axel.Haskell.Stack
  ( addStackDependency
  , axelStackageId
  , buildStackProject
  , createStackProject
  , runStackProject
  )
import Axel.Sourcemap (ModuleInfo)
import Axel.Utils.FilePath ((<.>), (</>))
import Axel.Utils.Monad (concatMapM)

import Control.Lens (op)
import Control.Monad (void)

import qualified Data.Text as T

import qualified Polysemy as Sem
import qualified Polysemy.Error as Sem
import qualified Polysemy.State as Sem

type ProjectPath = FilePath

newProject ::
     Sem.Members '[ Effs.FileSystem, Effs.Process, Effs.Resource] effs
  => Text
  -> Sem.Sem effs ()
newProject projectName = do
  createStackProject projectName
  let projectPath = FilePath projectName
  addStackDependency axelStackageId projectPath
  templatePath <- getResourcePath newProjectTemplate
  let copyAxel filePath = do
        copyFile
          (templatePath </> filePath <.> "axel")
          (projectPath </> filePath <.> "axel")
        removeFile (projectPath </> filePath <.> "hs")
  mapM_
    copyAxel
    [ FilePath "Setup"
    , FilePath "app" </> FilePath "Main"
    , FilePath "src" </> FilePath "Lib"
    , FilePath "test" </> FilePath "Spec"
    ]

data ProjectFileType
  = Axel
  | Backend

getProjectFiles ::
     (Sem.Member Effs.FileSystem effs)
  => ProjectFileType
  -> Sem.Sem effs [FilePath]
getProjectFiles fileType = do
  files <-
    concatMapM
      getDirectoryContentsRec
      [FilePath "app", FilePath "src", FilePath "test"]
  let ext =
        case fileType of
          Axel -> ".axel"
          Backend -> ".hs"
  pure $ filter (\filePath -> ext `T.isSuffixOf` op FilePath filePath) files

transpileProject ::
     (Sem.Members '[ Effs.Console, Sem.Error Error, Effs.FileSystem, Effs.Ghci, Effs.Log, Effs.Process, Effs.Resource] effs)
  => Sem.Sem effs ModuleInfo
transpileProject =
  Ghci.withGhci $ do
    axelFiles <- getProjectFiles Axel
    initialModuleInfo <- readModuleInfo axelFiles
    (moduleInfo, _) <-
      Sem.runState initialModuleInfo $ mapM transpileFileInPlace axelFiles
    pure moduleInfo

buildProject ::
     (Sem.Members '[ Effs.Console, Sem.Error Error, Effs.FileSystem, Effs.Ghci, Effs.Log, Effs.Process, Effs.Resource] effs)
  => Sem.Sem effs ()
buildProject = do
  projectPath <- getCurrentDirectory
  transpiledFiles <- transpileProject
  buildStackProject transpiledFiles projectPath

convertProject ::
     (Sem.Members '[ Effs.Console, Effs.FileSystem, Sem.Error Error, Effs.FileSystem, Effs.Process] effs)
  => Sem.Sem effs ()
convertProject = getProjectFiles Backend >>= void . traverse convertFileInPlace

runProject ::
     (Sem.Members '[ Effs.Console, Sem.Error Error, Effs.FileSystem, Effs.Process] effs)
  => Sem.Sem effs ()
runProject = getCurrentDirectory >>= runStackProject

formatProject ::
     (Sem.Members '[ Effs.Console, Effs.FileSystem, Sem.Error Error] effs)
  => Sem.Sem effs ()
formatProject = getProjectFiles Axel >>= void . traverse formatFileInPlace
