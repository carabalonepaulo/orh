class_name App
extends RefCounted


const SYNC := 0
const ASYNC := 1
const KIND := 0
const CALLABLE := 1


var _server: HttpServer
var _middlewares: Array


func _init(port: int = 8080):
    _middlewares = []
    _server = HttpServer.new(port)
    _server.connect("request_received", _on_request_received)


func start() -> void:
    _server.start()


func stop() -> void:
    _server.stop()
    _middlewares.clear()


func update() -> void:
    _server.poll()


func use(middleware) -> void:
    if middleware is Array:
        for m in middleware:
            use(m)
    else:
        _push_middleware(SYNC, middleware)


func use_async(middleware) -> void:
    if middleware is Array:
        for m in middleware:
            use_async(m)
    else:
        _push_middleware(ASYNC, middleware)


func _push_middleware(kind: int, middleware) -> void:
    if middleware is Middleware:
        _middlewares.push_back([kind, func(ctx: Dictionary) -> bool:
            return middleware.execute(ctx)])
    elif middleware is Callable:
        _middlewares.push_back([kind, middleware])
    else:
        push_error("Invalid middleware '%s'." % middleware.get_class())


func _on_request_received(req: HttpRequest, res: HttpResponse) -> void:
    var context := {
        "request": req,
        "response": res,
        "req": req,
        "res": res
    }

    for middleware in _middlewares:
        if middleware[KIND] == SYNC:
            if not middleware[CALLABLE].call(context):
                break
        else:
            if not (await middleware[CALLABLE].call(context)):
                break
