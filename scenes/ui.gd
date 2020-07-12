extends Node2D

var start = Vector2()
var end = Vector2()
var is_dragging = false

signal selection
signal right_click
signal right_click_drag
signal message_complete

var camera
var is_showing_message = false

onready var text_tween = Tween.new()

const MESSAGE_ANIM_TIME = 3.0
const MESSAGE_SHOW_TIME = 3.0

func _ready():
	add_child(text_tween)
	add_to_group("ui")
	$canvas/message.modulate.a = 0
	$canvas/bigtext.modulate.a = 0

	yield(get_tree(), "idle_frame")
	camera = get_tree().get_nodes_in_group("camera")[0]

func _process(delta):
	if Input.is_action_just_pressed("ui_mouse_left"):
		start = get_global_mouse_position()
		is_dragging = true

	if is_dragging:
		end = get_global_mouse_position()

	if Input.is_action_just_released("ui_mouse_left"):
		end = get_global_mouse_position()
		is_dragging = false
		emit_signal("selection", start, end)
		
	if not is_dragging:
		if Input.is_action_just_pressed("ui_mouse_right"):
			emit_signal("right_click", get_global_mouse_position())
		elif Input.is_action_pressed("ui_mouse_right"):
			emit_signal("right_click_drag", get_global_mouse_position())

	draw_select_rect()

func draw_select_rect():
	if not is_dragging:
		$canvas/select_rect.visible = false
		return

	$canvas/select_rect.visible = true
	$canvas/select_rect.rect_size = Vector2(abs(start.x-end.x), abs(start.y-end.y)) / camera.zoom
	
	var pos = Vector2()
	pos.x = min(start.x, end.x)
	pos.y = min(start.y, end.y)
	$canvas/select_rect.rect_position = (pos / camera.zoom) + get_viewport().size / 2 - (camera.global_position / camera.zoom)

func show_message(text):
	if is_showing_message:
		yield(self, "message_complete")
	is_showing_message = true
	$canvas/message.text = text
	text_tween.interpolate_property($canvas/message, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), MESSAGE_ANIM_TIME)
	text_tween.start()
	yield(text_tween, "tween_completed")
	yield(get_tree().create_timer(MESSAGE_SHOW_TIME), "timeout")
	text_tween.interpolate_property($canvas/message, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), MESSAGE_ANIM_TIME)
	text_tween.start()
	yield(text_tween, "tween_completed")
	is_showing_message = false
	emit_signal("message_complete")

func show_bigtext(text):
	if is_showing_message:
		yield(self, "message_complete")
	is_showing_message = true
	$canvas/bigtext.text = text
	text_tween.interpolate_property($canvas/bigtext, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), MESSAGE_ANIM_TIME)
	text_tween.start()
	yield(text_tween, "tween_completed")
	is_showing_message = false
	emit_signal("message_complete")
