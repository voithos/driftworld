extends Node

const hints = {
	"directive": ["your fight continues", "capture the red base"],
	"safety": ["the struggle can drive one mad", "but there is safety in numbers"],
	"neutral": ["acquire the center"],
	"drifters": ["but be cautious", "lest they turn against you"],
	"patience": ["take your time", "do not let the drifters oppose you"],
	"resist": ["the drifters", "they assemble against you"],
	"end": ["the red is no more", "yet the drifters still defy you", "will you end this?"],
}

var seen = {}

func show_hint(ui, key):
	if key in seen:
		return
	for text in hints[key]:
		ui.show_message(text)
		yield(ui, "message_complete")
	seen[key] = true
