class_name FileStream
extends Stream


var file_path: String:
    get: return _file_path

var _read_cursor: int
var _write_cursor: int
var _file: File
var _file_path: String


func _init(path := ""):
    _file = File.new()

    if path == "":
        _file_path = _get_temp_file_path()
        if _file.open(_file_path, File.WRITE_READ) != OK:
            push_error("Failed to open temp file.")
    else:
        _file_path = path
        if _file.open(_file_path, File.READ_WRITE) != OK:
            push_error("Failed to open file.")
        _write_cursor = _file.get_length()


func write_8(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 1
    _file.store_8(value)


func write_u8(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 1
    _file.store_8(value)


func write_16(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 2
    _file.store_16(value)


func write_u16(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 2
    _file.store_16(value)


func write_32(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 4
    _file.store_32(value)


func write_u32(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 4
    _file.store_32(value)


func write_64(value: int) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 8
    _file.store_64(value)


func write_u64(value: int) -> void:
    var buff := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
    buff.encode_u64(0, value)
    _file.seek(_write_cursor)
    _write_cursor += 8
    _file.store_buffer(buff)


func write_float(value: float) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 4
    _file.store_float(value)


func write_double(value: float) -> void:
    _file.seek(_write_cursor)
    _write_cursor += 8
    _file.store_double(value)


func write_bytes(value: PackedByteArray) -> void:
    _file.store_buffer(value)
    _file.flush()


func read_8() -> int:
    _file.seek(_read_cursor)
    _read_cursor += 1
    return _file.get_8()


func read_u8() -> int:
    _file.seek(_read_cursor)
    return read_bytes(1).decode_u8(0)


func read_16() -> int:
    _file.seek(_read_cursor)
    _read_cursor += 2
    return _file.get_16()


func read_u16() -> int:
    _file.seek(_read_cursor)
    return read_bytes(2).decode_u16(0)


func read_32() -> int:
    _file.seek(_read_cursor)
    return _file.get_32()


func read_u32() -> int:
    _file.seek(_read_cursor)
    return read_bytes(4).decode_u32(0)


func read_64() -> int:
    _file.seek(_read_cursor)
    _read_cursor += 8
    return _file.get_64()


func read_u64() -> int:
    _file.seek(_read_cursor)
    return read_bytes(8).decode_u64(0)


func read_float() -> float:
    _file.seek(_read_cursor)
    _read_cursor += 4
    return _file.get_float()


func read_double() -> float:
    _file.seek(_read_cursor)
    _read_cursor += 4
    return _file.get_double()


func read_bytes(_length: int) -> PackedByteArray:
    _file.seek(_read_cursor)
    _read_cursor += _length
    return _file.get_buffer(_length)


func get_available_bytes() -> int:
    return _file.get_length() - _read_cursor


func get_length() -> int:
    return _file.get_length()


func dispose() -> void:
    _file.close()


func flush() -> void:
    _file.flush()


func _get_temp_dir() -> String:
    match OS.get_name():
        "Windows":
            return OS.get_environment("Temp").plus_file("orh")
        "Linux":
            return "/tmp".plus_file("orh")
        _:
            return "res://temp".plus_file("orh")


func _get_temp_file_path() -> String:
    var temp_path := _get_temp_dir()
    _ensure_temp_dir_exists(temp_path)
    return temp_path.plus_file(UUID.v4() + ".temp")


func _ensure_temp_dir_exists(dir_path: String) -> void:
    var dir := Directory.new()
    if not dir.dir_exists(dir_path):
        dir.make_dir(dir_path)
