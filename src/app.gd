extends Main


var app: App


func start() -> void:
    app = App.new()

    app.use(func(ctx: Dictionary) -> bool:
        ctx["_log_start"] = Time.get_ticks_usec()
        return true)
    app.use(get_router())
    app.use(func(ctx: Dictionary) -> bool:
        var elapsed: float = Time.get_ticks_usec() - ctx["_log_start"]
        var now := Time.get_datetime_dict_from_system()
        var formatted := "[%s:%s:%s %s/%s/%s] %s %s %dus" % [now["hour"],
            now["minute"], now["second"], now["month"], now["day"],
            now["year"], ctx.req.method, ctx.req.uri.path, elapsed]
        print(formatted)
        return true)

    app.start()


func stop() -> void:
    app.stop()


func update() -> void:
    app.update()


func get_router() -> Router:
    var router := Router.new()

    router.use("GET", "/", func(ctx: Dictionary):
        ctx.res.send(200, "from index"))

    router.use("GET", "/:name", func(ctx: Dictionary):
        ctx.res.send(200, "nominho: %s" % ctx.params.name))

    return router
