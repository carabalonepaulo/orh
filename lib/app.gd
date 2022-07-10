class_name App
extends RefCounted


signal started
signal stopped

const SYNC := 0
const ASYNC := 1


class MetaMiddleware extends RefCounted:
    var kind: int
    var callable

    func _init(_kind: int, _callable: Callable):
        kind = _kind
        callable = _callable


var _server: HttpServer
var _meta_middlewares: Array[MetaMiddleware]
var _stateful_middlewares: Array[StatefulMiddleware]


func _init(port: int = 8080):
    _meta_middlewares = []
    _server = HttpServer.new(port)
    _server.connect("request_received", _on_request_received)


func start() -> void:
    emit_signal("started")
    _server.start()
    for middleware in _stateful_middlewares:
        middleware.start()


func stop() -> void:
    emit_signal("stopped")
    _server.stop()
    for middleware in _stateful_middlewares:
        middleware.stop()
    _stateful_middlewares.clear()
    _meta_middlewares.clear()


func update() -> void:
    _server.poll()
    for middleware in _stateful_middlewares:
        middleware.update()


func use(middleware) -> void:
    _push_middleware(SYNC, middleware)


func use_async(middleware) -> void:
    _push_middleware(ASYNC, middleware)


func _push_middleware(kind: int, middleware) -> void:
    if middleware is StatefulMiddleware:
        _meta_middlewares.push_back(MetaMiddleware.new(kind, middleware.execute))
        _stateful_middlewares.push_back(middleware)
    elif middleware is Callable:
        _meta_middlewares.push_back(MetaMiddleware.new(kind, middleware))
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

    for meta in _meta_middlewares:
        if meta.kind == SYNC:
            if meta.callable.call(context) == true:
                break
        else:
            if await meta.callable.call(context) == true:
                break

    context.clear()
