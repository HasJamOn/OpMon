extends "res://Scenes/Interface/Interface.gd"

# Speed at which the dialog lines are displayed
export var dialog_speed := 10.0

# If the dialog auto-closes when finished
export var close_when_over := true

# Lines of dialog stored as an array
var _dialog_lines: Array

# Index of the current shown dialog line
var _current_dialog_line_index := -1 # -1 since incremented first when calling _start_new_line

# True if the current dialog line is fully printed
var _awaiting_next_dialog_line := false

# Timer for displaying dialog line characters one at a time
var _timer = null

var _dialog_over := false

signal dialog_over

# Sets the dialog lines form a translation key instead of directly setting them.
func set_dialog_key(dialog_key: String):
	_dialog_lines.clear()
	var i := 0
	var line := ""
	line = tr(dialog_key + "_" + str(i))
	while(line != dialog_key + "_" + str(i)):
		_dialog_lines.append(line)
		i+=1
		line = tr(dialog_key + "_" + str(i))

# The "dialog_lines" parameter must be an array of Strings where one element is printed on one dialog.
# Make sure the text is not too long to be shown.
func set_dialog_lines(dialog_lines: Array):
	_dialog_lines = dialog_lines

func reset():
	_current_dialog_line_index = -1 # -1 since incremented first when calling _start_new_line
	_dialog_over = false

func go():
	# Display the first line of dialogue
	_start_new_line();

	# Start the animation of the dial arrow
	$NinePatchRect/DialArrow.get_node("AnimationPlayer").current_animation = "idle"
	$NinePatchRect/DialArrow.get_node("AnimationPlayer").playback_active = true

func _ready():
	if _map_manager != null:
		_map_manager.pause_player() # Pauses the player to prevent the character from moving during the dialog

	# Prepare the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_one_shot(false)
	_timer.set_wait_time(1/dialog_speed)

func _start_new_line():
	_current_dialog_line_index += 1
	$NinePatchRect/DialArrow.visible = false
	_awaiting_next_dialog_line = false
	_timer.start()
	$NinePatchRect/Text.visible_characters = 0
	$NinePatchRect/Text.text = _dialog_lines[_current_dialog_line_index]

func _finish_current_line():
	$NinePatchRect/DialArrow.visible = true
	_awaiting_next_dialog_line = true
	_timer.stop()
	$NinePatchRect/Text.visible_characters = -1 # Sets all characters visible

func _input(event):
	if event.is_action_pressed("dialog_pass") and not _dialog_over:
		if _awaiting_next_dialog_line: # If the current dialog line already is fully printed
			if _current_dialog_line_index < _dialog_lines.size() - 1: # If there is another
				_start_new_line()
			else: # If not, the dialog is over
				_dialog_over = true
				$NinePatchRect/DialArrow.visible = false
				emit_signal("dialog_over")
				if close_when_over:
					close()
		elif $NinePatchRect/Text.visible_characters != 0: # If there is still to print,
			# Print everything, but if there has been a character shown already
			# (else we assume this is an error, the same event counted twice, because it’s too fast)
			_finish_current_line()

func close():
	emit_signal("closed")

func _on_Timer_timeout():
	$NinePatchRect/Text.visible_characters += 1
	# If all characters has been printed
	if $NinePatchRect/Text.visible_characters == _dialog_lines[_current_dialog_line_index].length():
		_finish_current_line()
