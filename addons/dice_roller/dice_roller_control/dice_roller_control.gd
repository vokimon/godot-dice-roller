## A Control holding an actionable Dice Roller
@tool
@icon("./dice_roller_control.svg")
class_name DiceRollerControl
extends SubViewportContainer

const dice_roller_scene = preload("../dice_roller/dice_roller.tscn")

## The set of dices to be thrown. If empty, a default set will be used.
@export var dice_set: Array[DiceDef] = []:
	set(new_value):
		if not roller:
			dice_set = new_value
			return
		roller.dice_set = new_value
		# Roller might change it
		dice_set = roller.dice_set

## Color of the rolling box
@export var roller_color: Color = Color.DARK_GREEN:
	set(new_value):
		roller_color = new_value
		if roller:
			roller.roller_color = new_value

## Box roller size. x and z are width and depth of the floor, y is the ceiling.
##
## Small floors may not let the dices to finnish the roll.
## Big floors make dices look so small.
@export var roller_size := Vector3(9, 12, 5):
	set(new_value):
		roller_size = new_value
		if roller:
			roller.roller_size = new_value

## When true user may start a roll by left clicking
## or a quick roll by right clicking
@export var interactive := true:
	set(new_value):
		interactive = new_value
		if roller:
			roller.interactive = new_value

## Triggered when a roll simumation starts
signal roll_started()
## Triggered once the roll animation finishes
signal roll_finnished(int)

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
	roller.interactive = interactive

## Start a physics simulated roll
func roll():
	roller.roll()

## Start a quick roll, that just rotates to a computer generated result
func quick_roll():
	roller.quick_roll()

## Rotate the dices to a externally given result
func show_faces(result: Array[int]):
	roller.show_faces(result)

## Returns a dictionary with individual dice results,
## having dice names as keys
func per_dice_result():
	if not roller:
		return {}
	return roller.per_dice_result()
