import gleam/list
import lox/logger.{type Logger}
import lox/scanner
import lox/token

pub opaque type Lox {
  Lox(logger: Logger)
}

pub fn new() -> Lox {
  let logger = logger.new()
  Lox(logger:)
}

pub fn tokenize(lox: Lox, file_contents: String) -> Lox {
  let scanner = scanner.new(lox.logger, file_contents) |> scanner.scan
  let logger = scanner |> scanner.logger()
  let tokens = scanner |> scanner.tokens()
  {
    use token <- list.map(tokens)
    token |> token.info |> logger.print(lox.logger, _)
  }

  Lox(logger:)
}

pub fn logger(lox: Lox) -> Logger {
  lox.logger
}
