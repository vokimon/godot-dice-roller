@icon("./dice_roller.svg")
extends Node3D
class_name DiceRoller
const DiceScene = preload("../dice/dice.tscn")

@export var dice_definitions: Dictionary = {
	'red': {
		'color': Color.FIREBRICK,
	},
	'yellow': {
		'color': Color.GOLDENROD,
	},
}:
	set(new_value):
		dice_definitions = new_value
		reload_dices()

@export var fast_roll := false

const roller_width := 10
const roller_height := 8
const launch_height := Dice.dice_size * 5.0
## Margin away from the walls when repositioning
const margin = 1.0

## Dices in the roller
var dices := []
## Accomulated result as a map dice name -> final value
var result := {}
## Wheter the dices are rolling
var rolling := false

## Emits the final value once the roll has finished
signal roll_finnished(value: int)

var total_value:=0 :
	get:
		var total := 0
		for dice_name in result:
			total += result[dice_name]
		return total

func roll():
	result = {}
	rolling = true
	for dice in dices:
		dice.roll()

func prepare():
	for dice in dices:
		dice.stop()

func _init() -> void:
	reload_dices()

func clear_dices():
	for dice in dices:
		remove_child(dice)
	dices = []

func reload_dices():
	clear_dices()
	for dice_name: String in dice_definitions:
		add_dice(dice_name, dice_definitions[dice_name].color)
	reposition_dices()

func add_dice(dice_name, dice_color):
	var dice = DiceScene.instantiate()
	dice.name = dice_name
	dice.dice_color = dice_definitions[dice_name].color
	dice.roll_finished.connect(_on_finnished_dice_rolling.bind(dice_name))
	add_child(dice)
	dices.append(dice)

func reposition_dices():
	## Positions the dices evenly distributed along the roller
	const span = roller_width - margin * 2
	var dice_interval = span/2./dices.size()
	var dice_x = -span/2. + dice_interval
	for dice in dices:
		dice.position = Vector3(dice_x, launch_height, 0.0)
		dice_x += dice_interval*2

func _on_finnished_dice_rolling(number: int, dice_name: String):
	## One dice communicates has finished its rolling
	result[dice_name] = number
	print("Dice done: ", dice_name, " value ", number)
	if result.size() < dices.size():
		# Not all dices finished
		return
	print("Roll finished: ", result, " -> ", total_value)
	rolling = false
	roll_finnished.emit(total_value)

func _input(event: InputEvent) -> void:
	if rolling: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			prepare()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			roll()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			show_faces([randi_range(1,6), randi_range(1,6)])

func show_faces(faces: Array[int]):
	"""Shows given faces by rotating them up"""
	result={}
	rolling = true
	for i in range(faces.size()):
		dices[i].show_face(faces[i])
