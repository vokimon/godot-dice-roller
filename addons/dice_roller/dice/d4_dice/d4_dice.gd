@icon("./d4_dice.svg")
class_name D4Dice
extends Dice

func _init():
	sides = {
		1: Vector3(+1,-1,-1),
		2: Vector3(-1,-1,+1),
		3: Vector3(+1,+1,+1),
		4: Vector3(-1,+1,-1),
	}
	super()

func _ready():
	var collider_points = []
	for point in sides.values():
		collider_points.append(dice_size/2.0 * point)
	collider.shape.points = collider_points
	super()
	mass = mass / 4 # tetraedron is a quarter of a cube
