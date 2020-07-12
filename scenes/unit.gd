extends KinematicBody2D

const colors = preload("res://scripts/colors.gd")

var utype = "unit"

export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL
export var selected = false setget set_selected

export (int) var starting_hp = 3
var hp = starting_hp

export (int) var attack_power = 1
export (float) var attack_timeout = 2.0
export (float) var laser_timeout = 0.25

# Morale stuff
export (float) var morale = 100.0
const MAX_MORALE = 100.0
const MORALE_CONVERSION_THRESHOLD = 15.0

const MORALE_BASE_GAIN = 5.0

const MORALE_ATTRITION = -2.0
const MORALE_GROUP_GAIN = 1.5

const MORALE_MIN_FRIENDLIES = 10
const MORALE_LONELINESS_LOSS = -5.0

const MORALE_OUTNUMBERED_LOSS = -10.0

const MORALE_TICK_MULTIPLIER = 1.0
const MIN_DELTA_PER_MORALE = 0.5
var delta_since_last_morale = MIN_DELTA_PER_MORALE

# ------

onready var attack_timer = Timer.new()
var can_attack = true
onready var laser_timer = Timer.new()
var is_attacking = false
var attacking_unit = null
var attacking_unit_radius = 0

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
onready var attack_range = $attack_range

var current_motion = Vector2()
var current_target = Vector2()

onready var laser = $laser

func _ready():
	$selection.hide()
	$laser.hide()
	add_to_group("units")
	become_type(unit_type)
	
	add_child(attack_timer)
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	attack_timer.set_wait_time(attack_timeout)
	attack_timer.set_one_shot(true)
	
	add_child(laser_timer)
	laser_timer.connect("timeout", self, "_on_laser_timer_timeout")
	laser_timer.set_wait_time(laser_timeout)
	laser_timer.set_one_shot(true)

const MAX_REPEL_COUNT = 10

func _process(delta):
	update_laser()

func _physics_process(delta):
	check_arrival()
	
	if state == STATE.IDLE:
		SPEED = WANDER_SPEED
		steering.wander()
	elif state == STATE.MOVE:
		SPEED = MOVE_SPEED
		steering.arrive(current_target)
		steering.wander(0.05)

	var other_units = attack_range.get_overlapping_bodies()
	maintain_distance(other_units)
	attack_enemies(other_units)
	update_morale(delta)

	apply_steer()

func update_morale(delta):
	if unit_type != colors.TYPE.PLAYER:
		return
		
	delta_since_last_morale += delta
	if delta_since_last_morale < MIN_DELTA_PER_MORALE:
		return
	delta_since_last_morale = 0.0
	
	var bodies = detection.get_overlapping_bodies()
	
	var enemies = 0
	var friendlies = 0
	var friendly_bases = 0
	
	for body in bodies:
		if body.utype == "base":
			if body.unit_type == unit_type:
				friendly_bases += 1
		else:
			if body.unit_type == unit_type:
				friendlies += 1
			else:
				enemies += 1

	# Case 1: Proximity to a friendly base. If so, then all other morale drains are void.
	var change = MORALE_BASE_GAIN
	if friendly_bases == 0:
		# Otherwise, there is drain. Maybe a lot of it.
		change = MORALE_ATTRITION

		# Case 2: Sufficient nearby friendlies
		if friendlies < MORALE_MIN_FRIENDLIES:
			change += MORALE_LONELINESS_LOSS * (1.0 - friendlies / float(MORALE_MIN_FRIENDLIES))
		else:
			change += MORALE_GROUP_GAIN
		
		# Case 3: Not outnumbered
		if friendlies < enemies:
			change += MORALE_OUTNUMBERED_LOSS * (1.0 - friendlies / float(enemies))

	morale = min(morale + change, MAX_MORALE)
	if morale <= 0:
		defect()

func defect():
	hp = starting_hp
	remove_from_group("units_" + str(unit_type))
	become_type(colors.TYPE.DEFECTOR)
	set_selected(false)
	# TODO: Fix motion jankiness
	#go_idle()

func become_type(new_type):
	unit_type = new_type
	add_to_group("units_" + str(unit_type))
	$sprite.modulate = colors.COLORS[unit_type]
	$laser.modulate = colors.COLORS[unit_type].lightened(0.4)
	
	detection.monitoring = unit_type == colors.TYPE.PLAYER

func maintain_distance(other_units):
	# Maintain distance from other units.
	# Keep a count so as to not go overboard and slow down the game.
	var count = 0
	for unit in other_units:
		if unit == self:
			continue
		steering.repel(unit.global_position, 0.1)
		count += 1
		if count > MAX_REPEL_COUNT:
			break

func apply_steer():
	var motion = steering.steer()
	current_motion = motion
	move_and_slide(motion)

func check_arrival():
	if state == STATE.MOVE:
		if global_position.distance_squared_to(current_target) < ARRIVAL_DIST_SQUARED:
			go_idle()

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
	
func go_idle():
	state = STATE.IDLE
	current_target = null

func attack_enemies(other_units):
	if not can_attack:
		return

	var closest = null
	var closest_dist = null
	for unit in other_units:
		if unit.unit_type != unit_type and not (unit.unit_type in colors.ALLIES[unit_type]) and unit.hp > 0:
			var dist = global_position.distance_squared_to(unit.global_position)
			if closest == null or dist < closest_dist:
				closest = unit
				closest_dist = dist
	if closest != null:
		attack(closest)

func attack(other_unit):
	other_unit.take_damage(attack_power, unit_type)
	can_attack = false
	is_attacking = true
	attacking_unit = other_unit
	attacking_unit_radius = other_unit.get_node("shape").shape.radius
	attack_timer.start()
	shoot_laser()

func shoot_laser():
	laser.show()
	update_laser()
	laser_timer.start()

const laser_tolerance = 2

func update_laser():
	if is_attacking:
		if attacking_unit == null:
			# Must've died
			stop_attacking()
			return

		laser.look_at(attacking_unit.global_position)
		var dist = global_position.distance_to(attacking_unit.global_position) - attacking_unit_radius + laser_tolerance
		laser.region_rect.end.x = dist / laser.scale.x

func _on_laser_timer_timeout():
	stop_attacking()
	
func stop_attacking():
	laser.hide()
	is_attacking = false
	attacking_unit = null
	attacking_unit_radius = 0

func _on_attack_timer_timeout():
	can_attack = true

func take_damage(damage, from_type):
	hp -= damage
	if hp <= 0:
		die()

func die():
	# TODO: Should there be some form of hitstun?
	yield(get_tree(), "idle_frame")
	queue_free()
