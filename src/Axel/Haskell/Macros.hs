module Axel.Haskell.Macros where
import qualified Prelude as GHCPrelude
import qualified Axel.Parse.AST as AST
import Axel.Prelude
import Axel.Haskell.Language(isOperator)
import qualified Data.Text as T
hygenisizeMacroName :: () => ((->) Text Text)
hygenisizeMacroName oldName = (let {suffix = if (isOperator (T.unpack oldName)) then "%%%%%%%%%%" else "_AXEL_AUTOGENERATED_MACRO_DEFINITION"} in if (T.isSuffixOf suffix oldName) then oldName else ((<>) oldName suffix))