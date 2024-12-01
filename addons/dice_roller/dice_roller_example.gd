extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ResultLabel.text = "Ready to Roll"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_roll_button_pressed() -> void:
	%ResultLabel.text = "Rolling..."
	%DiceRollerControl.roll()


func _on_dice_roller_control_roll_finnished(result: int) -> void:
	%ResultLabel.text = "Result: %s %s"%[result, %DiceRollerControl/SubViewport/DiceRoller.result]
