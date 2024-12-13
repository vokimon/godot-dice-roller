## A Control holding an actionable Dice Roller
@icon("./dice_roller_control.svg")
class_name DiceRollerControl
extends SubViewportContainer

@export var dice_set: Array[DiceDef] = [
]:
	set(new_value):
		print("updating control dices")
		dice_set = new_value
		if roller:
			roller.dice_set = new_value

@onready var roller: DiceRoller = $SubViewport/DiceRoller
func per_dice_result():
	print("rooller on result", roller)
	if not roller:
		return {}
	return roller.per_dice_result()

signal roll_finnished(int)
signal roll_started()


func roll():
	roller.roll()

func quick_roll():
	roller.quick_roll()

func _ready():
	roller.roll_finnished.connect(
		func(value): roll_finnished.emit(value)
	)
	roller.roll_started.connect(
		func(): roll_started.emit()
	)
	roller.dice_set = dice_set
