class_name ThreadPool
extends RefCounted


var _in: ConcurrentQueue
var _out: ConcurrentQueue
var _semaphore: Semaphore
var _quit: bool
var _workers: Array[Thread]


func _init(worker_count := -1):
    _in = ConcurrentQueue.new()
    _out = ConcurrentQueue.new()
    _semaphore = Semaphore.new()
    _quit = false
    _workers = _create_workers(worker_count)


## Start all workers.
func start() -> void:
    for worker in _workers:
        worker.start(_loop)


## Stop all workers.
func stop() -> void:
    _quit = true
    for i in _workers.size():
        _semaphore.post()
    for worker in _workers:
        worker.wait_to_finish()

    # Release all pending tasks.
    poll()


## Bring the results back to the main thread and release all tasks.
func poll() -> void:
    var value = _out.try_dequeue()
    while value != null:
        value[0].complete(value[1])
        value = _out.try_dequeue()


## Execute a function on another thread.
func run(callable: Callable, args: Array = []) -> Task:
    if callable.is_custom():
        push_error("Can't use a CallableCustom.")
        return

    var task := Task.new()
    _in.enqueue([
        callable.get_object(),
        callable.get_method(),
        args,
        task
    ])
    _semaphore.post()
    return task


func _create_workers(count := 1) -> Array[Thread]:
    var workers: Array[Thread] = []
    for i in (count if count > 0 else OS.get_processor_count()):
        workers.push_back(Thread.new())
    return workers


func _loop() -> void:
    while true:
        _semaphore.wait()
        if _quit:
            break

        var data = _in.try_dequeue()
        while data != null:
            _out.enqueue([
                data[3],
                data[0].callv(data[1], data[2])
            ])
            data = _in.try_dequeue()
