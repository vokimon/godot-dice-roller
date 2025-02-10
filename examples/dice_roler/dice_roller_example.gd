extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Temporary hack to avoid small widgets in Android
	if OS.get_name() == "Android":
		theme = preload("res://examples/dice_roler/android_theme.tres")

	%ResultLabel.text = "Ready to Roll"

func _on_roll_button_pressed() -> void:
	%DiceRollerControl.roll() # physics emulation roll

func _on_quick_roll_button_pressed() -> void:
	%DiceRollerControl.quick_roll() # quick rotate roll

func _on_dice_roller_control_roll_finnished(result: int) -> void:
	%ResultLabel.text = "Result: %s"%[result]
	%DicesLabel.text = "%s"%[%DiceRollerControl.per_dice_result()]

func _on_dice_roller_control_roll_started() -> void:
	%ResultLabel.text = "Rolling..."
	%DicesLabel.text = "%s"%[%DiceRollerControl.per_dice_result()]

func _on_edit_dice_set_button_pressed() -> void:
	$DiceSetEditor.set_dice_set(%DiceRollerControl.dice_set)
	$DiceSetEditor.popup_centered()

func _on_dice_set_editor_confirmed() -> void:
	var dice_set = $DiceSetEditor.get_dice_set()
	%DiceRollerControl.dice_set = dice_set
