import gleam/float
import gleam/list
import gleam/string
import lox/logger.{type Logger}
import lox/token.{type Token, Token}

pub opaque type Scanner {
  Scanner(
    logger: Logger,
    contents: String,
    mode: Mode,
    line: Int,
    tokens: List(Token),
  )
}

pub fn new(logger: Logger, contents: String) {
  Scanner(logger:, contents:, mode: Empty, line: 1, tokens: [])
}

pub fn tokens(scanner: Scanner) -> List(Token) {
  scanner.tokens |> list.reverse
}

pub fn scan(scanner: Scanner) -> Scanner {
  case scanner.mode {
    Done -> scanner
    _ -> scanner |> scan_step |> scan
  }
}

fn scan_step(scanner: Scanner) -> Scanner {
  case string.pop_grapheme(scanner.contents) {
    Error(_) -> scanner |> consume_grapheme("")
    Ok(#(grapheme, contents)) ->
      Scanner(..scanner, contents:) |> consume_grapheme(grapheme)
  }
}

type Mode {
  Empty
  Done

  Bang
  Equal
  Greater
  Less

  Slash
  Comment

  LoxString(string: String)
  LoxNumber(int: String, decimal: Result(String, Nil))
  Identifier(name: String)
}

fn consume_grapheme(scanner: Scanner, grapheme: String) -> Scanner {
  let Scanner(line:, mode:, tokens:, ..) = scanner

  case mode {
    Empty ->
      case grapheme {
        "" ->
          Scanner(..scanner, mode: Done, tokens: [
            Token(token.Eof, line, ""),
            ..tokens
          ])
        " " | "\t" | "\r" -> scanner
        "\n" -> Scanner(..scanner, line: line + 1)

        "(" ->
          Scanner(..scanner, tokens: [
            Token(token.LeftParen, line, "("),
            ..tokens
          ])
        ")" ->
          Scanner(..scanner, tokens: [
            Token(token.RightParen, line, ")"),
            ..tokens
          ])
        "{" ->
          Scanner(..scanner, tokens: [
            Token(token.LeftBrace, line, "{"),
            ..tokens
          ])
        "}" ->
          Scanner(..scanner, tokens: [
            Token(token.RightBrace, line, "}"),
            ..tokens
          ])
        "." ->
          Scanner(..scanner, tokens: [Token(token.Dot, line, "."), ..tokens])
        "," ->
          Scanner(..scanner, tokens: [Token(token.Comma, line, ","), ..tokens])
        ";" ->
          Scanner(..scanner, tokens: [
            Token(token.Semicolon, line, ";"),
            ..tokens
          ])
        "*" ->
          Scanner(..scanner, tokens: [Token(token.Star, line, "*"), ..tokens])
        "+" ->
          Scanner(..scanner, tokens: [Token(token.Plus, line, "+"), ..tokens])
        "-" ->
          Scanner(..scanner, tokens: [Token(token.Minus, line, "-"), ..tokens])

        "!" -> Scanner(..scanner, mode: Bang)
        "=" -> Scanner(..scanner, mode: Equal)
        ">" -> Scanner(..scanner, mode: Greater)
        "<" -> Scanner(..scanner, mode: Less)
        "/" -> Scanner(..scanner, mode: Slash)
        "\"" -> Scanner(..scanner, mode: LoxString(""))
        _ -> {
          case is_digit(grapheme), is_alpha(grapheme) {
            True, _ -> Scanner(..scanner, mode: LoxNumber(grapheme, Error(Nil)))
            _, True -> Scanner(..scanner, mode: Identifier(grapheme))
            _, _ -> {
              let logger =
                scanner.logger
                |> logger.syntax_error(
                  line,
                  "Unexpected character: " <> grapheme,
                )
              Scanner(..scanner, logger:)
            }
          }
        }
      }
    Bang ->
      case grapheme {
        "=" ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.BangEqual, line, "!="),
            ..tokens
          ])
        _ ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Bang, line, "!"),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    Equal ->
      case grapheme {
        "=" ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.EqualEqual, line, "=="),
            ..tokens
          ])
        _ ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Equal, line, "="),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    Greater ->
      case grapheme {
        "=" ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.GreaterEqual, line, ">="),
            ..tokens
          ])
        _ ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Greater, line, ">"),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    Less ->
      case grapheme {
        "=" ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.LessEqual, line, "<="),
            ..tokens
          ])
        _ ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Less, line, "<"),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    Slash ->
      case grapheme {
        "/" -> Scanner(..scanner, mode: Comment)
        _ ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Slash, line, "/"),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    Comment ->
      case grapheme {
        "\n" -> Scanner(..scanner, mode: Empty, line: line + 1)
        _ -> scanner
      }
    LoxString(string) ->
      case grapheme {
        "\"" ->
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.LoxString(string), line, "\"" <> string <> "\""),
            ..tokens
          ])
        "" -> {
          let logger =
            scanner.logger
            |> logger.syntax_error(line, "Unterminated string.")
          Scanner(..scanner, logger:)
        }
        _ -> Scanner(..scanner, mode: LoxString(string <> grapheme))
      }
    LoxNumber(int, decimal) ->
      case is_digit(grapheme), decimal, grapheme {
        True, Ok(decimal), _ ->
          Scanner(..scanner, mode: LoxNumber(int, Ok(decimal <> grapheme)))
        True, Error(Nil), _ ->
          Scanner(..scanner, mode: LoxNumber(int <> grapheme, decimal))
        False, Ok(""), _ -> {
          let assert Ok(number) = { int <> ".0" } |> float.parse
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.Dot, line, "."),
            Token(token.LoxNumber(number), line, int),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
        }
        False, Ok(decimal), _ -> {
          let assert Ok(number) = { int <> "." <> decimal } |> float.parse
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.LoxNumber(number), line, int <> "." <> decimal),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
        }
        False, Error(Nil), "." ->
          Scanner(..scanner, mode: LoxNumber(int, Ok("")))
        False, Error(Nil), _ -> {
          let assert Ok(number) = { int <> ".0" } |> float.parse
          Scanner(..scanner, mode: Empty, tokens: [
            Token(token.LoxNumber(number), line, int),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
        }
      }
    Identifier(name) -> {
      case is_alpha_numeric(grapheme) {
        True -> Scanner(..scanner, mode: Identifier(name <> grapheme))
        False ->
          Scanner(..scanner, mode: Empty, tokens: [
            identifier_token(name, line),
            ..tokens
          ])
          |> consume_grapheme(grapheme)
      }
    }
    _ -> {
      let logger =
        scanner.logger
        |> logger.syntax_error(line, "Unexpected symbol.")
      Scanner(..scanner, logger:)
    }
  }
}

