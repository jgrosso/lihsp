module Lihsp.Utils.Display where

import Data.Char (isSymbol, toLower, toUpper)
import Data.List (intercalate)
import Data.List.Split (splitOn)
import Data.Semigroup ((<>))

data Delimiter
  = Commas
  | Newlines
  | Pipes
  | Spaces

delimit :: Delimiter -> [String] -> String
delimit delimiter = intercalate (lookupDelimiter delimiter)
  where
    lookupDelimiter Commas = ","
    lookupDelimiter Newlines = "\n"
    lookupDelimiter Pipes = "|"
    lookupDelimiter Spaces = " "

-- https://stackoverflow.com/questions/10548170/what-characters-are-permitted-for-haskell-operators
isOperator :: String -> Bool
isOperator = all $ \x -> isSymbol x || x `elem` "!#$%&*+./<=>?@\\^|-~:"

kebabToCamelCase :: String -> String
kebabToCamelCase input = preserveHead $ concatMap upperFirst $ splitOn "-" input
  where
    preserveHead [] = []
    preserveHead (_:newIdentifierTail) = head input : newIdentifierTail

lowerFirst :: String -> String
lowerFirst (x:xs) = toLower x : xs
lowerFirst "" = ""

renderBlock :: [String] -> String
renderBlock = surround CurlyBraces . intercalate ";"

renderPragma :: String -> String
renderPragma x = "{-# " <> x <> " #-}"

data Bracket
  = CurlyBraces
  | DoubleQuotes
  | Parentheses
  | SingleQuotes
  | SquareBrackets

surround :: Bracket -> String -> String
surround CurlyBraces x = "{" <> x <> "}"
surround DoubleQuotes x = "\"" <> x <> "\""
surround Parentheses x = "(" <> x <> ")"
surround SingleQuotes x = "'" <> x <> "'"
surround SquareBrackets x = "[" <> x <> "]"

upperFirst :: String -> String
upperFirst (x:xs) = toUpper x : xs
upperFirst "" = ""
