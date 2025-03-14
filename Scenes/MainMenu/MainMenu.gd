extends Control

signal button_pressed(id)

# The current selection of the menu
var _selection := 0
# The buttons of the menu
var _buttons: Array

var just_moved := false

# Called when the node enters the scene tree for the first time.
func _ready():
	_buttons = [get_node("MainMenuButtons/NewGameButton") as NinePatchRect, 
			   get_node("MainMenuButtons/LoadGameButton") as NinePatchRect,
			   get_node("MainMenuButtons/SettingsButton") as NinePatchRect, 
			   get_node("MainMenuButtons/QuitButton") as NinePatchRect]
	connect("button_pressed", self, "pressed")
	_buttons[_selection].modulate = Color(1,1,1,1)
	randomize()


func _input(event):
	if event.is_action_pressed("ui_up"):
		_selection -= 1
		if _selection < 0: _selection = 3
		just_moved = true
	elif event.is_action_pressed("ui_down"):
		_selection += 1
		if _selection > 3: _selection = 0
		just_moved = true
	elif event.is_action_pressed("ui_accept"): # If a button is pressed
		emit_signal("button_pressed", _selection)

func _process(_delta):
	# Movements up and down
	if just_moved: # Avoids refreshing all the time
		$Change.play()
		for button in _buttons: # Colors the active button
			button.modulate = Color(0.31,0.31,0.31,1) if button != _buttons[_selection] else Color(1,1,1,1)
		just_moved = false

func pressed(id):
	if id == 0:
		var map = load("res://Scenes/Maps/MapManager.tscn").instance()
		map.init("EuviTown", Vector2(-6,-11))
		get_tree().root.add_child(map)
		get_tree().root.remove_child(self)
		self.call_deferred("free")
	elif id == 3:
		get_tree().quit()
	else:
		$Nope.play()

