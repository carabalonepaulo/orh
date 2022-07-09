class_name TcpListener
extends RefCounted


signal client_connected(client: TcpClient)
signal client_disconnected(client: TcpClient)

var _listener: TCPServer
var _uuid: UUID
var _port: int
var _clients: Array


func _init(port: int):
    _listener = TCPServer.new()
    _uuid = UUID.new()
    _port = port
    _clients = []
    _clients.resize(4096)


func start() -> void:
    _listener.listen(_port)


func stop() -> void:
    for id in (_uuid.highest_index + 1):
        if _clients[id] == null:
            continue
        _clients[id].dispose()
    _clients.clear()
    _listener.stop()
    _uuid.dispose()


func poll() -> void:
    _try_accept()

    for id in (_uuid.highest_index + 1):
        if _clients[id] == null:
            continue
        _clients[id].poll()
        if not _clients[id].connected:
            _dispose_client(id)


func send(id: int, buff: PackedByteArray) -> void:
    if _clients[id] == null:
        return
    _clients[id].socket.put_data(buff)


func _try_accept() -> void:
    if not _listener.is_connection_available():
        return

    var client := TcpClient.new(_uuid.get_next(), _listener.take_connection())
    _clients[client.id] = client
    emit_signal("client_connected", client)


func _dispose_client(id: int) -> void:
    emit_signal("client_disconnected", _clients[id])
    _clients[id] = null
    _uuid.release(id)
