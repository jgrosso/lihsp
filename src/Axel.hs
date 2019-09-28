{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
module Axel where
import qualified Prelude as GHCPrelude
import qualified Axel.Parse.AST as AST
import Axel.Prelude
import Axel.Haskell.Language(haskellOperatorSymbols,haskellSyntaxSymbols)
import Axel.Parse(hygenisizeIdentifier)
import qualified Axel.Sourcemap as SM
import Axel.Utils.FilePath(takeFileName)
import Data.IORef(IORef,modifyIORef,newIORef,readIORef)
import qualified Data.Text as T
import System.IO.Unsafe(unsafePerformIO)
expandDo' :: () => ((->) ([] SM.Expression) SM.Expression)
expandDo' ((:) (AST.SExpression _ [(AST.Symbol _ "<-"),var,val]) rest) = (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 42 8))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/2535311963147900590/result.axel" (SM.Position 2 157))) ">>=")],[val],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 42 18))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/2535311963147900590/result.axel" (SM.Position 2 255))) "\\")],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 42 21))) (concat [[var]]))],[(expandDo' rest)]]))]]))
expandDo' ((:) (AST.SExpression _ ((:) (AST.Symbol _ "let") bindings)) rest) = (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 44 8))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/2535311963147900590/result.axel" (SM.Position 3 161))) "let")],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 44 13))) (concat [(AST.toExpressionList bindings)]))],[(expandDo' rest)]]))
expandDo' ((:) val rest) = (case rest of {[] -> val;_ -> (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 48 13))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/2535311963147900590/result.axel" (SM.Position 4 138))) ">>")],[val],[(expandDo' rest)]]))})
gensymCounter :: () => (IORef Int)
gensymCounter  = (unsafePerformIO (newIORef 0))
{-# NOINLINE gensymCounter #-}
gensym :: () => (IO SM.Expression)
gensym  = ((>>=) (readIORef gensymCounter) (\suffix -> (let {identifier = ((<>) "aXEL_AUTOGENERATED_IDENTIFIER_" (showText suffix))} in ((>>) (modifyIORef gensymCounter succ) (pure (AST.Symbol Nothing (T.unpack identifier)))))))
isPrelude :: () => ((->) FilePath Bool)
isPrelude  = ((.) ((==) (FilePath "Axel.axel")) takeFileName)
preludeMacros :: () => ([] Text)
preludeMacros  = (map ((.) T.pack (hygenisizeIdentifier haskellSyntaxSymbols haskellOperatorSymbols)) ["applyInfix","defmacro","def","do'","\\case","syntaxQuote"])
applyInfix_AXEL_AUTOGENERATED_MACRO_DEFINITION [x,op,y] = (pure [(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 18 17))) (concat [[op],[x],[y]]))])
defmacro_AXEL_AUTOGENERATED_MACRO_DEFINITION ((:) name cases) = (pure (map (\(AST.SExpression _ ((:) args body)) -> (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 23 55))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 23 56))) "aXEL_VALUE_aXEL_SYMBOL_EQUALS_macro")],[name],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 23 69))) (concat [[args]]))],(AST.toExpressionList body)]))) cases))
def_AXEL_AUTOGENERATED_MACRO_DEFINITION ((:) name ((:) typeSig cases)) = (pure ((:) (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 29 17))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/1530223672413010431/result.axel" (SM.Position 1 166))) "::")],[name],(AST.toExpressionList typeSig)])) (map (\x -> (AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 30 29))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/1530223672413010431/result.axel" (SM.Position 1 309))) "=")],[name],(AST.toExpressionList x)]))) cases)))
syntaxQuote_AXEL_AUTOGENERATED_MACRO_DEFINITION [x] = (pure [(AST.quoteExpression (const (AST.Symbol Nothing "_")) x)])
do'_AXEL_AUTOGENERATED_MACRO_DEFINITION input = (pure [(expandDo' input)])
aXEL_VALUE_aXEL_SYMBOL_BACKSLASH_case_AXEL_AUTOGENERATED_MACRO_DEFINITION cases = (fmap (\varId -> [(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 67 15))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/759944835796628298/result.axel" (SM.Position 1 188))) "\\")],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 67 18))) (concat [[varId]]))],[(AST.SExpression (GHCPrelude.Just ((,) "src/Axel.axel" (SM.Position 67 27))) (concat [[(AST.Symbol (GHCPrelude.Just ((,) "axelTemp/759944835796628298/result.axel" (SM.Position 1 375))) "case")],[varId],(AST.toExpressionList cases)]))]]))]) gensym)
applyInfix_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]
defmacro_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]
def_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]
syntaxQuote_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]
do'_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]
aXEL_VALUE_aXEL_SYMBOL_BACKSLASH_case_AXEL_AUTOGENERATED_MACRO_DEFINITION :: [AST.Expression SM.SourceMetadata] -> GHCPrelude.IO [AST.Expression SM.SourceMetadata]