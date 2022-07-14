class_name Stream
extends Disposable


var length: int:
    get: return get_length()
var available_bytes: int:
    get: return get_available_bytes()


func write_8(value: int) -> void:
    pass


func write_u8(value: int) -> void:
    pass


func write_16(value: int) -> void:
    pass


func write_u16(value: int) -> void:
    pass


func write_32(value: int) -> void:
    pass


func write_u32(value: int) -> void:
    pass


func write_64(value: int) -> void:
    pass


func write_u64(value: int) -> void:
    pass


func write_float(value: float) -> void:
    pass


func write_double(value: float) -> void:
    pass


func write_bytes(value: PackedByteArray) -> void:
    pass


func write_ascii(value: String) -> void:
    var buff := value.to_ascii_buffer()
    write_u16(buff.size())
    write_bytes(buff)


func write_raw_ascii(value: String) -> void:
    write_bytes(value.to_ascii_buffer())


func write_utf8(value: String) -> void:
    var buff := value.to_utf8_buffer()
    write_u16(buff.size())
    write_bytes(buff)


func write_raw_utf8(value: String) -> void:
    write_bytes(value.to_utf8_buffer())


func write_bool(value: bool) -> void:
    write_8(OK if value else FAILED)


func read_8() -> int:
    return -1


func read_u8() -> int:
    return -1


func read_16() -> int:
    return -1


func read_u16() -> int:
    return -1


func read_32() -> int:
    return -1


func read_u32() -> int:
    return -1


func read_64() -> int:
    return -1


func read_u64() -> int:
    return -1


func read_float() -> float:
    return -1.0


func read_double() -> float:
    return -1.0


func read_bytes(_length: int) -> PackedByteArray:
    return PackedByteArray()


func read_ascii() -> String:
    return read_raw_ascii(read_u16())


func read_raw_ascii(_length: int) -> String:
    return read_bytes(_length).get_string_from_ascii()


func read_utf8() -> String:
    return read_raw_utf8(read_u16())


func read_raw_utf8(_length: int) -> String:
    return read_bytes(_length).get_string_from_utf8()


func read_bool() -> bool:
    return read_8() == OK


func get_available_bytes() -> int:
    return 0


func get_length() -> int:
    return 0


func pipe_to(stream: Stream, max_chunk_size := 512, total := -1) -> void:
    var available := get_available_bytes()
    var chunk_size: int
    var total_written := 0

    while available > 0:
        if total != -1 and total_written + max_chunk_size >= total:
            stream.write_bytes(read_bytes(total - total_written))
            break

        chunk_size = max_chunk_size if available >= max_chunk_size else available
        stream.write_bytes(read_bytes(chunk_size))
        total_written += chunk_size

        available = get_available_bytes()


func pipe_through(stream: Stream, max_chunk_size := 512, total := -1) -> Stream:
    pipe_to(stream, max_chunk_size, total)
    return stream
