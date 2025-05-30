@icon("./d6_dice.svg")
class_name D6Dice
extends Dice

static func icon() -> Texture2D:
	return preload('./d6_dice.svg')

static func scene() -> PackedScene:
	return preload("./d6_dice.tscn")

func _init():
	sides = {
		1: Vector3.LEFT,
		2: Vector3.FORWARD,
		3: Vector3.DOWN,
		4: Vector3.UP,
		5: Vector3.BACK,
		6: Vector3.RIGHT,
	}
	highlight_orientation = {
		1: Vector3.UP,
		2: Vector3.LEFT,
		3: Vector3.FORWARD,
		4: Vector3.RIGHT,
		5: Vector3.DOWN,
		6: Vector3.BACK,
	}
	super()

func _ready():
	#$DiceMesh.mesh.size = dice_size * Vector3.ONE
	#collider.shape.size = dice_size * Vector3.ONE
	super()
