import gleam/list
import lox/expression as expr
import lox/logger.{type Logger} as log
import lox/parser as prsr
import lox/scanner as scr
import lox/token as tkn

pub opaque type Lox {
  Lox(logger: Logger)
}

pub fn new() -> Lox {
  let logger = log.new()
  Lox(logger:)
}

pub fn tokenize(lox: Lox, file_contents: String) -> Lox {
  let scanner = scr.new(lox.logger, file_contents) |> scr.scan
  let logger = scanner |> scr.logger()
  let tokens = scanner |> scr.tokens()
  {
    use token <- list.map(tokens)
    token |> tkn.info |> log.print(lox.logger, _)
  }

  Lox(logger:)
}

pub fn parse(lox: Lox, file_contents: String) -> Lox {
  let scanner = scr.new(lox.logger, file_contents) |> scr.scan
  let parser = prsr.new(scanner |> scr.logger, scanner |> scr.tokens)
  case prsr.expression(parser) {
    Ok(#(parser, expression)) -> {
      let logger =
        parser
        |> prsr.logger
        |> log.print(expression |> expr.info)
      Lox(logger:)
    }
    Error(parser) -> Lox(logger: parser |> prsr.logger)
  }
}

pub fn logger(lox: Lox) -> Logger {
  lox.logger
}

pub fn update_logger(_lox: Lox, logger: Logger) -> Lox {
  Lox(logger:)
}
