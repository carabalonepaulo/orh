class_name SessionStore
extends RefCounted


const SESSIONS_PATH := "res://lib/middlewares/session/sessions.bin"
const DEFAULT_LIFE_SPAN := 15 * 60 * 60 * 24 # 15 days

var _sessions: Dictionary
var _mutex: Mutex


func _init():
    _sessions = {}
    _mutex = Mutex.new()


func get_all() -> Array[Dictionary]:
    return _sessions.values()


func has(id: String) -> bool:
    return _sessions.has(id)


func get_session(id: String) -> Dictionary:
    return _sessions[id]


func regenerate(id: String) -> Dictionary:
    var session := get_session(id)
    destroy(id)

    var new_id := UUID.v4()
    session.__id = new_id
    session.__expires_at = Time.get_unix_time_from_system() + DEFAULT_LIFE_SPAN

    _mutex.lock()
    _sessions[new_id] = session
    _mutex.unlock()

    return session


func create() -> Dictionary:
    var id := UUID.v4()
    var session := {
        "__id": id,
        "__expires_at": Time.get_unix_time_from_system() + DEFAULT_LIFE_SPAN
    }
    _mutex.lock()
    _sessions[id] = session
    _mutex.unlock()
    return session


func destroy(id: String) -> void:
    _mutex.lock()
    _sessions.erase(id)
    _mutex.unlock()


func is_valid(id: String) -> bool:
    var session: Dictionary = _sessions[id]
    return session.__expires_at > Time.get_unix_time_from_system()


func clear() -> void:
    _mutex.lock()
    _sessions.clear()
    _mutex.unlock()


func save_sessions() -> void:
    var file := File.new()
    file.open(SESSIONS_PATH, File.WRITE)
    var buff := var2bytes(_sessions)
    file.store_64(buff.size())
    file.store_buffer(buff)
    file.close()


func load_sessions() -> void:
    var file := File.new()
    if file.file_exists(SESSIONS_PATH):
        file.open(SESSIONS_PATH, File.READ)
        var size := file.get_64()
        _sessions = bytes2var(file.get_buffer(size))
    else:
        _sessions = {}
