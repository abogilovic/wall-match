extends RigidBody
export(bool) var main = false
var speed setget set_speed
var apply_speed = false

func set_speed(v):
	speed = v
	linear_velocity = speed*Vector3(0,0,-1)

func _ready():
	if main: mode = MODE_RIGID

func _process(delta):
	if main and apply_speed:
		linear_velocity = speed*Vector3(0,0,-1)

func spawn(from, to, ref, texture):
	$Cube.get_surface_material(0).albedo_texture = texture
	var spawn_animation = $AnimationPlayer.get_animation("spawn")
	spawn_animation.track_set_key_value(0,0,from)
	spawn_animation.track_set_key_value(0,1,to)
	$AnimationPlayer.connect("animation_finished", ref, "add_remove_animation_finished")
	$Area.connect("area_entered", ref, "structure_entered")
	$AnimationPlayer.play("spawn")

func remove(to):
	$AnimationPlayer.connect("animation_finished", self, "remove_anim_finish")
	var spawn_animation = $AnimationPlayer.get_animation("spawn")
	spawn_animation.track_set_key_value(0,0,to)
	spawn_animation.track_set_key_value(0,1,transform[3])
	$AnimationPlayer.play_backwards("spawn")

func remove_anim_finish(_dummy):
	queue_free()
