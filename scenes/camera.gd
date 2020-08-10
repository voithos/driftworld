extends Camera2D

export var speed = 25
export var zoomspeed = 10

const MIN_ZOOM = 0.5
const MAX_ZOOM = 3
const ZOOM_CHANGE = 0.1
const MOVE_MARGIN_X = 120.0
const MOVE_MARGIN_Y = 100.0

var curzoom = MAX_ZOOM

var boundary_topleft = Vector2()
var boundary_size = Vector2()

const INITIAL_ZOOM_TIME = 2.5
var is_initial_zoom = true

func _ready():
	add_to_group("camera")
	yield(get_tree().create_timer(0.8), "timeout")
	initial_zoom()

func initial_zoom():
	is_initial_zoom = true
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "curzoom", curzoom, 1.0, INITIAL_ZOOM_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	is_initial_zoom = false

func set_boundary(topleft, size):
	boundary_topleft = topleft
	boundary_size = size

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size

	if not is_initial_zoom:
		var horizontal = (
			int(Input.is_action_pressed("ui_right") || mouse_pos[0] > viewport_size[0] - MOVE_MARGIN_X)
		    - int(Input.is_action_pressed("ui_left") || mouse_pos[0] < MOVE_MARGIN_X)
		)
		var vertical = (
			int(Input.is_action_pressed("ui_down") || mouse_pos[1] > viewport_size[1] - MOVE_MARGIN_Y)
			- int(Input.is_action_pressed("ui_up") || mouse_pos[1] < MOVE_MARGIN_Y)
		)
		position.x = lerp(position.x, position.x + horizontal * speed * curzoom, speed * delta)
		position.y = lerp(position.y, position.y + vertical * speed * curzoom, speed * delta)
	
	position.x = clamp(position.x, boundary_topleft.x, boundary_topleft.x + boundary_size.x)
	position.y = clamp(position.y, boundary_topleft.y, boundary_topleft.y + boundary_size.y)
	
	zoom.x = lerp(zoom.x, curzoom, zoomspeed * delta)
	zoom.y = lerp(zoom.y, curzoom, zoomspeed * delta)
	
	update_shake(delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if curzoom - ZOOM_CHANGE >= MIN_ZOOM:
					curzoom -= ZOOM_CHANGE
			if event.button_index == BUTTON_WHEEL_DOWN:
				if curzoom + ZOOM_CHANGE <= MAX_ZOOM:
					curzoom += ZOOM_CHANGE


# Camera shake logic
# An extended camera that supports shaking.
# Taken and modified from https://godotengine.org/qa/438/camera2d-screen-shake-extension?show=438#q438

var _shaking = false
var _duration = 0.0
var _stopwatch = 0.0
var _period = 0.0
var _amplitude = 0.0
var _shake_trigger_accumulator = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _previous_offset = Vector2(0, 0)

func update_shake(delta):
	if not _shaking:
		return

	_shake_trigger_accumulator += delta
	# Only shake once per period.
	# This loop usually only runs once on any given frame, but
	# in case there's lag, the calculation will run multiple times and stabilize.
	while _shake_trigger_accumulator >= _period:
		_shake_trigger_accumulator -= _period

		# Intensity starts at full amplitude and decreases linearly.
		var intensity = lerp(_amplitude, 0, _stopwatch / _duration)

		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + delta * (new_x - _previous_x))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + delta * (new_y - _previous_y))
		_previous_x = new_x
		_previous_y = new_y

		# Track how much we've moved the offset, so that we don't interfere with
		# other offset effects.
		var new_offset = Vector2(x_component, y_component)
		offset = offset - _previous_offset + new_offset
		_previous_offset = new_offset
			
	_stopwatch += delta
	if _stopwatch > _duration:
		# Clear our offset once shaking is done.
		offset = offset - _previous_offset
		_shaking = false

# Begin the screenshake effect.
#   duration: The amount of time to shake for, in seconds.
#   frequency: The shake frequency (per second).
#   amplitude: How heavily to shake.
func shake(duration, frequency, amplitude):
	_shaking = true
	_duration = duration
	_stopwatch = 0.0
	_period = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	
	# Clear the offset by subtracting our previous offset so that we don't interfere with
	# other effects that may be ongoing.
	offset = offset - _previous_offset
	_previous_offset = Vector2(0, 0)
