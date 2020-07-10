extends Camera2D

func _ready():
	pass

const SPEED = 1000

func _process(delta):
	var horizontal = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	var vertical = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
	position.x += horizontal * delta * SPEED
	position.y += vertical * delta * SPEED
