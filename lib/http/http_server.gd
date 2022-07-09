class_name HttpServer
extends RefCounted


signal request_received(req: HttpRequest, res: HttpResponse)

const MAX_LINE := 8192
const MAX_BODY := 8_388_608
const CRLF := "\r\n"
const HEADER_LIMIT := 10_000

var _listener: TcpListener
var _running: bool


func _init(port := 8080):
    _listener = TcpListener.new(port)
    _listener.connect("client_connected", _on_client_connected)


func start() -> void:
    _running = true
    _listener.start()


func stop() -> void:
    _running = false
    _listener.stop()


func poll() -> void:
    _listener.poll()


func _on_client_connected(client: TcpClient) -> void:
    while _running:
        if not await _handle_request(client):
            break


func _handle_request(client: TcpClient) -> bool:
    var request := HttpRequest.new()
    var response := HttpResponse.new(client)
    var line: String
    var parts: Array

    # https://tools.ietf.org/html/rfc7230#section-3.5
    for i in 2:
        line = await client.read_line().completed
        if line == "":
            client.dispose()
            return false
        elif line != CRLF:
            break
        elif line.length() > MAX_LINE:
            response.send(413)
            return false

    # GET /path HTTP/1.1
    parts = line.replace(CRLF, "").split(" ")

    if parts.size() != 3:
        response.send(400)
        return true

    request.method = parts[0]
    request.uri = URI.new(parts[1])
    request.protocol = parts[2].replace("HTTP/", "")

    # Headers
    var count := 0
    while true:
        line = await client.read_line().completed
        if line == CRLF:
            break
        elif line.length() > MAX_LINE:
            response.send(413)
            return false
        elif line == "":
            client.dispose()
            return false

        parts = line.split(": ")
        request.headers[parts[0]] = parts[1].replace(CRLF, "")
        count += 1

        if count > HEADER_LIMIT:
            response.send(400)
            client.dispose()
            return false

    if request.method == "POST":
        if request.headers.has("Expect"):
            response.send_status(100)
        else:
            response.send_status(417)

    # Body
    if request.headers.has("Content-Length"):
        var content_length: int = request.headers["Content-Length"].to_int()
        # TODO: Bad Request. Invalid Content-Length.
        if content_length > MAX_BODY:
            response.send(413)
            return false

        request.body = (await client.read(content_length).completed).get_string_from_ascii()
        if request.body.length() != content_length:
            response.send(400)
            return true

    elif _has_chunked_encoding(request):
        var size_or_data := 0
        var bytes_to_read := 0

        while true:
            if size_or_data % 2 == 0:
                line = await client.read_line().completed
                bytes_to_read = line.replace(CRLF, "").hex_to_int()
            else:
                if bytes_to_read == 0:
                    break

                var chunk: PackedByteArray = await client.read(bytes_to_read).completed
                request.body += chunk.get_string_from_ascii() # TODO: slow af

                var separator: String = (await client.read(2).completed).get_string_from_ascii()
                if separator != CRLF:
                    response.send(400)
                    return true

            size_or_data += 1
    elif request.method == "POST":
        response.send(411)
        return true

    emit_signal("request_received", request, response)

    if request.protocol == "1.1" and request.headers.has("Connection") and\
            request.headers["Connection"] == "close":
        client.dispose()
        return false

    return true


func _has_chunked_encoding(request: HttpRequest) -> bool:
    if request.headers.has("Transfer-Encoding"):
        if request.headers["Transfer-Encoding"].find("chunked") != -1:
            return request.method == "POST"
    return false