pub fn logger(scanner: Scanner) -> Logger {
  scanner.logger
}

fn is_digit(grapheme: String) -> Bool {
  case grapheme == "" {
    True -> False
    _ -> {
      let assert [u_grapheme, u_0, u_9] =
        { grapheme <> "09" }
        |> string.to_utf_codepoints
        |> list.map(string.utf_codepoint_to_int)

      u_grapheme >= u_0 && u_grapheme <= u_9
    }
  }
}

fn is_alpha(grapheme: String) -> Bool {
  case grapheme == "" {
    True -> False
    False -> {
      let assert [u_grapheme, u_la, u_ua, u_lz, u_uz] =
        { grapheme <> "aAzZ" }
        |> string.to_utf_codepoints
        |> list.map(string.utf_codepoint_to_int)

      { u_grapheme >= u_la && u_grapheme <= u_lz }
      || { u_grapheme >= u_ua && u_grapheme <= u_uz }
      || grapheme == "_"
    }
  }
}

fn is_alpha_numeric(grapheme: String) -> Bool {
  is_digit(grapheme) || is_alpha(grapheme)
}

fn identifier_token(name: String, line: Int) -> Token {
  let value = case name {
    "and" -> token.And
    "class" -> token.Class
    "else" -> token.Else
    "false" -> token.LoxFalse
    "for" -> token.For
    "fun" -> token.Fun
    "if" -> token.If
    "nil" -> token.LoxNil
    "or" -> token.Or
    "print" -> token.Print
    "return" -> token.Return
    "super" -> token.Super
    "this" -> token.This
    "true" -> token.LoxTrue
    "var" -> token.Var
    "while" -> token.While

    _ -> token.Identifier(name)
  }

  Token(value, line, name)
}
