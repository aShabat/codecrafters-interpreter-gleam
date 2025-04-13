import lox

import argv
import simplifile

pub fn main() {
  let args = argv.load().arguments

  let interpreter = lox.new()

  case args {
    ["tokenize", filename] -> {
      case simplifile.read(filename) {
        Error(error) ->
          interpreter |> lox.warn(error |> simplifile.describe_error)
        Ok(file_contents) -> interpreter |> lox.tokenize(file_contents)
      }
    }
    _ -> {
      lox.warn(interpreter, "Usage: ./your_program.sh tokenize <filename>")
      exit(1)
    }
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil
