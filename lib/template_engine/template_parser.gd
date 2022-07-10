class_name TemplateParser
extends RefCounted


func parse(text: String) -> AstNode:
    return null


func _is_alpha(c: String) -> bool:
    return false


func _is_num(c: String) -> bool:
    return false


func _is_alphanum(c: String) -> bool:
    return false


func _is_whitespace(c: String) -> bool:
    return false


func _skip_char(c: String) -> int:
    return -1


func _skip_until(cond: Callable) -> int:
    return -1

