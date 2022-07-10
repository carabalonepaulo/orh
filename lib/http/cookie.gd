class_name Cookie
extends RefCounted


const EXPIRES_REQUIRED_FIELDS := ["year", "month", "day", "weekday", "hour", "minute", "second"]
const SAME_SITE := ["Strict", "Lax", "None"]


var name: String
var value: String

var expires: Dictionary = {}
var max_age: int = -1
var domain: String = ""
var path: String = ""
var secure: bool = false
var http_only: bool = false
var same_site: String = ""


func _init(_name: String, _value: String):
    name = _name
    value = _value


func _to_string() -> String:
    var parts := PackedStringArray()
    parts.append("%s=%s" % [name, value.uri_encode()])

    if expires != null and _is_expires_valid():
        var day_name := _get_day_name(expires["weekday"])
        if day_name != "":
            parts.append("Expires=%s, %s %s %s %s:%s:%s GMT" % [day_name,
                    expires["day"], expires["month"], expires["year"],
                    expires["hour"], expires["minute"], expires["second"]])

    if max_age != -1:
        parts.append("Max-Age=" + str(max_age))

    if domain != "":
        parts.append("Domain=" + domain)

    if path != "":
        parts.append("Path=" + path)

    if secure:
        parts.append("Secure")

    if http_only:
        parts.append("HttpOnly")

    if same_site != "" and _is_same_site_valid():
        parts.append("SameSite=" + same_site)


    return "; ".join(parts)


func _is_expires_valid() -> bool:
    for field in EXPIRES_REQUIRED_FIELDS:
        if not expires.has(field):
            return false
    return true


func _is_same_site_valid() -> bool:
    return SAME_SITE.has(same_site)


func _get_day_name(weekday: int) -> String:
    match expires["weekday"]:
        Time.WEEKDAY_SUNDAY:
            return "Sun"
        Time.WEEKDAY_MONDAY:
            return "Mon"
        Time.WEEKDAY_TUESDAY:
            return "Tue"
        Time.WEEKDAY_WEDNESDAY:
            return "Wed"
        Time.WEEKDAY_THURSDAY:
            return "Thu"
        Time.WEEKDAY_FRIDAY:
            return "Fri"
        Time.WEEKDAY_SATURDAY:
            return "Sat"
        _:
            return ""
