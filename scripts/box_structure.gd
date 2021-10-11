extends Spatial
const box_object = preload("res://scenes/box.tscn")
onready var pass_structure_shrink_timer = get_node("pass_structure_shrink_timer")
onready var game = get_parent().get_parent()
var boxes = []
var path = []
var spawn_able = true
var next_wall
var true_path
var boxes_passed = 0
var has_outcome = false
var stop_build = false
var next_wall_width
var next_wall_height
var speed setget set_speed
var apply_speed = false setget set_apply_speed
var texture setget set_texture

func set_texture(t):
	texture = t
	boxes[0].get_node("Cube").get_surface_material(0).albedo_texture = texture

func set_next_wall(wall, true_path):
	next_wall = wall
	boxes_passed = 0
	has_outcome = false
	stop_build = false
	spawn_able = true
	next_wall_width = len(wall.wall_boxes[0])-1
	next_wall_height = len(wall.wall_boxes)-1
	self.true_path = true_path
	self.speed = 5 if game.stage_level>5 else 3
	boxes[0].gravity_scale = 1

func set_speed(v):
	speed = v
	boxes[0].speed = v
	get_node("moving_camera").speed = v

func set_apply_speed(b):
	apply_speed = b
	boxes[0].apply_speed = b
	get_node("moving_camera").apply_speed = b

func body_entered(_body):
	if _body.collision_layer==64:
		set_apply_speed(true)
		

func body_exited(_body):
	if _body.collision_layer==64:
		set_apply_speed(false)

func _ready():
	boxes.append($main_box)
	$main_box/Area.connect("area_entered", self, "structure_entered")
	$main_box.connect("body_entered", self, "body_entered")
	$main_box.connect("body_exited", self, "body_exited")
	pass_structure_shrink_timer.connect("timeout", self, "remove_last_box")

func next_spawns(center_position):
	return [center_position+Vector3(-1,0,0),
				   center_position+Vector3(0,1,0),
				   center_position+Vector3(1,0,0),
				   center_position+Vector3(0,-1,0),]

func add_box(side): #side 0,1,2,3
	var last_box_position = boxes[-1].transform[3] if len(path)!=0 else Vector3.ZERO
	boxes.append(box_object.instance())
	boxes[-1].spawn(last_box_position, next_spawns(last_box_position)[side], self, texture)
	boxes[0].add_child(boxes[-1])
	Input.vibrate_handheld(40)
	path.append(side)
	spawn_able = false
	$AudioStreamPlayer.play()

func add_remove_animation_finished(_dummy):
	spawn_able = true

func remove_last_box():
	if len(boxes)<2:
		pass_structure_shrink_timer.stop()
		boxes[0].gravity_scale = 1
		queued_moves.clear()
		return
	boxes[-1].remove(boxes[-2].transform[3] if len(path)!=1 else Vector3.ZERO)
	boxes.remove(len(boxes)-1)
	path.remove(len(path)-1)
	if pass_structure_shrink_timer.is_stopped():
		Input.vibrate_handheld(40)
	spawn_able = false

func collide_over(side):
	var pos_spawn = next_spawns(boxes[-1].transform[3])[side]
	for i in len(boxes)-1:
		if pos_spawn.distance_to(boxes[i].transform[3] if i!=0 else Vector3.ZERO)<0.5:
			return true
	return false

func structure_entered(_area):
	if has_outcome:
		if _area.collision_layer==32:
			game.finish_entered()
	else:
		match _area.collision_layer:
			2: #box pass indicator
				boxes_passed += 1
				if boxes_passed == next_wall.holes and path==true_path and boxes[-1].global_transform[3].distance_to(next_wall.get_node("star").global_transform[3])<1:
					game.wall_passed(next_wall)
			4: # udar u zid
				game.wall_hit()
			8: # ako dodje do not enough
				game.wall_incomplete()
			16: # no build zone
				stop_build = true
				_area.get_node("CollisionShape").disabled = true

var tutorial_moves
func process_move(side):
	if tutorial_moves and len(tutorial_moves)>0:
		if side == tutorial_moves[0]:
			tutorial_moves.remove(0)
			if len(tutorial_moves)==0:
				game.finish_tutorial_animation()
		else: return
	var last_box_pos = boxes[-1].global_transform[3]
	var first_box_pos = boxes[0].global_transform[3]
	var next_wall_pos = next_wall.global_transform[3]
	if side == 3 and abs(last_box_pos[1]-first_box_pos[1])<0.2 or side == 0 and abs(last_box_pos[0])<0.2 or side == 2 and abs(last_box_pos[0]-next_wall_width)<0.2 or side == 1 and abs(last_box_pos[1]-first_box_pos[1]-next_wall_height)<0.2:
		return
	var del = [2, 3, 0, 1]
	if len(path)>0:
		if del[side] != path[-1]:
			if not collide_over(side):
				add_box(side)
		else: remove_last_box()
	elif side == 1:
		add_box(side)
	elif side in [0,2]:
		reposition(side)

