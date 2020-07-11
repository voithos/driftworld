extends Camera2D

export var speed = 25
export var zoomspeed = 10

const MIN_ZOOM = 0.5
const MAX_ZOOM = 3
const ZOOM_CHANGE = 0.1

var curzoom = 1.0

func _ready():
	add_to_group("camera")

func _process(delta):
	var horizontal = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	var vertical = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
	position.x = lerp(position.x, position.x + horizontal * speed, speed * delta)
	position.y = lerp(position.y, position.y + vertical * speed, speed * delta)
	
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
