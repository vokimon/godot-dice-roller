## A Control holding an actionable Dice Roller
@tool
@icon("./dice_roller_control.svg")
class_name DiceRollerControl
extends SubViewportContainer

const dice_roller_scene = preload("../dice_roller/dice_roller.tscn")

## The set of dice to be thrown. If empty, a default set will be used.
@export var dice_set: DiceSet:
	set(new_value):
		dice_set = new_value
		if not roller:
			return
		roller.dice_set = new_value
		# Synchronize back in case the roller modifies it (e.g. adds default dice)
		if dice_set != roller.dice_set:
			dice_set = roller.dice_set

## Color of the rolling box
@export var roller_color: Color = Color.DARK_GREEN:
	set(new_value):
		roller_color = new_value
		if roller:
			roller.roller_color = new_value

## Box roller size. x and z are width and depth of the floor, y is the ceiling.
##
## Small floors may not let the dice to finnish the roll.
## Big floors make dice look so small.
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

## Triggered when a roll simulation starts
signal roll_started()
## Triggered once the roll animation finishes
signal roll_finished(int)

var roller: DiceRoller = null
var viewport: SubViewport = null

func _init():
	# Expand the viewport to cover the control
	stretch = true

func _ready() -> void:
	if Engine.is_editor_hint():
		# In the editor, children might already exist from a previous run.
		for c in get_children():
			if c is SubViewport:
				c.queue_free()
	viewport = SubViewport.new()
	add_child(viewport)
	roller = dice_roller_scene.instantiate()
	viewport.add_child(roller)

	# In the editor, the roller's script might not be fully parsed when we
	# try to connect signals. Awaiting `ready` ensures it's safe.
	if Engine.is_editor_hint():
		await roller.ready

	roller.roll_finished.connect(roll_finished.emit)
	roller.roll_started.connect(roll_started.emit)
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

## Rotate the dice to an externally given result
func show_faces(result: Array[int]):
	roller.show_faces(result)

## Returns a dictionary with individual dice results,
## having dice names as keys
func per_dice_result():
	if not roller:
		return {}
	return roller.per_dice_result()
