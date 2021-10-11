extends Node
const main_screen = preload("res://scenes/MainScreen.tscn")
const wall_object = preload("res://scenes/wall.tscn")
const box_structure_object = preload("res://scenes/box_structure.tscn")

var level_container

var texture
var box_structure
var walls_data = []
var walls = []
var grounds = []
var finish_circle

var current_height = 0

#environment
const TEXTURES = [preload("res://textures/Texture3_ForestB.png"),
				preload("res://textures/Texture2_ForestA.png"),
				preload("res://textures/Texture4_Sea.png"),
				preload("res://textures/Texture5_City.png"),
				preload("res://textures/Texture6_Clouds.png"),
				preload("res://textures/Texture1_CityOverview.png")]
const PLAYER_SKINS = [preload("res://textures/Cube_1.png"), preload("res://textures/Cube_2.png"),preload("res://textures/Cube_3.png"),preload("res://textures/Cube_4.png"),preload("res://textures/Cube_5.png"),preload("res://textures/Cube_6.png"),preload("res://textures/Cube_7.png")]
const platforms = ["res://scenes/platform4.tscn","res://scenes/platform5.tscn","res://scenes/platform6.tscn","res://scenes/platform7.tscn","res://scenes/platform8.tscn"]
const environsets = ["res://scenes/environsets/environset1.tscn", 
					"res://scenes/environsets/environset2.tscn",
					"res://scenes/environsets/environset3.tscn",
					"res://scenes/environsets/environset4.tscn",
					"res://scenes/environsets/environset5.tscn",
					"res://scenes/environsets/environset6.tscn"]

func _ready():
	playLevel(GJMain.getLevel())
	GJMain.onGameReady()

func _difficulty_tweaker():
	for level in range(1,50):
		#var holes_amount = 4 + int(round(5*levelnew + cos(PI+levelnew*0.6)))
		#var walls_amount = 1 + int(levelnew/5.5) + int((1-cos(levelnew)))
		
		var walls_amount = 3 + int(level/5.85) #+ int((1-cos(level)))
		var holes_amount = 5 + 5*level  #int(round(5*level + cos(PI+level*0.6)))
		print("Level{} -> {}, {}, {}".format([level+5, walls_amount, holes_amount, float(holes_amount)/walls_amount], "{}"))

