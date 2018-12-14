module Axel.Prelude where
import Axel.Parse.AST as AST
import Control.Lens.Cons (snoc)
mdo' ((:) var ((:) (AST.Symbol "<-") ((:) val rest)))
  = (AST.SExpression
       (concat
          [[(AST.Symbol ">>=")], [val],
           [(AST.SExpression
               (concat
                  [[(AST.Symbol "\\")], [(AST.SExpression (concat [[var]]))],
                   [(mdo' rest)]]))]]))
  where
mdo' ((:) val rest)
  = (case rest of
         [] -> val
         _ -> (AST.SExpression
                 (concat [[(AST.Symbol ">>")], [val], [(mdo' rest)]])))
  where

mdo' :: ((->) [AST.Expression] AST.Expression)
quasiquote_AXEL_AUTOGENERATED_MACRO_DEFINITION
  [(AST.SExpression xs)]
  = (let quasiquoteElem
           = (\ x ->
                (case x of
                     (AST.SExpression [(AST.Symbol "unquote"), x]) -> (AST.SExpression
                                                                         [(AST.Symbol "list"), x])
                     (AST.SExpression
                        [(AST.Symbol "unquoteSplicing"), x]) -> (AST.SExpression
                                                                   [(AST.Symbol
                                                                       "AST.toExpressionList"),
                                                                    x])
                     atom -> (AST.SExpression
                                [(AST.Symbol "list"),
                                 (AST.SExpression [(AST.Symbol "quasiquote"), atom])])))
       in
       (pure
          [(AST.SExpression
              [(AST.Symbol "AST.SExpression"),
               (AST.SExpression
                  [(AST.Symbol "concat"),
                   (AST.SExpression
                      ((:) (AST.Symbol "list") (map quasiquoteElem xs)))])])]))
  where
quasiquote_AXEL_AUTOGENERATED_MACRO_DEFINITION [atom]
  = (pure [(AST.SExpression [(AST.Symbol "quote"), atom])])
  where
applyInfix_AXEL_AUTOGENERATED_MACRO_DEFINITION [x, op, y]
  = (pure [(AST.SExpression (concat [[op], [x], [y]]))])
  where
defmacro_AXEL_AUTOGENERATED_MACRO_DEFINITION ((:) name cases)
  = (pure
       (map
          (\ x ->
             (AST.SExpression
                (concat
                   [[(AST.Symbol "=macro")], [name], (AST.toExpressionList x)])))
          cases))
  where
def_AXEL_AUTOGENERATED_MACRO_DEFINITION
  ((:) name ((:) typeSig cases))
  = (pure
       (snoc
          (map
             (\ x ->
                (AST.SExpression
                   (concat [[(AST.Symbol "=")], [name], (AST.toExpressionList x)])))
             cases)
          (AST.SExpression
             (concat [[(AST.Symbol "::")], [name], [typeSig]]))))
  where
fnCase_AXEL_AUTOGENERATED_MACRO_DEFINITION cases
  = ((<$>)
       (\ varId ->
          [(AST.SExpression
              (concat
                 [[(AST.Symbol "\\")], [(AST.SExpression (concat [[varId]]))],
                  [(AST.SExpression
                      (concat
                         [[(AST.Symbol "case")], [varId],
                          (AST.toExpressionList cases)]))]]))])
       AST.gensym)
  where
mdo_AXEL_AUTOGENERATED_MACRO_DEFINITION input
  = (pure [(mdo' input)])
  where
if_AXEL_AUTOGENERATED_MACRO_DEFINITION [cond, true, false]
  = (pure
       [(AST.SExpression
           (concat
              [[(AST.Symbol "case")], [cond],
               [(AST.SExpression (concat [[(AST.Symbol "True")], [true]]))],
               [(AST.SExpression (concat [[(AST.Symbol "False")], [false]]))]]))])
  where

quasiquote_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                               ((->) ([] AST.Expression) (IO ([] AST.Expression)))

applyInfix_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                               ((->) ([] AST.Expression) (IO ([] AST.Expression)))

defmacro_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                             ((->) ([] AST.Expression) (IO ([] AST.Expression)))

def_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                        ((->) ([] AST.Expression) (IO ([] AST.Expression)))

fnCase_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                           ((->) ([] AST.Expression) (IO ([] AST.Expression)))

mdo_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                        ((->) ([] AST.Expression) (IO ([] AST.Expression)))

if_AXEL_AUTOGENERATED_MACRO_DEFINITION ::
                                       ((->) ([] AST.Expression) (IO ([] AST.Expression)))