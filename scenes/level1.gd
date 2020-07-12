extends Node2D

onready var hints = get_node("/root/Hints")

func _ready():
	yield($level, "loaded")
	hints.show_hint($level/ui, "directive")
	yield($level/ui, "message_complete")
	yield(get_tree().create_timer(5.0), "timeout")
	hints.show_hint($level/ui, "safety")
