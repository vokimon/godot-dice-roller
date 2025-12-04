@icon("./dice_roller.svg")
extends Node3D
class_name DiceRoller

## Margin away from the walls when repositioning
const margin = 1.0
const launch_height := Dice.dice_size * 5.0
const default_set := {
	'red': {
		'color': Color.FIREBRICK,
	},
	'yellow': {
		'color': Color.GOLDENROD,
	},
}

@export var dice_set: DiceSet:
	set(new_value):
		if rolling:
			await roll_finished
		dice_set = new_value
		if is_node_ready():
			reload_dice()

@export var roller_color := Color.DARK_GREEN:
	set(new_value):
		roller_color = new_value
		if $RollerBox/CSGBox3D:
			$RollerBox/CSGBox3D.material.albedo_color = new_value

@export var roller_size := Vector3(9, 12, 5):
	set(new_value):
		roller_size = new_value
		if $RollerBox/CSGBox3D:
			$RollerBox.width = new_value.x
			$RollerBox.height = new_value.y
			$RollerBox.depth = new_value.z
			reload_dice()
@export var interactive := false

## Emits the final value once the roll has finished
signal roll_finished(value: int)
## Emits the final value when the roll starts
signal roll_started()

## Dice in the roller
var rollerDice := []
## Accomulated result as a map rollerDice name -> final value
var result := {}
## Wheter the rollerDice are rolling
var rolling := false

func _ready() -> void:
	$RollerBox/CSGBox3D.material.albedo_color = roller_color
	$RollerBox.width = roller_size.x
	$RollerBox.height = roller_size.y
	$RollerBox.depth = roller_size.z

func per_dice_result() -> Dictionary:
	return result

var total_value:=0 :
	get:
		var total := 0
		for dice_name in result:
			total += result[dice_name]
		return total

func set_default_dice_set():
	var new_dice_set := DiceSet.new()
	for key in default_set:
		var dice = DiceDef.new()
		dice.name = key
		dice.color = default_set[key].color
		dice.shape = DiceShape.new("D6")
		new_dice_set.dice.append(dice)
	self.dice_set = new_dice_set

func ensure_valid_and_unique_dice_names():
	var used_names: Dictionary = {}
	for die in dice_set.dice:
		var name_prefix := die.name if die.name and len(die.name) else "rollerDice"
		var dice_name := name_prefix
		for i in range(len(result)+1, 100):
			if dice_name not in used_names:
				break
			dice_name = name_prefix+"{0}".format([i])
		used_names[dice_name] = true
		die.name = dice_name

func roll():
	if rolling: return
	result = {}
	rolling = true
	for die in rollerDice:
		die.roll()
	roll_started.emit()

func prepare():
	if rolling: return
	for die in rollerDice:
		die.stop()

func _init() -> void:
	reload_dice()

func clear_dice():
	for die in rollerDice:
		remove_child(die)
	rollerDice = []

func reload_dice():
	if not dice_set or dice_set.dice.is_empty():
		return set_default_dice_set()
	clear_dice()
	ensure_valid_and_unique_dice_names()
	for dieDef: DiceDef in dice_set.dice:
		#print("reloading rollerDice: ", rollerDice, rollerDice.shape)
		add_dice_scene(dieDef)
	reposition_dice()

func add_dice_scene(dice: DiceDef):
	var packed_scene: PackedScene
	if not dice.shape:
		push_warning("Shapeless dice def ", dice.name)
		packed_scene = DiceShape.new("D6").scene()
	else:
		packed_scene = dice.shape.scene()
	var scene = packed_scene.instantiate()
	scene.name = dice.name
	scene.dice_color = dice.color
	scene.roll_finished.connect(_on_finished_dice_rolling.bind(dice))
	add_child(scene)
	rollerDice.append(scene)

func dice_arrangement(ndice: int, width: float, height: float) -> Vector2i:
	""" Given an aspect ratio and a number of rollerDice returns
	the number of rows and columns to best organize the rollerDice.
	"""
	# ndice <= rows * cols =
	# = ( cols * height / width ) * cols =
	# = cols *  cols * height / width
	# cols >= sqrt( ndice * width / height )
	# column_center = -w/2 + w/cols * (1 + 2*i)/2 = w/2 (-1 + (2*i+1)/cols)
	var first_cols: int = ceil(sqrt(ndice*width/height))
	var rows: int = ceil(ndice/float(first_cols))
	# If we are using the row, fully use it
	var cols: int = ceil(ndice/float(rows))
	return Vector2i(cols, rows)

func reposition_dice():
	""" Position rollerDice evenly distributed along the roller """
	var span_x := roller_size.x - margin * 2
	var span_z := roller_size.z - margin * 2
	var arrangement: Vector2i = dice_arrangement(rollerDice.size(), span_x, span_x)
	var cols: int = arrangement.x
	var rows: int = arrangement.y
	var last_row_cols: int = rollerDice.size()%cols if rollerDice.size()%cols else  cols
	for i in range(rollerDice.size()):
		var dice = rollerDice[i] # TODO: use polymorphism
		var col: int = i%cols
		var row: int = floor(float(i)/cols)
		# Center last row with less columns
		var actual_cols = last_row_cols if row == rows-1 else cols
		var dice_x : float = -span_x/2 + span_x/actual_cols * (0.5 + col)
		var dice_z : float = -span_z/2 + span_z/rows * (0.5 + row)
		dice.position = Vector3(dice_x, launch_height, dice_z)
		dice.original_position = dice.position

func _on_finished_dice_rolling(number: int, dice: DiceDef):
	## One rollerDice communicates has finished its rolling
	var value = number
	if number == 0:
		if DiceShape.shapes_to_sides[dice.shape.name] == DiceShape.DiceSides.D10x10:
			# A '00' on a D10x10 is 100
			value = 100
		elif DiceShape.shapes_to_sides[dice.shape.name] == DiceShape.DiceSides.D10:
			# A '0' on a D10 is 10
			value = 10
	result[dice.name] = value
	#print("Dice done: ", dice_name, " value ", number)
	if result.size() < rollerDice.size():
		# Not all rollerDice finished
		return
	#print("Roll finished: ", result, " -> ", total_value)
	rolling = false
	roll_finished.emit(total_value)

func _input(event: InputEvent) -> void:
	if rolling: return
	if not interactive: return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			prepare()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			roll()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			quick_roll()

func quick_roll():
	"""Turn rollerDice toward computer generated random values (non-physics)"""
	var values: Array[int] = []
	for dice: Dice in rollerDice:
		var dice_values := dice.sides.keys()
		var chosen = dice_values[randi_range(0, dice_values.size()-1)]
		values.append(chosen)
	show_faces(values)
	roll_started.emit()

func show_faces(faces: Array[int]):
	"""Shows given faces by rotating them up"""
	if rolling: return
	assert(faces.size() == rollerDice.size())
	result={}
	rolling = true
	for i in range(faces.size()):
		rollerDice[i].show_face(faces[i])
