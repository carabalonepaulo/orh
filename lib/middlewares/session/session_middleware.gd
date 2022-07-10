class_name SessionMiddleware
extends Middleware


var _store: SessionStore


func _init():
    _store = SessionStore.new()


func load_store() -> void:
    _store.load_sessions()


func save_store() -> void:
    _store.save_sessions()


func execute(ctx: Dictionary) -> bool:
    var req: HttpRequest = ctx.req
    var res: HttpResponse = ctx.res

    if req.cookies.has("GDSESSID"):
        var id: String = req.cookies["GDSESSID"]
        if _store.has(id) && _store.is_valid(id):
            ctx.session = _store.regenerate(id)
        else:
            _store.destroy(id)
            ctx.session = _store.create()
    else:
        ctx.session = _store.create()

    var cookie := Cookie.new("GDSESSID", ctx.session.__id)
    cookie.path = "/"
    cookie.same_site = Cookie.SameSite.STRICT
    cookie.expires = Time.get_datetime_dict_from_unix_time(ctx.session.__expires_at)
    res.add_cookie(cookie)

    return true
