class_name ConcurrentList
extends RefCounted


class ListNode extends RefCounted:
    var value
    var next: ListNode


    func _init(_value, _next: ListNode = null):
        value = _value
        next = _next


var is_empty: bool:
    get: return _count == 0

var _first: ListNode = null
var _last: ListNode = null
var _count: int = 0
var _mutex: Mutex


func _init():
    _mutex = Mutex.new()


func add(value) -> void:
    var node := ListNode.new(value)
    _mutex.lock()
    if _count == 0:
        _first = node
        _last = node
    else:
        var last := _last
        last.next = node
        _last = node
    _count += 1
    _mutex.unlock()


func remove(value) -> void:
    if _count == 0:
        return

    var nodes := _find_node(value)
    if nodes[0] == null:
        return

    _mutex.lock()
    if nodes[1] != null:
        nodes[1].next = nodes[0].next
        if nodes[0] == _last:
            _last = nodes[1]
    else:
        _first = _first.next

    _count -=1
    if _count == 0:
        _first = null
        _last = null
    _mutex.unlock()


func contains(value) -> bool:
    var node := _first
    var result := false

    _mutex.lock()
    while node != null:
        if node.value == value:
            result = true
            break
        if node.next == null:
            break
        node = node.next
    _mutex.unlock()
    return result


func clear() -> void:
    _mutex.lock()
    _first = null
    _last = null
    _mutex.unlock()


func for_each(callable: Callable) -> void:
    _mutex.lock()
    var node := _first
    while node != null:
        callable.call(node.value)
        if node.next == null:
            break
        node = node.next
    _mutex.unlock()


func to_array() -> Array:
    var array := []
    array.resize(_count)

    var i := 0
    var node := _first

    _mutex.lock()
    while node != null:
        array[i] = node.value
        i += 1
        if node.next == null:
            break
        node = node.next
    _mutex.unlock()

    return array


func _find_node(value) -> Array:
    if _count == 0:
        return [null, null]

    _mutex.lock()
    var last_node
    var current_node = _first

    while current_node != null:
        if current_node.value == value:
            return [current_node, last_node]

        last_node = current_node
        current_node = current_node.next

    _mutex.unlock()
    return [null, null]
