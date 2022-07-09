class_name Main
extends SceneTree


func start() -> void:
    pass


func update() -> void:
    pass


func stop() -> void:
    pass


func _initialize() -> void:
    start()


func _process(delta: float) -> bool:
    update()
    return false


func _finalize() -> void:
    stop()
