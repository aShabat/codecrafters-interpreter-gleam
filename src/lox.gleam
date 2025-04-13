import gleam/list
import lox_logger.{type Logger}
import scanner.{type Scanner}
import token

pub opaque type Lox {
  Lox(logger: Logger, scanner: Scanner)
}

pub fn new() {
  let logger = lox_logger.new()
  let scanner = scanner.new(logger)
  Lox(logger:, scanner:)
}

pub fn tokenize(lox: Lox, file_contents: String) -> Nil {
  let tokens = lox.scanner |> scanner.scan_tokens(file_contents)
  {
    use token <- list.map(tokens)
    token |> token.info |> lox_logger.print(lox.logger, _)
  }

  Nil
}

pub fn warn(lox: Lox, string: String) {
  lox.logger |> lox_logger.print_error("Warning: " <> string)
}