var stage_level
func playLevel(level):
	stage_level = level
	clear_previous_level()
	level_container.add_child(main_screen.instance())
	level_container.add_child(load("res://scenes/control.tscn").instance())
	
	level_container.get_node("Control/start_text").show()
	texture = TEXTURES[int((level-1)/3)%len(TEXTURES)]
	#_difficulty_tweaker()
	#return
	box_structure = box_structure_object.instance()
	level_container.add_child(box_structure)
	if level in [1,2]:
		box_structure.tutorial_moves = [[1],[1,2]][level-1]
	box_structure.get_node("moving_camera/Camera/Background").get_surface_material(0).albedo_texture = texture
	box_structure.texture = PLAYER_SKINS[(level-1)%len(PLAYER_SKINS)] #PLAYER_SKINS[GJMain.getSkin()-1]
	box_structure.speed = 5 if level>5 else 3
	
	if level<=5:
		var ml = load("res://scenes/manual_levels.tscn").instance()
		walls_data.append(ml.manual_levels[level-1])
		ml.queue_free()
		if level==1:
			level_container.get_node("Control/start_text").text = "DRAG UP"
			level_container.get_node("Control/hand").show()
			var anim = level_container.get_node("Control/hand/AnimationPlayer").get_animation("up")
			anim.track_set_key_value(0,0,level_container.get_node("Control/hand").rect_position + Vector2(0,0))
			anim.track_set_key_value(0,1,level_container.get_node("Control/hand").rect_position + Vector2(0,-200))
			anim.track_set_key_value(0,2,level_container.get_node("Control/hand").rect_position + Vector2(0,-200))
			level_container.get_node("Control/hand/AnimationPlayer").play("up")
			#level_container.get_node("Control/Tutorial").popup_centered()
		elif level==2:
			level_container.get_node("Control/start_text").text = "DRAG UP & RIGHT"
			level_container.get_node("Control/hand").show()
			var anim = level_container.get_node("Control/hand/AnimationPlayer").get_animation("up-right")
			anim.track_set_key_value(0,0,level_container.get_node("Control/hand").rect_position + Vector2(0,0))
			anim.track_set_key_value(0,1,level_container.get_node("Control/hand").rect_position + Vector2(0,-200))
			anim.track_set_key_value(0,2,level_container.get_node("Control/hand").rect_position + Vector2(200,-200))
			anim.track_set_key_value(0,3,level_container.get_node("Control/hand").rect_position + Vector2(200,-200))
			level_container.get_node("Control/hand/AnimationPlayer").play("up-right")
	else:
		var levelnew = level-5
		var walls_amount = 3 + int(levelnew/5.85) #+ int((1-cos(level)))
		var holes_amount = 5 + 5*levelnew  #int(round(5*level + cos(PI+level*0.6)))
		var holes_per_wall = holes_amount/walls_amount
		seed(level)
		var the_width = 4 + level/100 + randi()%5
		if the_width > 8: the_width = 8
		
		while(1):
			if holes_per_wall>the_width*13:
				if the_width < 8: the_width += 1
				else:
					holes_per_wall = the_width*13
					break
			else: break
		
		var explode_wall_index = -1
		if walls_amount > 3:
			explode_wall_index = randi()%walls_amount
		for i in range(walls_amount):
			walls_data.append(random_wall_data(holes_per_wall, the_width, explode_wall_index==i))
	
	var env_distance = 0
	var last_wall_distance = 0
	var wall_distance = 0
	var next_wall_width = 0
	var last_height = current_height
	var wall
	for i in range(len(walls_data)+1):
		if i!=len(walls_data):
			var wall_data = walls_data[i]
			wall = wall_object.instance()
			if level < 4: wall_distance = 22
			elif level < 8: wall_distance = 32
			else:
				wall_distance = 15 + (3 + abs(last_height-current_height)*1 if i!=0 else 0) + (box_structure.speed*wall_data["holes_amount"])*0.5
			last_wall_distance += wall_distance
			wall.spawn(-last_wall_distance, wall_distance, current_height, wall_data["wall_matrix"], wall_data["star_position"], texture, wall_data["bomb_powerup"], wall_data["slow_powerup"])
			walls.append(wall)
			level_container.add_child(wall)
		else:
			finish_circle = load("res://scenes/finish_circle.tscn").instance()
			finish_circle.translate(Vector3(next_wall_width/2.0, current_height+4, -last_wall_distance-wall_distance/1.2))
			finish_circle.get_node("Mesh").get_surface_material(0).albedo_texture = texture
			finish_circle.connect("body_entered", self, "finish_entered")
			level_container.add_child(finish_circle)
		
		next_wall_width = len(wall.wall_boxes[0])-1
		var ground = load(platforms[(next_wall_width+1-4)%len(platforms)]).instance()
		ground.translate(Vector3(-0.5, current_height, -last_wall_distance+(-wall_distance*3 if i==len(walls_data) else wall_distance)/2.0))
		last_height = current_height
		var rf = randf()
		if rf < 0.5: current_height -= 6 * rf/0.5
		if i==0: ground.translate(Vector3(0,0,6))
		ground.scale = Vector3(1,2, wall_distance*3 if i==len(walls_data) else (wall_distance if i!=0 else wall_distance+12))
		ground.get_node("StaticBody/Mesh").get_surface_material(0).albedo_texture = texture
		grounds.append(ground)
		level_container.add_child(ground)
		
		if i==len(walls_data): last_wall_distance += wall_distance
		randomize()
		while env_distance<=last_wall_distance+30:
			var environset = load(environsets[int((level-1)/3)%len(environsets)]).instance()
			environset.put_meshes(int((level-1)/3), texture)
			environset.make_translations(Vector3(0,0,-env_distance-8),
									Vector3(-2, current_height-10, 0),
									Vector3(next_wall_width+2, current_height-10, 0))
			level_container.add_child(environset)
			env_distance += 30
	
	
	box_structure.get_node("main_box").translate(Vector3(int(len(walls[0].wall_boxes[0])/2), 1, 0))
	box_structure.get_node("moving_camera").position_nicely(Vector3(int(len(walls[0].wall_boxes[0])/2), 1, 0))
	box_structure.set_next_wall(walls.pop_front(), walls_data.pop_front()["path"])
	box_structure.speed = 0
	box_structure.stop_build = true
	
	#DODANO
	#level_container.get_node("Control/Tutorial").hide()
	level_container.get_node("Control").hide()
	#DODANO

