extends Position3D
const static_box_object = preload("res://scenes/box_static.tscn")
const glasses_objects = [preload("res://scenes/glass1.tscn")]
const bomb_powerup_object = preload("res://scenes/bomb_powerup.tscn")
const slow_powerup_object = preload("res://scenes/slow_powerup.tscn")

var wall_boxes = []
var holes = 0
var star_global_position setget, get_global_star_position
var glasses = []
var broken_glasses = false
var boxes_for_explosis = []

func spawn(z_position, wall_track_length, y_position, wall_data, star_position, texture, bomb_powerup, slow_powerup):
	for i in range(len(wall_data)):
		wall_boxes.append([])
		for j in range(len(wall_data[i])):
			if wall_data[i][j]==0:
				wall_boxes[-1].append(null)
				holes += 1
				if bomb_powerup:
					var static_box = static_box_object.instance()
					static_box.translate(Vector3(j,i,0))
					static_box.get_node("Cube").get_surface_material(0).albedo_texture = texture
					boxes_for_explosis.append(static_box)
					add_child(static_box)
				if Vector3(j,i,0) != star_position:
					var glass = glasses_objects[0].instance()
					glasses.append(glass)
					glass.translate(Vector3(j,i,0))
					add_child(glass)
				continue
			var static_box = static_box_object.instance()
			static_box.translate(Vector3(j,i,0))
			static_box.get_node("Cube").get_surface_material(0).albedo_texture = texture
			wall_boxes[-1].append(static_box)
			add_child(static_box)
	translate(Vector3(0,y_position,z_position))
	var v = Vector3(len(wall_data[0]),len(wall_data),0.001)
	$pass_zone.scale = v
	$not_enough_zone.scale = v
	v.z = 1.5
	$no_build_zone.scale = v
	$star.translate(star_position)
	
	#powerups
	if bomb_powerup:
		var bomb = bomb_powerup_object.instance()
		bomb.translate(Vector3(round(randf()*(len(wall_data[0])-1)), 0, rand_range(0.6, 0.75)*wall_track_length))
		add_child(bomb)
	
	elif slow_powerup:
		var slow = slow_powerup_object.instance()
		slow.translate(Vector3(round(randf()*(len(wall_data[0])-1)), 0, rand_range(0.6, 0.75)*wall_track_length))
		add_child(slow)

func get_global_star_position():
	if star_global_position == null:
		star_global_position = $star.global_transform[3]
	return star_global_position

func break_glasses():
	if not broken_glasses:
		broken_glasses = true
		for glass in glasses:
			glass.get_node("AnimationPlayer").play("default")

func explode():
	for box in boxes_for_explosis:
		box.mode = RigidBody.MODE_RIGID
		box.get_node("Area/CollisionShape").disabled = true
		box.add_central_force(3*Vector3(300*(randf()-0.5),5,150))
	$AudioStreamPlayer2.play()

func destruction(collision=false):
	for row in wall_boxes:
		for box in row:
			if not box: continue
			if collision:
				box.add_child(preload("res://scenes/CollisionShape.tscn").instance())
			box.mode = RigidBody.MODE_RIGID
			box.get_node("Area/CollisionShape").disabled = true
			box.add_central_force(3*Vector3(20*(randf()-0.5),5,150*randf()))
