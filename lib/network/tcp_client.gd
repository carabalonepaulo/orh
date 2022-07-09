class_name TcpClient
extends RefCounted


class Event extends RefCounted:
    var task: Task

    func _init(_task: Task):
        task = _task

    func handle(buffer: StreamPeerBuffer, read_cursor: int, write_cursor: int) -> int:
        return -1


class ReadEvent extends Event:
    var length: int

    func _init(_task: Task, _length: int):
        super(_task)
        length = _length

    func handle(buffer: StreamPeerBuffer, read_cursor: int, write_cursor: int) -> int:
        if read_cursor + length > write_cursor:
            return - 1
        buffer.seek(read_cursor)
        task.complete(buffer.get_data(length)[1])
        read_cursor += length
        return length


class ReadLineEvent extends Event:
    func handle(buffer: StreamPeerBuffer, read_cursor: int, write_cursor: int) -> int:
        var i := buffer.data_array.find(10, read_cursor)
        if i == -1:
            return -1

        var length := i + 1 - read_cursor
        buffer.seek(read_cursor)
        task.complete(buffer.get_string(length))
        return length


var id: int:
    get: return _id
var connected: bool:
    get: return _connected

var _id: int
var _socket: StreamPeerTCP
var _connected: bool
var _buffer: StreamPeerBuffer
var _read_cursor: int
var _write_cursor: int
var _events: Queue


func _init(cid: int, socket: StreamPeerTCP):
    _id = cid
    _socket = socket
    _connected = true
    _buffer = StreamPeerBuffer.new()
    _events = Queue.new()


func poll() -> void:
    if not _connected:
        return

    _try_receive()
    _try_handle_event()

    if _socket.poll() != OK or _socket.get_status() != StreamPeerTCP.STATUS_CONNECTED:
        dispose()


func read_line() -> Task:
    var task := Task.new()
    _events.enqueue(ReadLineEvent.new(task))
    return task


func read(length: int) -> Task:
    var task := Task.new()
    _events.enqueue(ReadEvent.new(task, length))
    return task


func send(buff: PackedByteArray) -> void:
    _socket.put_data(buff)


func send_string(text: String) -> void:
    send(text.to_ascii_buffer())


func dispose() -> void:
    _release_pending_events()
    _socket.disconnect_from_host()
    _connected = false


func _release_pending_events() -> void:
    var event: Event = _events.dequeue()
    while event != null:
        if event is ReadLineEvent:
            event.task.complete("")
        else:
            event.task.complete(PackedByteArray())
        event = _events.dequeue()


func _try_receive() -> void:
    var bytes := _socket.get_available_bytes()
    var data := _socket.get_data(bytes)
    if data[0] != OK:
        dispose()
        return

    _buffer.seek(_write_cursor)
    _buffer.put_data(data[1])
    _write_cursor += data[1].size()


func _try_handle_event() -> void:
    var event: Event = _events.peek_first()
    if event == null:
        return

    var length := event.handle(_buffer, _read_cursor, _write_cursor)
    if length != -1:
        _read_cursor += length
        _events.dequeue()

    if _read_cursor == _write_cursor:
        _buffer.clear()
        _read_cursor = 0
        _write_cursor = 0