func finish_tutorial_animation():
	level_container.get_node("Control/hand/AnimationPlayer").stop()
	level_container.get_node("Control/hand").hide()

func around_positions(center_position):
	return [center_position+Vector2(-1,0),
				   center_position+Vector2(0,1),
				   center_position+Vector2(1,0),
				   center_position+Vector2(0,-1),]

func flood_fill(wall_matrix, h, w):
	if not(h>0 and h<len(wall_matrix) and w>=0 and w<len(wall_matrix[0])) or wall_matrix[h][w] == 0: return 0
	var floods = [Vector2(h,w)]
	var new_floods = 1

	while new_floods>0:
		var nf = new_floods
		new_floods = 0
		for i in range(len(floods)-nf, len(floods)):
			var potential_floods = around_positions(floods[i])
			for p in potential_floods:
				if p.x<len(wall_matrix) and p.x>0 and p.y<len(wall_matrix[0]) and p.y>=0 and wall_matrix[p.x][p.y]!=0 and not p in floods:
					floods.append(p)
					new_floods += 1
	return len(floods)
	
func random_wall_data(holes_amount, width, to_bomb):
	var wall_matrix = []
	var path = []
	var star_position
	var init_holes_amount = holes_amount
	
	var to_slow = holes_amount > 9 and randf() < 0.25
	#algor
	#var width = 4 + randi()%5
	var height = max(3,int(min(14, 5*(holes_amount/width))))
	#var width = 7
	#var height = 6
	for i in range(height):
		wall_matrix.append([])
		for j in range(width):
			wall_matrix[i].append(1)
	
	var start_column = randi()%width
	wall_matrix[0][start_column] = 0
	wall_matrix[1][start_column] = 0
	path.append(1)
	holes_amount -= 2
	
	var i = 1
	var j = start_column
	var i_moves = [0,1,0,-1]
	var j_moves = [-1,0,1,0]
	
	while holes_amount>0:
		var valid_floods = []
		var max_flood = 1
		for k in range(4):
			var flood = flood_fill(wall_matrix, i+i_moves[k], j+j_moves[k])
			if flood >= holes_amount and flood >= max_flood:
				if flood > max_flood:
					max_flood = flood
					valid_floods.clear()
				valid_floods.append([k, flood])

		var better_floods = []
		var max_c = -1
		for v in valid_floods:
			var ap = around_positions(Vector2(i+i_moves[v[0]], j+j_moves[v[0]]))
			var c = 0
			for a in ap:
				if a.x<len(wall_matrix) and a.x>=0 and a.y<len(wall_matrix[0]) and a.y>=0:
					if wall_matrix[a.x][a.y]!=0:
						c += 1
				else: c += 0.5
			if c>max_c:
				max_c = c
				better_floods.clear()
			if c == max_c:
				better_floods.append(v)
			
		valid_floods = better_floods
		
		var mv = valid_floods[randi()%len(valid_floods)]
		
		var delta_i = i_moves[mv[0]]
		var delta_j = j_moves[mv[0]]
		if delta_i!=0:
			path.append(1 if delta_i>0 else 3)
		elif delta_j!=0:
			path.append(2 if delta_j>0 else 0)
		i += delta_i
		j += delta_j
		wall_matrix[i][j] = 0
		star_position = Vector3(j,i,0)
		holes_amount -= 1
	#algo
	
	return {"wall_matrix": wall_matrix, "path": path, "holes_amount": init_holes_amount, "star_position": star_position, "bomb_powerup": to_bomb, "slow_powerup": to_slow}

