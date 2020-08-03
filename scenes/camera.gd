extends Camera2D

export var speed = 25
export var zoomspeed = 10

const MIN_ZOOM = 0.5
const MAX_ZOOM = 3
const ZOOM_CHANGE = 0.1
const MOVE_MARGIN_X = 150.0
const MOVE_MARGIN_Y = 100.0

var curzoom = 1.0

var boundary_topleft = Vector2()
var boundary_size = Vector2()

func _ready():
	add_to_group("camera")

func set_boundary(topleft, size):
	boundary_topleft = topleft
	boundary_size = size

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size
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

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if curzoom - ZOOM_CHANGE >= MIN_ZOOM:
					curzoom -= ZOOM_CHANGE
			if event.button_index == BUTTON_WHEEL_DOWN:
				if curzoom + ZOOM_CHANGE <= MAX_ZOOM:
					curzoom += ZOOM_CHANGE
