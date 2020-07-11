extends Node2D

const colors = preload("res://scripts/colors.gd")

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
