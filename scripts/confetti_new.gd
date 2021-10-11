extends Control

func _ready():
	pass # Replace with function body.

func emit_confetti(v):
	if v: $AudioStreamPlayer.play()
	for child in get_children():
		if child.name != "AudioStreamPlayer":
			child.emitting = v


func _on_stop_confetti_timer_timeout():
	emit_confetti(false)
