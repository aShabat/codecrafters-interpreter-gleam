import gleam/int
import gleam/io

pub opaque type Logger {
  Logger(syntax_error: Bool, runtime_error: Bool)
}

pub fn new() -> Logger {
  Logger(False, False)
}

pub fn exit_code(logger: Logger) -> Int {
  case logger.syntax_error {
    True -> 65
    False -> 1
  }
}

pub fn print(logger: Logger, string: String) -> Logger {
  io.println(string)
  logger
}

pub fn print_error(logger: Logger, string: String) -> Logger {
  io.println_error(string)
  logger
}

pub fn error(
  logger: Logger,
  line: Int,
  where: String,
  message: String,
) -> Logger {
  logger
  |> print_error(
    "[line" <> int.to_string(line) <> "] Error" <> where <> ": " <> message,
  )
}

pub fn syntax_error(logger: Logger, line: Int, message: String) -> Logger {
  Logger(..logger, syntax_error: True)
  |> error(line, "", message)
}
