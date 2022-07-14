class_name MemoryStream
extends Stream


var _read_cursor: int
var _write_cursor: int
var _buffer: StreamPeerBuffer


func _init():
    _buffer = StreamPeerBuffer.new()


func write_8(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 1
    _buffer.put_8(value)


func write_u8(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 1
    _buffer.put_u8(value)


func write_16(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 2
    _buffer.put_16(value)


func write_u16(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 2
    _buffer.put_u16(value)


func write_32(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 4
    _buffer.put_32(value)


func write_u32(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 4
    _buffer.put_u32(value)


func write_64(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 8
    _buffer.put_64(value)


func write_u64(value: int) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 8
    _buffer.put_u64(value)


func write_float(value: float) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 4
    _buffer.put_float(value)


func write_double(value: float) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += 8
    _buffer.put_double(value)


func write_bytes(value: PackedByteArray) -> void:
    _buffer.seek(_write_cursor)
    _write_cursor += value.size()
    _buffer.put_data(value)


func read_8() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 1
    return _buffer.get_8()


func read_u8() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 1
    return _buffer.get_u8()


func read_16() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 2
    return _buffer.get_16()


func read_u16() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 2
    return _buffer.get_u16()


func read_32() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 4
    return _buffer.get_32()


func read_u32() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 4
    return _buffer.get_u32()


func read_64() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 8
    return _buffer.get_64()


func read_u64() -> int:
    _buffer.seek(_read_cursor)
    _read_cursor += 8
    return _buffer.get_u64()


func read_float() -> float:
    _buffer.seek(_read_cursor)
    _read_cursor += 4
    return _buffer.get_float()


func read_double() -> float:
    _buffer.seek(_read_cursor)
    _read_cursor += 8
    return _buffer.get_double()


func read_bytes(length: int) -> PackedByteArray:
    _buffer.seek(_read_cursor)
    _read_cursor += length
    var data := _buffer.get_data(length)
    return data[1]


func dispose() -> void:
    _buffer.clear()
