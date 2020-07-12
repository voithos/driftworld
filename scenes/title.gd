extends Node2D

var is_loading = false

const TITLE_EMERGE_TIME = 5
const CLICK_EMERGE_TIME = 2

func _ready():
	$canvas/titletext.modulate.a = 0
	$canvas/click.modulate.a = 0
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($canvas/titletext, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), TITLE_EMERGE_TIME, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	
	tween.interpolate_property($canvas/click, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), CLICK_EMERGE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")

func _process(delta):
	if Input.is_action_just_pressed("ui_mouse_left"):
		load_next_level()

func load_next_level():
	if is_loading:
		return
	is_loading = true
	$transition.fade_out()
	yield($transition, "fade_complete")
	get_tree().change_scene("res://scenes/level1.tscn")
