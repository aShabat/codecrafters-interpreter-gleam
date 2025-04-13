import gleam/list
import gleam/string
import lox_logger.{type Logger}
import token.{type Token, Token}

pub opaque type Scanner {
  Scanner(logger: Logger)
}

pub fn new(logger: Logger) {
  Scanner(logger:)
}

pub fn scan_tokens(scanner: Scanner, file_contents: String) -> List(Token) {
  scan_tokens_helper(scanner, file_contents, State(Empty, 1), [])
  |> list.reverse
}

fn scan_tokens_helper(
  scanner: Scanner,
  contents: String,
  state: State,
  tokens: List(Token),
) -> List(Token) {
  echo contents
  case string.pop_grapheme(contents) {
    Error(_) -> [token.Token(token.Eof, state.line, ""), ..tokens]
    Ok(#(grapheme, contents)) -> {
      let #(new_tokens, state) = consume_grapheme(scanner, state, grapheme)
      scan_tokens_helper(
        scanner,
        contents,
        state,
        put_front(new_tokens, tokens),
      )
    }
  }
}

type Mode {
  Empty

  Bang
  Equal
  Greater
  Less
}

type State {
  State(mode: Mode, line: Int)
}

fn consume_grapheme(
  scanner: Scanner,
  state: State,
  grapheme: String,
) -> #(List(Token), State) {
  case state {
    State(Empty, line) ->
      case grapheme {
        "\t" | "\r" -> #([], state)
        "\n" -> #([], State(..state, line: line + 1))

        "(" -> #([Token(token.LeftParen, line, "(")], state)
        ")" -> #([Token(token.RightParen, line, ")")], state)
        "{" -> #([Token(token.LeftBrace, line, "{")], state)
        "}" -> #([Token(token.RightBrace, line, "}")], state)
        "." -> #([Token(token.Dot, line, ".")], state)
        "," -> #([Token(token.Comma, line, ",")], state)
        ";" -> #([Token(token.Semicolon, line, ";")], state)
        "*" -> #([Token(token.Star, line, "*")], state)
        "+" -> #([Token(token.Plus, line, "+")], state)
        "-" -> #([Token(token.Minus, line, "-")], state)

        "!" -> #([], State(..state, mode: Bang))
        "=" -> #([], State(..state, mode: Equal))
        ">" -> #([], State(..state, mode: Greater))
        "<" -> #([], State(..state, mode: Less))
        _ -> {
          scanner.logger
          |> lox_logger.error(state.line, "", "Unexpected symbol.")
          #([], State(..state, mode: Empty))
        }
      }
    _ -> {
      scanner.logger
      |> lox_logger.error(state.line, "", "Unexpected symbol.")
      #([], State(..state, mode: Empty))
    }
  }
}

fn put_front(left: List(value), right: List(value)) -> List(value) {
  case left {
    [] -> right
    [head, ..tail] -> put_front(tail, [head, ..right])
  }
}
