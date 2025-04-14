import gleam/float
import lox/token.{type Token}

pub type Expr {
  Literal(token: Token)
  Unary(operator: Token, right: Expr)
  Binary(operator: Token, left: Expr, right: Expr)
  Grouping(expression: Expr)
}

pub fn info(expression: Expr) -> String {
  case expression {
    Literal(token) ->
      case token.value {
        token.LoxString(string) -> string
        token.LoxNumber(number) -> float.to_string(number)
        _ -> token.lexemme
      }
    Unary(operator, right) ->
      "(" <> operator.lexemme <> " " <> info(right) <> ")"
    Binary(operator, left, right) ->
      "(" <> operator.lexemme <> " " <> info(left) <> " " <> info(right) <> ")"
    Grouping(expression) -> "(" <> info(expression) <> ")"
  }
}
