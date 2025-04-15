import gleam/result
import lox/expression.{type Expr}
import lox/logger.{type Logger}
import lox/token.{type Token}

import gleam/option.{type Option, None, Some}

pub opaque type Parser {
  Parser(logger: Logger, tokens: List(Token))
}

pub fn new(logger: Logger, tokens: List(Token)) -> Parser {
  Parser(logger:, tokens:)
}

pub fn expression(parser: Parser) -> Result(#(Parser, Expr), Parser) {
  equality(parser, None)
}

fn equality(
  parser: Parser,
  acc: Option(Expr),
) -> Result(#(Parser, Expr), Parser) {
  use #(parser, left) <- result.try(case acc {
    None -> comparison(parser, None)
    Some(expression) -> Ok(#(parser, expression))
  })
  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.BangEqual | token.EqualEqual -> {
      use #(parser, right) <- result.try(comparison(
        Parser(..parser, tokens:),
        None,
      ))
      equality(parser, Some(expression.Binary(first, left, right)))
    }
    _ -> Ok(#(parser, left))
  }
}

fn comparison(
  parser: Parser,
  acc: Option(Expr),
) -> Result(#(Parser, Expr), Parser) {
  use #(parser, left) <- result.try(case acc {
    None -> term(parser, None)
    Some(expression) -> Ok(#(parser, expression))
  })

  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.Greater | token.GreaterEqual | token.Less | token.LessEqual -> {
      use #(parser, right) <- result.try(term(Parser(..parser, tokens:), None))
      equality(parser, Some(expression.Binary(first, left, right)))
    }
    _ -> Ok(#(parser, left))
  }
}

fn term(parser: Parser, acc: Option(Expr)) -> Result(#(Parser, Expr), Parser) {
  use #(parser, left) <- result.try(case acc {
    None -> factor(parser, None)
    Some(expression) -> Ok(#(parser, expression))
  })

  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.Minus | token.Plus -> {
      use #(parser, right) <- result.try(factor(Parser(..parser, tokens:), None))
      equality(parser, Some(expression.Binary(first, left, right)))
    }
    _ -> Ok(#(parser, left))
  }
}

fn factor(parser: Parser, acc: Option(Expr)) -> Result(#(Parser, Expr), Parser) {
  use #(parser, left) <- result.try(case acc {
    None -> unary(parser)
    Some(expression) -> Ok(#(parser, expression))
  })

  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.Slash | token.Star -> {
      use #(parser, right) <- result.try(unary(Parser(..parser, tokens:)))
      equality(parser, Some(expression.Binary(first, left, right)))
    }
    _ -> Ok(#(parser, left))
  }
}

fn unary(parser: Parser) -> Result(#(Parser, Expr), Parser) {
  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.Bang | token.Minus -> {
      use #(parser, right) <- result.try(unary(Parser(..parser, tokens:)))
      Ok(#(parser, expression.Unary(first, right)))
    }
    _ -> primary(parser)
  }
}

fn primary(parser: Parser) -> Result(#(Parser, Expr), Parser) {
  let assert [first, ..tokens] = parser.tokens
  case first.value {
    token.LoxNil
    | token.LoxNumber(_)
    | token.LoxString(_)
    | token.LoxFalse
    | token.LoxTrue ->
      Ok(#(Parser(..parser, tokens:), expression.Literal(first)))
    token.LeftParen -> {
      use #(parser, expression) <- result.try(expression(
        Parser(..parser, tokens:),
      ))
      let assert [last, ..tokens] = parser.tokens
      case last.value == token.RightParen {
        True ->
          Ok(#(Parser(..parser, tokens:), expression.Grouping(expression)))
        False -> {
          let logger =
            parser.logger
            |> logger.syntax_error(last.line, "Expect ')' after expression.")
          Error(Parser(..parser, logger:))
        }
      }
    }
    _ -> {
      let logger =
        parser.logger
        |> logger.syntax_error(
          first.line,
          "Unexpected symbol: " <> first.lexemme,
        )
      Error(Parser(..parser, logger:))
    }
  }
}

// fn synchronize(parser: Parser) -> Parser {
//   case first_token(parser).value {
//     token.Eof
//     | token.Class
//     | token.Fun
//     | token.Var
//     | token.For
//     | token.If
//     | token.While
//     | token.Print
//     | token.Return -> parser
//     _ -> {
//       let assert [first, ..tokens] = parser.tokens
//       case first.value == token.Semicolon {
//         True -> Parser(..parser, tokens:)
//         False -> Parser(..parser, tokens:) |> synchronize
//       }
//     }
//   }
// }

fn first_token(parser: Parser) -> token.Token {
  let assert [first, ..] = parser.tokens
  first
}

pub fn logger(parser: Parser) -> Logger {
  parser.logger
}
