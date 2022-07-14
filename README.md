# ORH

Asynchronous HTTP server fully written in GDScript.

## TODO

### Addons
- [ ] Router
- [ ] Static file server
- [ ] SMTP Client

### Framework
- [X] Cookies
- [X] Session
- [ ] SSL
- [ ] GZIP

## Exemple
```gdscript
extends Main


var app: App


func start() -> void:
    app = App.new()

    # session
    app.use(Session.new())

    # logger
    app.use(func(ctx: Dictionary):
        var now := Time.get_datetime_dict_from_system()
        var formatted := "[%02d:%02d:%02d] %s %s" % [now["hour"],
            now["minute"], now["second"], ctx.req.method, ctx.req.uri.path]
        print(formatted))

    # handle request
    app.use(func(ctx):
        ctx.init_session.call()
        ctx.res.body = MemoryStream.new()

        if ctx.session.has("last_path"):
            ctx.res.body.write_raw_ascii("Path: %s" % ctx.session.last_path)
        else:
            ctx.res.body.write_raw_ascii("Hello World!")

        ctx.res.send()
        ctx.session.last_path = ctx.req.uri.path)

    # detroy current session
    app.use(func(ctx):
        ctx.session.count = ctx.session.count + 1 if ctx.session.has("count") else 0
        if ctx.session.count == 2:
            ctx.destroy_session.call())

    app.start()


func stop() -> void:
    app.stop()


func update() -> void:
    app.update()

```
