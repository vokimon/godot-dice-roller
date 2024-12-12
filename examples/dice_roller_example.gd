extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ResultLabel.text = "Ready to Roll"

func _on_roll_button_pressed() -> void:
	%DiceRollerControl.roll()

func _on_quick_roll_button_pressed() -> void:
	%DiceRollerControl.quick_roll()

func _on_dice_roller_control_roll_finnished(result: int) -> void:
	%ResultLabel.text = "Result: %s"%[result]
	%DicesLabel.text = "%s"%[%DiceRollerControl/SubViewport/DiceRoller.result]

func _on_dice_roller_control_roll_started() -> void:
	%ResultLabel.text = "Rolling..."
	%DicesLabel.text = "%s"%[%DiceRollerControl/SubViewport/DiceRoller.result]
