@icon("./dice_roller.svg")
extends Node3D
class_name DiceRoller
const DiceScene = preload("../dice/dice.tscn")

const defaultSet := {
	'red': {
		'color': Color.FIREBRICK,
	},
	'yellow': {
		'color': Color.GOLDENROD,
	},
}

@export var dice_set: Array[DiceDef] = []:
	set(new_value):
		print("Updating roller dices")
		if rolling:
			await roll_finnished
		dice_set = new_value
		reload_dices()

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
## Emits the final value when the roll starts
signal roll_started()

var total_value:=0 :
	get:
		var total := 0
		for dice_name in result:
			total += result[dice_name]
		return total

func ensure_any_dice_set():
	if dice_set:
		return
	var new_set: Array[DiceDef] = []
	for name in defaultSet:
		var dice = DiceDef.new()
		dice.name = name
		dice.color = defaultSet[name].color
		new_set.append(dice)
	dice_set = new_set

func ensure_valid_and_unique_dice_names():
	var used_names: Dictionary = {}
	for dice in dice_set:
		var name_prefix := dice.name if dice.name and len(dice.name) else "dice"
		var dice_name := name_prefix
		for i in range(len(result)+1, 100):
			if dice_name not in used_names:
				break
			dice_name = name_prefix+"{0}".format([i])
		used_names[dice_name] = true
		dice.name = dice_name

func roll():
	if rolling: return
	result = {}
	rolling = true
	for dice in dices:
		dice.roll()
	roll_started.emit()

func prepare():
	if rolling: return
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
	ensure_any_dice_set()
	ensure_valid_and_unique_dice_names()
	for dice: DiceDef in dice_set:
		add_dice_escene(dice)
	reposition_dices()

func add_dice_escene(dice: DiceDef):
	var scene = DiceScene.instantiate()
	scene.name = dice.name
	scene.dice_color = dice.color
	scene.roll_finished.connect(_on_finnished_dice_rolling.bind(dice.name))
	add_child(scene)
	dices.append(scene)

func dices_arrangement(ndices: int, width: float, height: float) -> Vector2i:
	""" Given an aspect ratio and a number of dices returns
	the number of rows and columns to best organize the dices.
	"""
	# ndices <= rows * cols =
	# = ( cols * height / width ) * cols =
	# = cols *  cols * height / width
	# cols >= sqrt( ndices * width / height )
	# column_center = -w/2 + w/cols * (1 + 2*i)/2 = w/2 (-1 + (2*i+1)/cols)
	var first_cols: int = ceil(sqrt(ndices*width/height))
	var rows: int = ceil(ndices/float(first_cols))
	# If we are using the row, fully use it
	var cols: int = ceil(ndices/float(rows))
	return Vector2i(cols, rows)

func reposition_dices():
	""" Position dices evenly distributed along the roller """
	const span_x := roller_width - margin * 2
	const span_z := roller_height - margin * 2
	var arrangement: Vector2i = dices_arrangement(dices.size(), span_x, span_x)
	var cols: int = arrangement.x
	var rows: int = arrangement.y
	var last_row_cols: int = dices.size()%cols if dices.size()%cols else  cols
	print("{0} X {1} {2}".format([cols, rows, last_row_cols]))
	for i in range(dices.size()):
		var dice: Dice = dices[i]
		var col: int = i%cols
		var row: int = floor(i/cols)
		# Center last row with less columns
		var actual_cols = last_row_cols if row == rows-1 else cols
		var dice_x : float = -span_x/2 + span_x/actual_cols * (0.5 + col)
		var dice_z : float = -span_z/2 + span_z/rows * (0.5 + row)
		dice.position = Vector3(dice_x, launch_height, dice_z)
		dice.original_position = dice.position

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
			quick_roll()

func quick_roll():
	"""Turn dices toward computer generated random values (non-physics)"""
	var values: Array[int] = []
	for dice in dice_set:
		values.append(randi_range(1, dice.sides))
	show_faces(values)
	roll_started.emit()

func show_faces(faces: Array[int]):
	"""Shows given faces by rotating them up"""
	if rolling: return
	assert(faces.size() == dices.size())
	result={}
	rolling = true
	for i in range(faces.size()):
		dices[i].show_face(faces[i])
