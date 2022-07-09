extends App


func create_router() -> Router:
    var router := Router.new()

    router.use("GET", "/", func(ctx: Dictionary):
        ctx.res.send(200, "from index"))

    router.use("GET", "/:name", func(ctx: Dictionary):
        ctx.res.send(200, "nominho: %s" % ctx.params.name))

    return router


func get_middlewares() -> Array:
    return [
        Logger.new(),
        create_router()
    ]
