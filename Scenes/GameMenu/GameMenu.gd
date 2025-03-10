extends Interface

var labels := []

var options := ["res://Scenes/GameMenu/TeamManager.tscn", "", "", "", "", ""]

var selection := 0

# Freezes the inputs for the menu while a subinterface is opened
var subinterface_opened := false
# Cooldown after closing a subinterface so a same event is not counted twice
var subinterface_cooldown = -1

var subinterface = null

func _ready():
	labels.append($OpMonLabel)
	labels.append($BagLabel)
	labels.append($OpDexLabel)
	labels.append($IDLabel)
	labels.append($SaveLabel)
	labels.append($SettingsLabel)
	self.rect_position = (Vector2(960,640) / 2) - (self.rect_size / 2)

func _input(event):
	if not subinterface_opened:
		# Conditions on selection are here to avoid warping
		if event.is_action_pressed("ui_accept"):
			subinterface = load(options[selection]).instance()
			subinterface._map_manager = _map_manager
			subinterface_opened = true
			subinterface.connect("closed", self, "close_subinterface")
			$Subinterface.add_child(subinterface)
		elif event.is_action_pressed("menu"):
			emit_signal("closed")
		elif event.is_action_pressed("ui_down") and selection != 4:
			selection += 2
		elif event.is_action_pressed("ui_up") and selection != 1:
			selection -= 2
		elif event.is_action_pressed("ui_left") and selection % 2 == 1:
			selection -= 1
		elif event.is_action_pressed("ui_right") and selection % 2 == 0:
			selection += 1
		if selection < 0:
				selection = 0
		elif selection > 5:
			selection = 5
		$ChoiceRect.rect_position = labels[selection].rect_position
	elif subinterface_cooldown > 0:
		subinterface_cooldown -= 1
	elif subinterface_cooldown == 0:
		subinterface_cooldown -= 1
		subinterface_opened = false
	
func close_subinterface():
	if subinterface != null:
		subinterface.call_deferred("queue_free")
		subinterface = null
		subinterface_cooldown = 5
