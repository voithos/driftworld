extends KinematicBody2D

const colors = preload("res://scripts/colors.gd")

export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL
export var selected = false setget set_selected

enum STATE {
	IDLE,
	MOVE,
}

var state = STATE.IDLE

# Steering
export (float) var MOVE_SPEED = 100 # Pixels/second
export (float) var WANDER_SPEED = 10 # Pixels/second
export (float) var ARRIVE_RADIUS = 75
export (float) var REPEL_RADIUS = 50
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
	$sprite.modulate = colors.COLORS[unit_type]
	$selection.hide()
	add_to_group("units")

const MAX_REPEL_COUNT = 10

func _physics_process(delta):
	check_arrival()
	
	if state == STATE.IDLE:
		SPEED = WANDER_SPEED
		steering.wander()
	elif state == STATE.MOVE:
		SPEED = MOVE_SPEED
		steering.arrive(current_target)
		steering.wander(0.05)

	# Maintain distance from other units.
	var count = 0
	for unit in detection.get_overlapping_bodies():
		if unit == self:
			continue
		steering.repel(unit.global_position, 0.1)
		count += 1
		if count > MAX_REPEL_COUNT:
			break
	apply_steer()

func apply_steer():
	var motion = steering.steer()
	current_motion = motion
	move_and_slide(motion)

func check_arrival():
	if state == STATE.MOVE:
		if global_position.distance_squared_to(current_target) < ARRIVAL_DIST_SQUARED:
			state = STATE.IDLE

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
	state = STATE.MOVE
	current_target = pos
