class_name App
extends RefCounted


signal started
signal stopped


const SYNC := 0
const ASYNC := 1
const KIND := 0
const CALLABLE := 1


var _server: HttpServer
var _middlewares: Array[Array]


func _init(port: int = 8080):
    _middlewares = []
    _server = HttpServer.new(port)
    _server.connect("request_received", _on_request_received)


func start() -> void:
    emit_signal("started")
    _server.start()


func stop() -> void:
    emit_signal("stopped")
    _server.stop()
    _middlewares.clear()


func update() -> void:
    _server.poll()


func use(middleware) -> void:
    _push_middleware(_middlewares, SYNC, middleware)


func use_async(middleware) -> void:
    _push_middleware(_middlewares, ASYNC, middleware)


func _push_middleware(container: Array, kind: int, middleware) -> void:
    if middleware is Middleware:
        container.push_back([kind, func(ctx: Dictionary) -> bool:
            return middleware.execute(ctx)])
    elif middleware is Callable:
        container.push_back([kind, middleware])
    else:
        push_error("Invalid middleware '%s'." % middleware.get_class())


func _on_request_received(req: HttpRequest, res: HttpResponse) -> void:
    var context := {
        "app": self,
        "request": req,
        "response": res,
        "req": req,
        "res": res
    }

    for middleware in _middlewares:
        if middleware[KIND] == SYNC:
            if middleware[CALLABLE].call(context) == true:
                break
        else:
            if await middleware[CALLABLE].call(context) == true:
                break

    context.clear()
