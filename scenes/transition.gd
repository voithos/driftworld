extends CanvasLayer

export (bool) var start_immediately = true
onready var fade = $fade
onready var tween = Tween.new()

const DURATION = 2.0

signal fade_complete

func _ready():
	add_child(tween)
	tween.connect("tween_completed", self, "_on_tween_complete") 

	set_cutoff(0)
	fade_in()

func fade_in():
	tween.interpolate_method(self, "set_cutoff", 0.0, 1.0, DURATION)
	tween.start()

func fade_out():
	tween.interpolate_method(self, "set_cutoff", 1.0, 0.0, DURATION)
	tween.start()
	
func set_cutoff(val):
	fade.material.set_shader_param("cutoff", val)

func _on_tween_complete(object, key):
	emit_signal("fade_complete")
