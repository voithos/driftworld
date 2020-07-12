extends Node

# Music management.

const MIN_DB = -80.0
const MUSIC_DB = -8.0

class MusicBox extends Node:
	var player
	
	func _init(stream):
		player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = stream
		player.volume_db = MIN_DB

	func set_volume_db(volume_db):
		player.volume_db = volume_db

	func play():
		player.volume_db = MUSIC_DB
		player.play()

var level_theme = preload("res://assets/the-lift.ogg")

var level_musicbox

const MUSIC_LEVEL = "LEVEL"
var current_music = null

func _ready():
	_load_music()

func _load_music():
	level_musicbox = MusicBox.new(level_theme)
	add_child(level_musicbox)

func play_background():
	if current_music != MUSIC_LEVEL:
		level_musicbox.play()
		current_music = MUSIC_LEVEL
