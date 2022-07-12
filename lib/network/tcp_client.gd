class_name TcpClient
extends RefCounted


const LF := 10
const EMPTY_STRING := ""

var is_connected: bool:
    get: return _socket.poll() == OK and _socket.get_status() == StreamPeerTCP.STATUS_CONNECTED
var has_pending_data: bool:
    get: return _socket.get_available_bytes() > 0

var _socket: StreamPeerTCP


func _init(socket: StreamPeerTCP):
    _socket = socket


func send(buff: PackedByteArray) -> void:
    _socket.put_data(buff)


func send_string(text: String) -> void:
    send(text.to_ascii_buffer())


func read(length: int) -> Array:
    return _socket.get_data(length)


func read_line() -> String:
    var buff := PackedByteArray()

    while true:
#        print(_socket.get_status())
        if _socket.poll() != OK or _socket.get_status() != StreamPeerTCP.STATUS_CONNECTED:
            print("disconnected")
            break

        var available := _socket.get_available_bytes()
        while available > 0:
            var byte := _socket.get_8()
            buff.append(byte)
            available -= 1

            if byte == LF:
                return buff.get_string_from_ascii()

    return EMPTY_STRING


func disconnect_from_host() -> void:
    _socket.disconnect_from_host()
