extends Node2D

var start = Vector2()
var end = Vector2()
var is_dragging = false
var mousepos = Vector2()
var mousestart = Vector2()
var mouseend = Vector2()

var camera

func _ready():
	yield(get_tree(), "idle_frame")
	camera = get_tree().get_nodes_in_group("camera")[0]

func _process(delta):
	if Input.is_action_just_pressed("ui_mouse_left"):
		start = get_global_mouse_position()
		mousestart = mousepos
		is_dragging = true

	if is_dragging:
		end = get_global_mouse_position()
		mouseend = mousepos

	if Input.is_action_just_released("ui_mouse_left"):
		end = get_global_mouse_position()
		mouseend = mousepos
		is_dragging = false

	draw_select_rect()		

func draw_select_rect():
	if not is_dragging:
		$canvas/select_rect.visible = false
		return

	$canvas/select_rect.visible = true
	$canvas/select_rect.rect_size = Vector2(abs(start.x-end.x), abs(start.y-end.y))
	
	var pos = Vector2()
	pos.x = min(start.x, end.x)
	pos.y = min(start.y, end.y)
	$canvas/select_rect.rect_position = pos + get_viewport().size / 2 - camera.position

func _input(event):
	if event is InputEventMouse:
		mousepos = event.position
