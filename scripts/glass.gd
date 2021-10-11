extends Spatial

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "free_up")


func _on_Area_area_entered(area):
	get_parent().break_glasses()
	get_parent().get_node("AudioStreamPlayer").play()

func free_up(_name):
	queue_free()
