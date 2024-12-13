## A Control holding an actionable Dice Roller
@tool
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

func per_dice_result():
	print("rooller on result", roller)
	if not roller:
		return {}
	return roller.per_dice_result()

signal roll_finnished(int)
signal roll_started()

var roller: DiceRoller = null
var viewport: SubViewport = null

const dice_roller_scene = preload("../dice_roller/dice_roller.tscn")

func _init():
	stretch = true
	viewport = SubViewport.new()
	add_child(viewport)
	roller = dice_roller_scene.instantiate()
	viewport.add_child(roller)

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
