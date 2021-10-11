extends Popup

func _ready():
	$Move/anim.play("fade_in")
	$Move/Stretch.visible = false
	$Move/Release.visible = false

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		$Move/anim.play("fade_out")

func _on_anim_animation_finished(anim_name):
	match anim_name:
		"fade_out":
			hide()
		"fade_in":
			$Move/Noise.play("noise")
