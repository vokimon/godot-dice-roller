## A Control holding an actionable Dice Roller
@tool
@icon("./dice_roller_control.svg")
class_name DiceRollerControl
extends SubViewportContainer

const dice_roller_scene = preload("../dice_roller/dice_roller.tscn")

@export var dice_set: Array[DiceDef] = []:
	set(new_value):
		dice_set = new_value
		if roller:
			roller.dice_set = new_value

@export var roller_color: Color = Color.DARK_GREEN:
	set(new_value):
		roller_color = new_value
		if roller:
			roller.roller_color = new_value

@export var roller_size := Vector3(10, 12, 6):
	set(new_value):
		roller_size = new_value
		if roller:
			roller.roller_size = new_value

func per_dice_result():
	print("rooller on result", roller)
	if not roller:
		return {}
	return roller.per_dice_result()

signal roll_finnished(int)
signal roll_started()

var roller: DiceRoller = null
var viewport: SubViewport = null

func _init():
	# Expand the viewport to cover the control
	stretch = true

func _ready():
	viewport = SubViewport.new()
	add_child(viewport)
	roller = dice_roller_scene.instantiate()
	viewport.add_child(roller)
	roller.roll_finnished.connect(
		func(value): roll_finnished.emit(value)
	)
	roller.roll_started.connect(
		func(): roll_started.emit()
	)
	roller.dice_set = dice_set
	roller.roller_color = roller_color
	roller.roller_size = roller_size

func roll():
	roller.roll()

func quick_roll():
	roller.quick_roll()
