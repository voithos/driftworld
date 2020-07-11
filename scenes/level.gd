extends Node2D



func _on_ui_selection(start, end):
	var topleft = Vector2(min(start.x, end.x), min(start.y, end.y))
	var botright = Vector2(max(start.x, end.x), max(start.y, end.y))
	
	for unit in get_tree().get_nodes_in_group("units"):
		var selected = unit.position > topleft and unit.position < botright
		unit.set_selected(selected)
