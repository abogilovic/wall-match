extends Control


func _ready():
	$Label.text = "Level " + str(GJMain.getLevel()) + " of Infinity"
	pass


var started_moving = false
func _on_play_button_pressed():
	var game = get_parent().get_parent()
	game.level_container.get_node("Control").show()
	if not started_moving:
		game.box_structure.speed = 5 if game.stage_level>5 else 3
		game.box_structure.stop_build = false
		game.level_container.get_node("Control/start_text").hide()
		game.box_structure.started_moving = true
	hide()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_clear_progress_pressed():
	GJMain.level = 1
	GJMain.onLevelComplete(false)


func _on_info_button_pressed():
	$Panel2.show()
	get_tree().create_timer(1.5).connect("timeout", $Panel2, "hide")
