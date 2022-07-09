class_name App
extends SceneTree


var _quit := false
var _server: HttpServer
var _middlewares: Array[Middleware]


func start() -> void:
    _middlewares = get_middlewares()
    _server = HttpServer.new()
    _server.connect("request_received", _on_request_received)
    _server.start()


func stop() -> void:
    _middlewares.clear()
    _server.stop()


func update() -> void:
    _server.poll()


func get_middlewares() -> Array[Middleware]:
    return []


func _initialize():
    start()


func _process(_delta: float):
    update()
    return _quit


func _finalize():
    stop()
    _middlewares.clear()


func _on_request_received(req: HttpRequest, res: HttpResponse) -> void:
    var context := {
        "request": req,
        "response": res,
        "req": req,
        "res": res
    }

    for middleware in _middlewares:
        if not middleware.execute(context):
            return

    res.send(405)
