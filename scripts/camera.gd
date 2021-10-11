extends RigidBody
var speed setget set_speed
var apply_speed = false

func set_speed(v):
	speed = v
	linear_velocity = speed*Vector3(0,0,-1)

func position_nicely(v):
	translate(v+Vector3(4.0, 8.983, 20.172))

func _process(delta):
	if apply_speed:
		linear_velocity = speed*Vector3(0,0,-1)

func drop_camera_down(y):
	$Tween.interpolate_property($Camera, "translation", $Camera.translation, $Camera.translation+Vector3(0,y,0), 1, Tween.TRANS_QUAD)
	$Tween.start()

func on_win_camera_movement():
	var anim = $AnimationPlayer.get_animation("rotatecam")
	anim.track_set_key_value(1,0,translation + Vector3(0,0,0))
	anim.track_set_key_value(1,1,translation + Vector3(5,-4,-17.5))
	anim.track_set_key_value(1,2,translation + Vector3(0,0,-35))
	$AnimationPlayer.play("rotatecam")
