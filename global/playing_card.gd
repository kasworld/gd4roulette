extends Node

const Symbols := ["♠","♥","♦","♣"]
const Numbers := ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]

var AllCards :Array
func _ready() -> void:
	var rtn := []
	for s in Symbols:
		for n in Numbers:
			rtn.append("%s%s" %[s,n])
	AllCards = rtn
