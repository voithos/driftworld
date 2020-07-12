extends KinematicBody2D

const colors = preload("res://scripts/colors.gd")

var utype = "base"

export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL

export (int) var starting_hp = 100
var hp = starting_hp

export var selected = false setget set_selected

export (float) var spawn_secs = 2.0
export (float) var spawn_ring_width = 50.0
export (float) var regen_secs = 1.0
export (int) var regen_amt = 1
export (int) var starting_units = 5

onready var timer = Timer.new()
onready var regen_timer = Timer.new()
onready var level = get_parent()
onready var spawn_radius = $shape.shape.radius

onready var detection = $detection
onready var healthbar = $healthbar
onready var healthbar_tween = Tween.new()
var healthbar_shown = false
const HEALTHBAR_ANIM_TIME = 0.5

const LASER_TOLERANCE = 10

var new_units_target

const unit_scene = preload("res://scenes/unit.tscn")

func _ready():
	randomize()
	$selection.hide()
	add_to_group("bases")
	become_type(unit_type)
	healthbar.modulate.a = 0
	add_child(healthbar_tween)
	
	add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(spawn_secs)
	timer.set_one_shot(false)
	timer.start()
	
	add_child(regen_timer)
	regen_timer.connect("timeout", self, "_on_regen_timer_timeout")
	regen_timer.set_wait_time(regen_secs)
	regen_timer.set_one_shot(false)
	regen_timer.start()
	
	call_deferred("setup_starting_units")

func _process(delta):
	check_hotkeys()

func check_hotkeys():
	if selected and Input.is_action_just_pressed("ui_cancel"):
		go_idle()

func _on_base_input_event(viewport, event, shape_idx):
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
	new_units_target = pos

func go_idle():
	new_units_target = null

func setup_starting_units():
	for i in range(starting_units):
		spawn_unit()

func _on_timer_timeout():
	# Don't generate units for neutral
	if unit_type != colors.TYPE.NEUTRAL:
		spawn_unit()

func _on_regen_timer_timeout():
	regen()

func regen():
	adjust_hp(regen_amt)

func spawn_unit():
	var unit = unit_scene.instance()
	unit.global_position = generate_spawn_position()
	unit.unit_type = unit_type
	level.add_child(unit)
	if selected:
		unit.set_selected(true)
	if new_units_target != null:
		unit.go_to(new_units_target)

func generate_spawn_position():
	var angle = randf() * PI * 2
	var direction = Vector2(cos(angle), sin(angle))
	var ring_offset = randf() * spawn_ring_width
	return global_position + direction * (spawn_radius + ring_offset)

func take_damage(damage, from_type):
	adjust_hp(-damage)
	if hp <= 0:
		takeover(from_type)

func adjust_hp(change):
	hp = min(starting_hp, hp + change)
	healthbar.value = max(0, hp / float(starting_hp)) * 100

	if hp < starting_hp and not healthbar_shown:
		healthbar_shown = true
		healthbar_tween.stop_all()
		healthbar_tween.interpolate_property(healthbar, "modulate", healthbar.modulate, Color(1, 1, 1, 1), HEALTHBAR_ANIM_TIME)
		healthbar_tween.start()
	elif hp == starting_hp and healthbar_shown:
		healthbar_shown = false
		healthbar_tween.stop_all()
		healthbar_tween.interpolate_property(healthbar, "modulate", healthbar.modulate, Color(1, 1, 1, 0.0), HEALTHBAR_ANIM_TIME)
		healthbar_tween.start()

func takeover(new_type):
	hp = starting_hp
	remove_from_group("bases_" + str(unit_type))
	become_type(new_type)

func become_type(new_type):
	unit_type = new_type
	add_to_group("bases_" + str(unit_type))
	$sprite.modulate = colors.COLORS[unit_type].darkened(0.15)
