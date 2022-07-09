class_name CloseConnection
extends Middleware


func execute(ctx: Dictionary) -> bool:
    ctx.res.headers["Connection"] = "close"
    return true
