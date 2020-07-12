extends Node2D

const colors = preload("res://scripts/colors.gd")

onready var hints = get_node("/root/Hints")
onready var music = get_node("/root/Music")

export (String, FILE, "*.tscn") var next_level
export (Vector2) var boundary_topleft = Vector2(-1500, -1500)
export (Vector2) var boundary_size = Vector2(3000, 3000)

export (Rect2) var myhoney

signal loaded
signal eradicated
signal victorious

var is_loading = true
var session_complete = false

func _ready():
	music.play_background()
	add_to_group("level")
	create_boundary()
	$camera.set_boundary(boundary_topleft, boundary_size)
	yield($transition, "fade_complete")
	is_loading = false
	emit_signal("loaded")

const BOUNDARY_THICKNESS = 50

func create_boundary():
	var top = CollisionShape2D.new()
	$boundary.add_child(top)
	var left = CollisionShape2D.new()
	$boundary.add_child(left)
	var bottom = CollisionShape2D.new()
	$boundary.add_child(bottom)
	var right = CollisionShape2D.new()
	$boundary.add_child(right)
	
	top.shape = RectangleShape2D.new()
	left.shape = RectangleShape2D.new()
	bottom.shape = RectangleShape2D.new()
	right.shape = RectangleShape2D.new()
	
	top.shape.extents = Vector2(boundary_size.x / 2, BOUNDARY_THICKNESS)
	bottom.shape.extents = Vector2(boundary_size.x / 2, BOUNDARY_THICKNESS)
	left.shape.extents = Vector2(BOUNDARY_THICKNESS, boundary_size.y / 2)
	right.shape.extents = Vector2(BOUNDARY_THICKNESS, boundary_size.y / 2)
	
	top.global_position = boundary_topleft + Vector2(boundary_size.x / 2, 0)
	bottom.global_position = boundary_topleft + Vector2(boundary_size.x / 2, boundary_size.y)
	left.global_position = boundary_topleft + Vector2(0, boundary_size.y / 2)
	right.global_position = boundary_topleft + Vector2(boundary_size.x, boundary_size.y / 2)

func _process(delta):
	# Level hotkeys
	if not is_loading and Input.is_action_just_pressed("ui_reset"):
		reset_level()

func _physics_process(delta):
	check_end_state()

func check_end_state():
	if session_complete:
		return
	var tree = get_tree()

	# Check for player defeat
	var player_units = len(tree.get_nodes_in_group("units_" + str(colors.TYPE.PLAYER)))
	var player_bases = len(tree.get_nodes_in_group("bases_" + str(colors.TYPE.PLAYER)))
	if player_units == 0 and player_bases == 0:
		session_complete = true
		emit_signal("eradicated")
		$ui.show_bigtext("ERADICATED")
		yield($ui, "message_complete")
		reset_level()
	
	# Check for victory. We only care about bases.
	var enemy_bases = (len(tree.get_nodes_in_group("bases_" + str(colors.TYPE.ENEMY))) + 
	                   len(tree.get_nodes_in_group("bases_" + str(colors.TYPE.DEFECTOR))))
	if enemy_bases == 0:
		session_complete = true
		emit_signal("victorious")
		$ui.show_bigtext("VICTORIOUS")
		yield($ui, "message_complete")
		load_next_level()

func _on_ui_selection(start, end):
	var topleft = Vector2(min(start.x, end.x), min(start.y, end.y))
	var botright = Vector2(max(start.x, end.x), max(start.y, end.y))
	
	var units = get_tree().get_nodes_in_group("units_" + str(colors.TYPE.PLAYER))
	var bases = get_tree().get_nodes_in_group("bases_" + str(colors.TYPE.PLAYER))
	
	for unit in units+bases:
		var selected = (unit.global_position.x > topleft.x and unit.global_position.y > topleft.y and
		                unit.global_position.x < botright.x and unit.global_position.y < botright.y)
		unit.set_selected(selected)

func _on_ui_right_click(pos):
	move_selected(pos)

func _on_ui_right_click_drag(pos):
	move_selected(pos)

func move_selected(pos):
	for unit in get_tree().get_nodes_in_group("selected"):
		unit.go_to(pos)

func load_next_level():
	is_loading = true
	$transition.fade_out()
	yield($transition, "fade_complete")
	get_tree().change_scene(next_level)

func reset_level():
	is_loading = true
	$transition.fade_out()
	yield($transition, "fade_complete")
	get_tree().reload_current_scene()
