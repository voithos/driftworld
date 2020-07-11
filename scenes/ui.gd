extends Node2D

var start = Vector2()
var end = Vector2()
var is_dragging = false

signal selection
signal right_click
signal right_click_drag

var camera

func _ready():
	add_to_group("ui")
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