func reposition(side):
#	spawn_able = false
#	$main_box/Tween.interpolate_property($main_box, "translation",
#		$main_box.translation, $main_box.translation + (Vector3(-1,0,-0.7) if side==0 else Vector3(1,0,-0.7)), 0.1,
#		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
#	$main_box/Tween.connect("tween_all_completed", self, "add_remove_animation_finished", [null])
#	$main_box/Tween.start()
	#$main_box.transform[3] += Vector3(-1,0,0) if side==0 else Vector3(1,0,0)
	if apply_speed:
		$main_box.translate(Vector3(-1,0,-0.08) if side==0 else Vector3(1,0,-0.08))
		$AudioStreamPlayer4.play()
	#Input.vibrate_handheld(40)
	#$main_box/Camera.translate(Vector3(1,0,0) if side==0 else Vector3(-1,0,0))

func leave_boxes_inside():
	for glass in next_wall.glasses:
		var box = box_object.instance()
		box.global_transform = glass.global_transform
		box.mode = RigidBody.MODE_RIGID
		#box.get_node("CollisionShape2").disabled = true
		box.add_central_force(3*Vector3(20*(randf()-0.5),5,20*randf()))
		get_parent().add_child(box)

	queue_free()

func shrink_boxes():
	boxes[0].gravity_scale = 0
	boxes[0].sleeping = true
	boxes[0].visible = false
	var dv = boxes[-1].global_transform[3] - boxes[0].global_transform[3]

	for i in range(len(boxes)):
		boxes[i].translate(dv if i==0 else -dv)
	
	for i in range(int((len(boxes)-2)/2)):
		var x = Vector3(boxes[i+1].global_transform[3])
		boxes[i+1].global_transform[3] = boxes[-(i+2)].global_transform[3]
		boxes[-(i+2)].global_transform[3] = x
	
	boxes[0].sleeping = false
	boxes[0].visible = true
	
	pass_structure_shrink_timer.start()

var start_drag_position
var drag_started = false
var queued_moves = []

var started_moving = false
func _process(_delta):
	if not has_outcome:
		if path==true_path and spawn_able:
			var p_last = boxes[-1].global_transform[3]
			var x = Vector2(p_last.x-next_wall.star_global_position.x, p_last.y-next_wall.star_global_position.y)
			if x.length()<0.5:
				spawn_able = false
				set_speed(25)
				$AudioStreamPlayer5.play()
		if spawn_able and not stop_build and len(queued_moves)>0 and pass_structure_shrink_timer.is_stopped():
			process_move(queued_moves.pop_back())


var clicks = 0
var click_pos = Vector2(0,0)
func _input(event):
	if game.level_container.get_node("MainScreen").visible: 
		return
	#if get_tree().get_nodes_in_group("tutorial")[0].tut_end == true:
	if event is InputEventMouseButton:
		if event.pressed:
			if clicks == 0:
				click_pos = event.position
			clicks += 1
			if clicks == 2 and event.position.distance_to(click_pos) < 70 and spawn_able:
				reset_structure()
				clicks = 0
			drag_started = false
		else:
			queued_moves.clear()
	if event is InputEventMouseMotion:
		if event.position.distance_to(click_pos) > 70:
			clicks = 0
		if not drag_started:
			start_drag_position = event.position
			drag_started = true
		else:
			var v = (event.position-start_drag_position)
			var vlen = v.length()
			#var screen_relative = (screen_width/1440.0)
			if vlen > 110:
				var side
				var angle = v.angle()
				if abs(angle)>PI-PI/4: side = 0
				elif vlen > 130 and angle<=-PI/4 and angle>=-PI+PI/4: side = 1
				elif abs(angle)<PI/4: side = 2
				elif vlen > 130 and angle>=PI/4 and angle<=PI-PI/4: side = 3
				else: return
				queued_moves.push_front(side)
				drag_started = false

func reset_structure():
	for i in range(len(boxes)-1):
		remove_last_box()

func knock_apart():
	for i in range(len(boxes)):
		var box = box_object.instance()
		box.mode = RigidBody.MODE_RIGID
		box.global_transform = boxes[-i-1].global_transform
		boxes[-i-1].queue_free()
		box.collision_mask = 0b00000000000000000101
		box.friction = 1
		add_child(box)
		box.add_central_force(3*Vector3(5*(randf()-0.5),5,2))
