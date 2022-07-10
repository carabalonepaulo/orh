class_name SessionMiddleware
extends Middleware


const COOKIE_NAME := "GDSESSID"

var _store: SessionStore


func _init():
    _store = SessionStore.new()


func load_store() -> void:
    _store.load_sessions()


func save_store() -> void:
    _store.save_sessions()


func execute(ctx: Dictionary):
    var req: HttpRequest = ctx.req
    var res: HttpResponse = ctx.res

    ctx.session_store = _store

    ctx.init_session = (func():
        if ctx.has("session"):
            return

        if req.cookies.has(COOKIE_NAME):
            var id: String = req.cookies[COOKIE_NAME]
            if _store.has(id) && _store.is_valid(id):
                ctx.session = _store.regenerate(id)
            else:
                _store.destroy(id)
                ctx.session = _store.create()
        else:
            ctx.session = _store.create()

        var cookie := Cookie.new(COOKIE_NAME, ctx.session.__id)
        cookie.path = "/"
        cookie.same_site = Cookie.SameSite.STRICT
        cookie.expires = Time.get_datetime_dict_from_unix_time(ctx.session.__expires_at)
        res.add_cookie(cookie))

    ctx.destroy_session = (func():
        if not ctx.has("session"):
            return

        _store.destroy(ctx.session.__id)
        ctx.session = null
        ctx.res.remove_cookie(COOKIE_NAME))
