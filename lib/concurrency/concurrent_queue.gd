class_name ConcurrentQueue
extends RefCounted


const VALUE = 0
const NEXT = 1

## Returns the number of elements in the queue.
var size: int:
    get: return _size

## Returns true if the array is empty.
var is_empty: bool:
    get: return _size == 0

var _first := [null, null]
var _last := _first
var _size := 0
var _mutex: Mutex


func _init():
    _mutex = Mutex.new()


## Appends an element at the end of the queue.
func enqueue(value) -> void:
    var node := [value, null]
    _mutex.lock()
    if _size == 0:
        _first = node
    else:
        _last[NEXT] = node
    _last = node
    _size += 1
    _mutex.unlock()


## Removes and returns the first element of the queue.
## Returns [code]null[/code] if the queue is empty.
func try_dequeue():
    var value
    _mutex.lock()
    if _size > 0:
        value = _first[VALUE]
        if _size == 1:
            _first = [null, null]
            _last = [null, null]
        else:
            _first = _first[NEXT]
        _size -= 1
    _mutex.unlock()
    return value


## Clears the queue.
func clear() -> void:
    _mutex.lock()
    _first = [null, null]
    _last = [null, null]
    _size = 0
    _mutex.unlock()


## Returns the first element of queue, but does not remove it from the queue.
func peek_first():
    return _first[VALUE]


## Returns the last element of queue, but does not remove it from the queue.
func peek_last():
    return _last[NEXT]
