extends Node2D

onready var music = get_node("/root/Music")
onready var tween = Tween.new()

const STEP_TIME = 2

func _ready():
	music.play_background()
	music.end_screen()
	set_glitch_activation(0)
	
	$canvas/endtext.modulate.a = 0
	$canvas/endtext2.modulate.a = 0
	$canvas/endtext3.modulate.a = 0
	
	add_child(tween)
	
	yield($transition, "fade_complete")
	
	yield(transition_text($canvas/endtext, STEP_TIME), "completed")
	yield(transition_text($canvas/endtext2, STEP_TIME), "completed")
	yield(transition_text($canvas/endtext3, STEP_TIME, false), "completed")
	
	tween.interpolate_method(self, "set_glitch_activation", 0, 1.0, STEP_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func transition_text(text, step_time, fade_out=true):
	tween.interpolate_property(text, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), step_time, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	if fade_out:
		tween.interpolate_property(text, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), step_time, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
	yield(get_tree().create_timer(step_time / 2.0), "timeout")
	
func set_glitch_activation(activation):
	$canvas/glitch.material.set_shader_param("activation", activation)
