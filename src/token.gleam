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
  String(value: String)
  Number(value: Float)

  And
  Class
  Else
  False
  Fun
  For
  If
  Nil
  Or
  Print
  Return
  Super
  This
  True
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
    String(_) -> "STRING"
    Number(_) -> "NUMBER"
    And -> "AND"
    Class -> "CLASS"
    Else -> "ELSE"
    False -> "FALSE"
    Fun -> "FUN"
    For -> "FOR"
    If -> "IF"
    Nil -> "NIL"
    Or -> "OR"
    Print -> "PRINT"
    Return -> "RETURN"
    Super -> "SUPER"
    This -> "THIS"
    True -> "TRUE"
    Var -> "VAR"
    While -> "WHILE"
    Eof -> "EOF"
  }

  let value = case token.value {
    String(value) -> value
    Number(value) -> float.to_string(value)
    _ -> "null"
  }

  name <> " " <> token.lexemme <> "" <> value
}
