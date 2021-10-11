extends Area

func _ready():
	$AnimationPlayer.play("rotation")

func _on_bomb_powerup_area_entered(area):
	if area.collision_layer==1:
		var box_structure = area.get_parent().get_parent()
		if box_structure.name != "box_structure":
			box_structure = box_structure.get_parent()
			if box_structure.name != "box_structure":
				return
		self.visible = false
		box_structure.next_wall.explode()
		$AudioStreamPlayer.play()
		if not $AudioStreamPlayer.is_connected("finished", self, "picked_up"):
			$AudioStreamPlayer.connect("finished", self, "picked_up")
		
func picked_up():
	queue_free()
