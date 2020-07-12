extends Node

# Common steering manager for entity nodes. Used to queue up steering operations and
# steer all at once.

onready var steering = get_node("/root/Steering")

# Common state.
var entity
var current_steering = Vector2(0, 0)
var wander_angle = 0

func _ready():
	entity = get_parent()
	wander_angle = randf() * PI * 2

func seek(target, weight=1):
	current_steering += steering.seek(
		entity.global_position, target,
		entity.current_motion, entity.SPEED) * weight

func flee(target, weight=1):
	self.current_steering += steering.flee(
		entity.global_position, target,
		entity.current_motion, entity.SPEED)

func arrive(target, weight=1):
	current_steering += steering.arrive(
		entity.global_position, target, entity.ARRIVE_RADIUS,
		entity.current_motion, entity.SPEED) * weight

func repel(target, weight=1):
	current_steering += steering.repel(
		entity.global_position, target, entity.REPEL_RADIUS,
		entity.current_motion, entity.SPEED) * weight

func wander(weight=1):
	current_steering += steering.wander(
		entity.global_position, entity.WANDER_DISTANCE, entity.WANDER_RADIUS,
		wander_angle, entity.current_motion) * weight
	wander_angle = steering.next_wander_angle(wander_angle, entity.WANDER_ANGLE_CHANGE)

func steer():
	var motion = steering.steer(current_steering, entity.current_motion, entity.SPEED, entity.STEERING_FORCE, entity.MASS)
	current_steering.x = 0
	current_steering.y = 0
	return motion
