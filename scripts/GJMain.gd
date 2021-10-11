extends Node

enum hint_type {REGULAR,PREMIUM}

var level : int = 1
var skin : int = 5

func _ready():
	load_level()

func load_level():
	var save_file = File.new()
	if not save_file.file_exists("user://savefile.save"):
		print("Aborting, no savefile")
		return

	save_file.open("user://savefile.save", File.READ)
	level = int(save_file.get_line())
	save_file.close()

func save_level():
	var save_file = File.new()
	save_file.open("user://savefile.save", File.WRITE)
	save_file.store_line(str(level))
	save_file.close()

func onGameReady():
	pass

func getLevel() -> int:
	return level

func getSkin() -> int:
	return skin

func BuyInGameItem(type : int, itemName) -> bool:
	return true

func onLevelComplete(isLevelSuccess : bool, data : Dictionary = {}):
	if isLevelSuccess:
		level+=1
		save_level()
		get_tree().create_timer(2.5).connect("timeout", self, "loadNewLevel")
	else:
		get_tree().create_timer(2).connect("timeout", self, "loadNewLevel")

func loadNewLevel():
	get_tree().get_current_scene().playLevel(getLevel())

func earlyEndLevelNotice(isLevelSuccess : bool): 
	# use this if there is a delay between the moment the game and player know
	# the game is ended and the actual call to onLevelComplete
	# ensure you use GJMain.has_method() to maintain compability with different modes/versions
	pass

func getHintType(type : int) -> Dictionary:
	var out : Dictionary = {
		"can_buy": false,
		"price": -1,
	}
	if type == hint_type.REGULAR:
		out.can_buy = true
		out.price = 50
	elif type == hint_type.PREMIUM:
		out.price = 150
	return out
