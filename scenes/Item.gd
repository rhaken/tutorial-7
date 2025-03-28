extends Node

class_name Item

var nama_item: String

func _init(item: String):
	self.nama_item = item

func use():
	print("Using " + name)

func hilang():
	pass
