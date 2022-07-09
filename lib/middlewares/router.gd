class_name Router
extends Middleware


var _routes: Dictionary


func _init():
    _routes = {
        "GET": {},
        "POST": {},
        "HEAD": {},
        "PUT": {},
        "DELETE": {},
        "PATCH": {},
        "OPTIONS": {},
        "CONNECT": {},
        "TRACE": {},
    }


func use(method: String, path: String, callable: Callable) -> void:
    if not _routes.has(method):
        push_error("Invalid HTTP method '%s'." % method)
        return

    var regex := RegEx.new()
    regex.compile(path)
    _routes[method][regex] = callable


func execute(ctx: Dictionary) -> bool:
    var path: String = ctx.request.uri.path
    var method: String = ctx.request.method
    var list: Dictionary = _routes[ctx.request.method]

    for regex in list.keys():
        var result := regex.search(path) as RegExMatch
        if result == null or result.strings.size() == 0:
            continue
        list[regex].call(ctx)

    return false
