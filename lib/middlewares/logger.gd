class_name Logger
extends Middleware


func execute(ctx: Dictionary) -> bool:
    var now := Time.get_datetime_dict_from_system()
    var formatted := "[%s:%s:%s %s/%s/%s] %s %s" % [now["hour"], now["minute"],
        now["second"], now["month"], now["day"], now["year"], ctx.req.method,
        ctx.req.uri.path]
    print(formatted)
    return true
