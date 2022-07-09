# ORH

Asynchronous HTTP server fully written in GDScript.

## TODO

### Addons
- [ ] Router
- [ ] Static file server
- [ ] SMTP Client

### Framework
- [ ] Cookies
- [ ] Session
- [ ] SSL
- [ ] GZIP

### Core
- [X] Add timeout to read/write
- [ ] Rewrite `Content-Length` header parser
- [ ] Rewrite `path` parser

## Exemple
```gdscript
extends Main


var app: App


func start() -> void:
    app = App.new()

    app.use(func(ctx: Dictionary) -> bool:
        ctx._log_start = Time.get_ticks_msec()
        return true)
    app.use_async(func(ctx: Dictionary) -> bool:
        await create_timer(3).timeout
        return true)
    app.use(func(ctx: Dictionary) -> bool:
        var elapsed: float = Time.get_ticks_msec() - ctx._log_start
        var now := Time.get_datetime_dict_from_system()
        var formatted := "[%s:%s:%s %s/%s/%s] %s %s %dms" % [now["hour"],
            now["minute"], now["second"], now["month"], now["day"],
            now["year"], ctx.req.method, ctx.req.uri.path, elapsed]
        print(formatted)
        return true)

    app.start()


func stop() -> void:
    app.stop()


func update() -> void:
    app.update()

```