func finish_entered():
	print("WIIIIIIIIIIN")
	#box_structure.speed = 0
	box_structure.get_node("moving_camera").speed = 0
	box_structure.get_node("moving_camera").on_win_camera_movement()
	level_container.get_node("Control/confetti_new").emit_confetti(true)
	GJMain.onLevelComplete(true)

func wall_incomplete():
	print("Wall incomplete")
	box_structure.has_outcome = true
	box_structure.speed = 0
	box_structure.get_node("AudioStreamPlayer2").play()
	box_structure.knock_apart()
	box_structure.next_wall.get_node("star").hide()
	box_structure.next_wall.destruction(true)
	stopLevel()

func wall_hit():
	print("Wall hit")
	box_structure.has_outcome = true
	#box_structure.speed = -0.45
	box_structure.speed = 0
	box_structure.apply_speed = false
	box_structure.knock_apart()
	box_structure.get_node("AudioStreamPlayer2").play()
	stopLevel()

func slow_motion(v):
	Engine.time_scale = 0.25 if v else 1

func wall_passed(wall):
	print("Wall passed")
	slow_motion(true)
	get_tree().create_timer(0.2).connect("timeout", self, "slow_motion", [false])
	
	box_structure.has_outcome = true
	wall.get_node("not_enough_zone/CollisionShape").disabled = true
	wall.get_node("star").hide()
	wall.destruction(true)
	
	var prev_camera_translation = box_structure.get_node("moving_camera").translation
	var prev_real_camera_translation = box_structure.get_node("moving_camera/Camera").translation
	var prev_speed = box_structure.speed
	var prev_texture = box_structure.texture
	box_structure.leave_boxes_inside()
	
	box_structure = box_structure_object.instance()
	level_container.add_child(box_structure)
	box_structure.get_node("moving_camera/Camera/Background").get_surface_material(0).albedo_texture = texture
	box_structure.get_node("main_box").global_transform = wall.get_node("star").global_transform
	var camera = box_structure.get_node("moving_camera")
	camera.translate(prev_camera_translation)
	box_structure.get_node("moving_camera/Camera").translation = prev_real_camera_translation
	
	box_structure.has_outcome = true
	box_structure.started_moving = true
	box_structure.speed = prev_speed
	box_structure.texture = prev_texture
	box_structure.get_node("AudioStreamPlayer3").play()
	
	if len(walls)>=1:
		box_structure.boxes[0].gravity_scale = 0
		var next_wall = walls.pop_front()
		var next_wall_data = walls_data.pop_front()["path"]
		camera.drop_camera_down(next_wall.global_transform[3][1]-wall.global_transform[3][1])
		get_tree().create_timer(0.2).connect("timeout",box_structure,"set_next_wall",[next_wall, next_wall_data])
	else:
		camera.drop_camera_down(finish_circle.global_transform[3][1] - 4 - wall.global_transform[3][1])

func clear_previous_level():
	if level_container != null:
		level_container.queue_free()
	
	level_container = Spatial.new()
	level_container.name = "level_container"
	add_child(level_container)
	walls.clear()
	grounds.clear()
	walls_data.clear()
	current_height = 0

func _on_Button_pressed():
	get_tree().reload_current_scene()

func stopLevel():
	# add here input disabling function here
	GJMain.onLevelComplete(false)
