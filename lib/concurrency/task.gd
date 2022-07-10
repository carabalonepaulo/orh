class_name Task
extends RefCounted


## Emitted when the [code]result[/code] is available.
signal completed(value)

enum State { PENDING, COMPLETED }

var state: int:
    get: return _state
var result:
    get: return _result
var is_completed: bool:
    get: return _state == State.COMPLETED

var _state: int = State.PENDING
var _result


func complete(value = null) -> void:
    _result = value
    _state = State.COMPLETED
    emit_signal("completed", value)
