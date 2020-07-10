extends KinematicBody2D

export var unit_base_color = Color(1, 1, 1)

export var selected = false setget set_selected

func _ready():
	$sprite.modulate = unit_base_color
	#$selection.modulate = unit_base_color
	$selection.hide()
	add_to_group("units")

func _on_unit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				toggle_select()

func toggle_select():
	set_selected(not selected)

func set_selected(value):
	if selected != value:
		selected = value
		if selected:
			add_to_group("selected")
		else:
			remove_from_group("selected")
		$selection.visible = selected
