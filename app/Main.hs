{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Axel.Eff.Console (putStrLn)
import qualified Axel.Eff.Console as Effs (Console)
import qualified Axel.Eff.Console as Console (runEff)
import qualified Axel.Eff.FileSystem as FS (runEff)
import qualified Axel.Eff.FileSystem as Effs (FileSystem)
import qualified Axel.Eff.Ghci as Ghci (runEff)
import qualified Axel.Eff.Ghci as Effs (Ghci)
import qualified Axel.Eff.Log as Log (ignoreEff)
import qualified Axel.Eff.Log as Effs (Log)
import qualified Axel.Eff.Process as Proc (runEff)
import qualified Axel.Eff.Process as Effs (Process)
import qualified Axel.Eff.Resource as Res (runEff)
import qualified Axel.Eff.Resource as Effs (Resource)
import qualified Axel.Error as Error (Error, unsafeRunEff)
import Axel.Haskell.File (convertFile', transpileFile')
import Axel.Haskell.Project (buildProject, runProject)
import Axel.Haskell.Stack (axelStackageVersion)
import Axel.Macros (ModuleInfo)
import Axel.Parse.Args (Command(Convert, File, Project, Version), commandParser)
import Control.Monad (void)
import Control.Monad.Freer (Eff)
import qualified Control.Monad.Freer as Effs (runM)
import qualified Control.Monad.Freer.Error as Effs (Error)
import Control.Monad.Freer.State (evalState)
import qualified Data.Map as Map (empty)
import Options.Applicative ((<**>), execParser, helper, info, progDesc)
import Prelude hiding (putStrLn)

type AppEffs
   = (Eff '[ Effs.Log, Effs.Console, Effs.Error Error.Error, Effs.FileSystem, Effs.Ghci, Effs.Process, Effs.Resource, IO])

runApp =
  ((.)
     Effs.runM
     ((.)
        Res.runEff
        ((.)
           Proc.runEff
           ((.)
              Ghci.runEff
              ((.)
                 FS.runEff
                 ((.) Error.unsafeRunEff ((.) Console.runEff Log.ignoreEff)))))))

runApp :: (((->) (AppEffs a)) (IO a))
app (Convert filePath) = (void (convertFile' filePath))
app (File filePath) =
  (void ((evalState @ModuleInfo Map.empty) (transpileFile' filePath)))
app (Project) = ((>>) buildProject runProject)
app (Version) = (putStrLn ((<>) "Axel version " axelStackageVersion))

app :: (((->) Command) (AppEffs ()))
main = do
  modeCommand <-
    execParser $
    info (commandParser <**> helper) (progDesc "The command to run.")
  runApp $ app modeCommand

main :: (IO ())
