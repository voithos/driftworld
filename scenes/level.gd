extends Node2D

const colors = preload("res://scripts/colors.gd")

export (String, FILE, "*.tscn") var next_level

signal eradicated
signal victorious

var session_complete = false

func _ready():
	assert(next_level)
	add_to_group("level")

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
		reset_level()
	
	# Check for victory. We only care about bases.
	var enemy_bases = len(tree.get_nodes_in_group("bases_" + str(colors.TYPE.ENEMY)))
	if enemy_bases == 0:
		session_complete = true
		emit_signal("victorious")
		load_next_level()

func _on_ui_selection(start, end):
	var topleft = Vector2(min(start.x, end.x), min(start.y, end.y))
	var botright = Vector2(max(start.x, end.x), max(start.y, end.y))
	
	for unit in get_tree().get_nodes_in_group("units_" + str(colors.TYPE.PLAYER)):
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
	$transition.fade_out()
	yield($transition, "fade_complete")
	get_tree().change_scene(next_level)

func reset_level():
	$transition.fade_out()
	yield($transition, "fade_complete")
	get_tree().reload_current_scene()
