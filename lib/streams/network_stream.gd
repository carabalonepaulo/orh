class_name NetworkStream
extends Stream


var _stream: StreamPeer


func _init(stream: StreamPeer):
    _stream = stream


func write_8(value: int) -> void:
    _stream.put_8(value)


func write_u8(value: int) -> void:
    _stream.put_u8(value)


func write_16(value: int) -> void:
    _stream.put_16(value)


func write_u16(value: int) -> void:
    _stream.put_u16(value)


func write_32(value: int) -> void:
    _stream.put_32(value)


func write_u32(value: int) -> void:
    _stream.put_u32(value)


func write_64(value: int) -> void:
    _stream.put_64(value)


func write_u64(value: int) -> void:
    _stream.put_u64(value)


func write_float(value: float) -> void:
    _stream.put_float(value)


func write_double(value: float) -> void:
    _stream.put_double(value)


func write_bytes(value: PackedByteArray) -> void:
    _stream.put_data(value)


func read_8() -> int:
    return _stream.get_8()


func read_u8() -> int:
    return _stream.get_u8()


func read_16() -> int:
    return _stream.get_16()


func read_u16() -> int:
    return _stream.get_u16()


func read_32() -> int:
    return _stream.get_32()


func read_u32() -> int:
    return _stream.get_u32()


func read_64() -> int:
    return _stream.get_64()


func read_u64() -> int:
    return _stream.get_u64()


func read_float() -> float:
    return _stream.get_float()


func read_double() -> float:
    return _stream.get_double()


func read_bytes(length: int) -> PackedByteArray:
    var data := _stream.get_data(length)
    return data[1]


func get_available_bytes() -> int:
    return _stream.get_available_bytes()
