extends Main


var app: App


func start() -> void:
    app = App.new()

    # Session
    var session_middleware := SessionMiddleware.new()
    app.connect("started", session_middleware.load_store)
    app.connect("stopped", session_middleware.save_store)
    app.use(session_middleware)

    app.use(func(ctx: Dictionary) -> bool:
        ctx._log_start = Time.get_ticks_msec()
        return true)
    app.use(func(ctx: Dictionary) -> bool:
        ctx.res.send(200, "Hello World!")
        return true)
    app.use(func(ctx: Dictionary) -> bool:
        var elapsed: float = Time.get_ticks_msec() - ctx._log_start
        var now := Time.get_datetime_dict_from_system()
        var formatted := "[%02d:%02d:%02d] %s %s %dms" % [now["hour"],
            now["minute"], now["second"], ctx.req.method,
            ctx.req.uri.path, elapsed]
        print(formatted)
        return true)

    app.start()


func stop() -> void:
    app.stop()


func update() -> void:
    app.update()
