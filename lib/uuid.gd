class_name UUID
extends RefCounted


var highest_index: int:
    get: return _highest_index


var _available_indices: Array[int]
var _highest_index: int


func _init():
    _available_indices = []
    _highest_index = -1


func get_next() -> int:
    if _available_indices.size() > 0:
        return _available_indices.pop_back()
    _highest_index += 1
    return _highest_index


func release(id: int) -> void:
    _available_indices.push_back(id)


func dispose() -> void:
    _available_indices.clear()


static func v4() -> String:
    return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
        randi() % 255,
        randi() % 255,
        randi() % 255,
        randi() % 255,

        randi() % 255,
        randi() % 255,

        ((randi() % 255) & 0x0F) | 0x40,
        randi() % 255,

        ((randi() % 255) & 0x3F) | 0x80,
        randi() % 255,

        randi() % 255,
        randi() % 255,
        randi() % 255,
        randi() % 255,
        randi() % 255,
        randi() % 255,
    ]
