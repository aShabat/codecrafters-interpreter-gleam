import gleam/float

pub type Token {
  Token(value: TokenValue, line: Int, lexemme: String)
}

pub type TokenValue {
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Slash
  Star

  Bang
  BangEqual
  Equal
  EqualEqual
  Greater
  GreaterEqual
  Less
  LessEqual

  Identifier(name: String)
  LoxString(value: String)
  LoxNumber(value: Float)

  And
  Class
  Else
  LoxFalse
  Fun
  For
  If
  LoxNil
  Or
  Print
  Return
  Super
  This
  LoxTrue
  Var
  While

  Eof
}

pub fn info(token: Token) -> String {
  let name = case token.value {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    Comma -> "COMMA"
    Dot -> "DOT"
    Minus -> "MINUS"
    Plus -> "PLUS"
    Semicolon -> "SEMICOLON"
    Slash -> "SLASH"
    Star -> "STAR"
    Bang -> "BANG"
    BangEqual -> "BANG_EQUAL"
    Equal -> "EQUAL"
    EqualEqual -> "EQUAL_EQUAL"
    Greater -> "GREATER"
    GreaterEqual -> "GREATER_EQUAL"
    Less -> "LESS"
    LessEqual -> "LESS_EQUAL"
    Identifier(_) -> "IDENTIFIER"
    LoxString(_) -> "STRING"
    LoxNumber(_) -> "NUMBER"
    And -> "AND"
    Class -> "CLASS"
    Else -> "ELSE"
    LoxFalse -> "FALSE"
    Fun -> "FUN"
    For -> "FOR"
    If -> "IF"
    LoxNil -> "NIL"
    Or -> "OR"
    Print -> "PRINT"
    Return -> "RETURN"
    Super -> "SUPER"
    This -> "THIS"
    LoxTrue -> "TRUE"
    Var -> "VAR"
    While -> "WHILE"
    Eof -> "EOF"
  }

  let value = case token.value {
    LoxString(value) -> value
    LoxNumber(value) -> float.to_string(value)
    _ -> "null"
  }

  name <> " " <> token.lexemme <> " " <> value
}
