import gleam/list
import gleam/string
import lox_logger.{type Logger}
import token.{type Token, Token}

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
    Error(_) ->
      Scanner(..scanner, mode: Done, tokens: [
        Token(token.Eof, scanner.line, ""),
        ..scanner.tokens
      ])
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
}

fn consume_grapheme(scanner: Scanner, grapheme: String) -> Scanner {
  let Scanner(line:, mode:, tokens:, ..) = scanner

  case mode {
    Empty ->
      case grapheme {
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
        _ -> {
          let logger =
            scanner.logger
            |> lox_logger.syntax_error(
              line,
              "Unexpected character: " <> grapheme,
            )
          Scanner(..scanner, logger:)
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
    _ -> {
      let logger =
        scanner.logger
        |> lox_logger.syntax_error(line, "Unexpected symbol.")
      Scanner(..scanner, logger:)
    }
  }
}

fn put_front(left: List(value), right: List(value)) -> List(value) {
  case left {
    [] -> right
    [head, ..tail] -> put_front(tail, [head, ..right])
  }
}

pub fn logger(scanner: Scanner) -> Logger {
  scanner.logger
}
