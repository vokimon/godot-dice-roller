@icon("./d4_dice.svg")
class_name D4Dice
extends Dice

"""
An equilateral rectangle has height: side * sqrt(1² - 1/2²) = side * sqrt(3)/2 = side * 0,8660254037844386
The prism has its base centered on X axis, with the height pointing +Y, centered as the enclosing rectangle
The center of the equilateral triangle is 1/3 of the triangle height.
The center of the rectangle will be placed at 1/2
It should be moved vertically +1/2 - 1/3 = +1/6 of the side
Tetrahedron edges are diagonals of the 2m side square, so they are 2*sqrt(2) = 2,828427124746190
height = 2,598076211353316 ~= 2.6
"""

static func icon() -> Texture2D:
	return preload('./d4_dice.svg')

static func scene() -> PackedScene:
	return preload("./d4_dice.tscn")

func _init():
	sides = {
		1: Vector3(+1,-1,-1),
		2: Vector3(-1,-1,+1),
		3: Vector3(+1,+1,+1),
		4: Vector3(-1,+1,-1),
	}
	highlight_orientation = {
		1: sides[2],
		2: sides[3],
		3: sides[4],
		4: sides[1],
	}
	super()

func _ready():
	var collider_points = []
	for point in sides.values():
		collider_points.append(dice_size/2.0 * point)
	collider.shape.points = collider_points
	var hl: Node3D = $FaceHighligth
	hl.rotate_y(deg_to_rad(120))
	var hlmesh: PrismMesh = $FaceHighligth/Mesh.mesh
	var hlinstance: MeshInstance3D = $FaceHighligth/Mesh
	hlinstance.position.y = hlmesh.size.y / 6.0
	super()
	mass = mass / 4 # tetraedron is a qu artrof a cube
