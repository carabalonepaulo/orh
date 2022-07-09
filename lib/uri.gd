class_name URI
extends RefCounted


var scheme
var authority
var path
var query
var fragment


func _init(text: String):
    var regex := RegEx.new()
    regex.compile("^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?")

    var result := regex.search(text)
    scheme = result.strings[2]
    authority = result.strings[4]
    path = result.strings[5]
    query = result.strings[7]
    fragment = result.strings[9]
