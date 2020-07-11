extends KinematicBody2D

export var unit_base_color = Color(1, 1, 1)
export var selected = false setget set_selected

const STATE_IDLE = "idle"
const STATE_MOVE = "move"

var state = STATE_IDLE

# Steering
export (float) var MOVE_SPEED = 100 # Pixels/second
export (float) var WANDER_SPEED = 10 # Pixels/second
export (float) var ARRIVE_RADIUS = 75
export (float) var REPEL_RADIUS = 100
export (float) var STEERING_FORCE = 10
export (float) var MASS = 2
export (float) var WANDER_DISTANCE = 100
export (float) var WANDER_RADIUS = 200
export (float) var WANDER_ANGLE_CHANGE = .5 # Radians
var SPEED = WANDER_SPEED

const ARRIVAL_DIST_SQUARED = 15

onready var steering = $steering
onready var detection = $detection

var current_motion = Vector2()
var current_target = Vector2()

func _ready():
	$sprite.modulate = unit_base_color
	$selection.hide()
	add_to_group("units")

func _physics_process(delta):
	check_arrival()
	
	if state == STATE_IDLE:
		SPEED = WANDER_SPEED
		steering.wander()
	elif state == STATE_MOVE:
		SPEED = MOVE_SPEED
		steering.arrive(current_target)
		steering.wander(0.05)

	# Maintain distance from other units.
	for unit in detection.get_overlapping_bodies():
		if unit == self:
			continue
		steering.repel(unit.global_position, 0.2)
	apply_steer()

func apply_steer():
	var motion = steering.steer()
	current_motion = motion
	move_and_slide(motion)

func check_arrival():
	if state == STATE_MOVE:
		if global_position.distance_squared_to(current_target) < ARRIVAL_DIST_SQUARED:
			state = STATE_IDLE

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

func go_to(pos):
	state = STATE_MOVE
	current_target = pos
