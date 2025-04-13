import gleam/int
import gleam/io

pub opaque type Logger {
  Logger
}

pub fn new() -> Logger {
  Logger
}

pub fn print(_logger: Logger, string: String) {
  io.println(string)
}

pub fn print_error(_logger: Logger, string: String) {
  io.println_error(string)
}

pub fn error(logger: Logger, line: Int, where: String, message: String) {
  logger
  |> print_error(
    "[line" <> int.to_string(line) <> "] Error" <> where <> ": " <> message,
  )
}
