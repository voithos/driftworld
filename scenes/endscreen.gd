extends Node2D

const STEP_TIME = 2

func _ready():
	$canvas/endtext.modulate.a = 0
	$canvas/endtext2.modulate.a = 0
	$canvas/endtext3.modulate.a = 0
	
	var tween = Tween.new()
	add_child(tween)
	
	yield($transition, "fade_complete")
	tween.interpolate_property($canvas/endtext, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), STEP_TIME, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	
	yield(get_tree().create_timer(STEP_TIME), "timeout")
	tween.interpolate_property($canvas/endtext2, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), STEP_TIME, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	
	yield(get_tree().create_timer(STEP_TIME), "timeout")
	tween.interpolate_property($canvas/endtext3, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), STEP_TIME, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
