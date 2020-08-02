extends Sprite

export (float) var speed = 1
export (float) var acceleration = 3.0
export (float) var max_size = 3
export (float) var strength = 0.178

onready var current_scale = Vector2.ZERO
var is_expanding = false

func _ready():
	scale = Vector2.ZERO
	material.set_shader_param("strength", strength)

func _process(delta):
	if is_expanding:
		if scale.x < max_size:
			scale += Vector2(speed, speed) * delta
			scale *= 1.0 + acceleration * delta
		else:
			is_expanding = false
			scale = Vector2.ZERO

func shockwave():
	is_expanding = true
	scale = Vector2.ZERO
