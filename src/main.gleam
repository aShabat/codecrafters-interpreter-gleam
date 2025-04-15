import lox
import lox/logger

import argv
import simplifile

pub fn main() -> Nil {
  let args = argv.load().arguments

  let interpreter = lox.new()

  case args {
    ["tokenize", filename] -> {
      let interpreter = case simplifile.read(filename) {
        Error(error) -> {
          interpreter
          |> lox.logger
          |> logger.print_error(
            "Error: couldn't access file: " <> simplifile.describe_error(error),
          )
          |> lox.update_logger(interpreter, _)
        }
        Ok(file_contents) -> {
          interpreter |> lox.tokenize(file_contents)
        }
      }
      interpreter |> lox.logger |> logger.exit_code |> exit
    }
    ["parse", filename] -> {
      let interpreter = case simplifile.read(filename) {
        Error(error) -> {
          interpreter
          |> lox.logger
          |> logger.print_error(
            "Error: couldn't access file: " <> simplifile.describe_error(error),
          )
          |> lox.update_logger(interpreter, _)
        }
        Ok(file_contents) -> {
          interpreter |> lox.parse(file_contents)
        }
      }
      interpreter |> lox.logger |> logger.exit_code |> exit
    }
    _ -> {
      interpreter
      |> lox.logger
      |> logger.print_error("Usage: ./your_program.sh tokenize <filename>")
      interpreter |> lox.logger |> logger.exit_code |> exit
    }
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil
