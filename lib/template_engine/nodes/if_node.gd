class_name IfNode
extends AstNode


var if_content: String
var else_content: String


func _init(_line: int, _column: int, _lexeme: String):
    super(_line, _column, _lexeme)
