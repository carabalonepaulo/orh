class_name TcpClient
extends RefCounted


enum { READ_LINE, READ }

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
var _tasks: Queue


func _init(cid: int, socket: StreamPeerTCP):
    _id = cid
    _socket = socket
    _connected = true
    _buffer = StreamPeerBuffer.new()
    _tasks = Queue.new()


func poll() -> void:
    if not _connected:
        return

    _try_receive()
    _do_task()

    if _socket.poll() != OK or _socket.get_status() != StreamPeerTCP.STATUS_CONNECTED:
        dispose()


func read_line() -> Task:
    var task := Task.new()
    _tasks.enqueue([task, READ_LINE])
    return task


func read(bytes: int) -> Task:
    var task := Task.new()
    _tasks.enqueue([task, READ, bytes])
    return task


func send(buff: PackedByteArray) -> void:
    _socket.put_data(buff)


func send_string(text: String) -> void:
    send(text.to_ascii_buffer())


func dispose() -> void:
    _release_pending_tasks()
    _socket.disconnect_from_host()
    _connected = false


func _release_pending_tasks() -> void:
    var current_task = _tasks.dequeue()
    while current_task != null:
        match current_task[1]:
            READ_LINE:
                current_task[0].complete("")
            READ:
                current_task[0].complete(PackedByteArray())
        current_task = _tasks.dequeue()


func _try_receive() -> void:
    var bytes := _socket.get_available_bytes()
    var data := _socket.get_data(bytes)
    if data[0] != OK:
        dispose()
        return

    _buffer.seek(_write_cursor)
    _buffer.put_data(data[1])
    _write_cursor += data[1].size()


func _do_task() -> void:
    var current_task = _tasks.peek_first()
    if current_task == null:
        return

    match current_task[1]:
        READ_LINE:
            var i := _buffer.data_array.find(10, _read_cursor)
            if i == -1:
                return
            _buffer.seek(_read_cursor)
            current_task[0].complete(_buffer.get_string(i + 1 - _read_cursor))
            _read_cursor += i - _read_cursor + 1
            _tasks.dequeue()
        READ:
            if _read_cursor + current_task[2] > _write_cursor:
                return
            _buffer.seek(_read_cursor)
            current_task[0].complete(_buffer.get_data(current_task[2])[1])
            _read_cursor += current_task[2]
            _tasks.dequeue()

    if _read_cursor == _write_cursor:
        _buffer.clear()
        _read_cursor = 0
        _write_cursor = 0
