extends Node2D

onready var hints = get_node("/root/Hints")

func _ready():
	yield($level, "loaded")
	hints.show_hint($level/ui, "resist")
