import lox/logger.{type Logger}

pub opaque type Parser {
  Parser(logger: Logger)
}
