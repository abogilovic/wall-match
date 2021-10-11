extends Area

var slow_time = 4
var box_structure

func _ready():
	$AnimationPlayer.play("rotation")

func _on_slow_powerup_area_entered(area):
	if area.collision_layer==1:
		box_structure = area.get_parent().get_parent()
		if box_structure.name == "main_box":
			box_structure = box_structure.get_parent()
		if box_structure.speed!=25:
			box_structure.speed = 2
		self.visible = false
		get_tree().create_timer(slow_time).connect("timeout", self, "after_slow")
		$AudioStreamPlayer.play()

func after_slow():
	if box_structure!=null:
		if box_structure.speed == 2:
			box_structure.speed = 5
	queue_free()
