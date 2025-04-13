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
  case scanner.mode {
    Empty ->
      case grapheme {
        "\t" | "\r" -> scanner
        "\n" -> Scanner(..scanner, line: scanner.line + 1)

        "(" ->
          Scanner(..scanner, tokens: [
            Token(token.LeftParen, scanner.line, "("),
            ..scanner.tokens
          ])
        ")" ->
          Scanner(..scanner, tokens: [
            Token(token.RightParen, scanner.line, ")"),
            ..scanner.tokens
          ])
        "{" ->
          Scanner(..scanner, tokens: [
            Token(token.LeftBrace, scanner.line, "{"),
            ..scanner.tokens
          ])
        "}" ->
          Scanner(..scanner, tokens: [
            Token(token.RightBrace, scanner.line, "}"),
            ..scanner.tokens
          ])
        "." ->
          Scanner(..scanner, tokens: [
            Token(token.Dot, scanner.line, "."),
            ..scanner.tokens
          ])
        "," ->
          Scanner(..scanner, tokens: [
            Token(token.Comma, scanner.line, ","),
            ..scanner.tokens
          ])
        ";" ->
          Scanner(..scanner, tokens: [
            Token(token.Semicolon, scanner.line, ";"),
            ..scanner.tokens
          ])
        "*" ->
          Scanner(..scanner, tokens: [
            Token(token.Star, scanner.line, "*"),
            ..scanner.tokens
          ])
        "+" ->
          Scanner(..scanner, tokens: [
            Token(token.Plus, scanner.line, "+"),
            ..scanner.tokens
          ])
        "-" ->
          Scanner(..scanner, tokens: [
            Token(token.Minus, scanner.line, "-"),
            ..scanner.tokens
          ])

        "!" -> Scanner(..scanner, mode: Bang)
        "=" -> Scanner(..scanner, mode: Equal)
        ">" -> Scanner(..scanner, mode: Greater)
        "<" -> Scanner(..scanner, mode: Less)
        _ -> {
          let logger =
            scanner.logger
            |> lox_logger.syntax_error(
              scanner.line,
              "Unexpected character: " <> grapheme,
            )
          Scanner(..scanner, logger:)
        }
      }
    _ -> {
      let logger =
        scanner.logger
        |> lox_logger.syntax_error(scanner.line, "Unexpected symbol.")
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
