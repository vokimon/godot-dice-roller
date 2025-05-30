@icon("./d8_dice.svg")
class_name D8Dice
extends Dice

"""
A d8 dice is an octohedron, a square bipyramid with equilateral triangles as sides.
Faces of a d8 are equilateral triangles of side l.
Vertex can be aligned with axes: (+-d, 0, 0) (0, +-d, 0) (0, 0, +-d)
Faces normals are (+-1,+-1,+-1)/sqrt(3).
The rest height of the dice should match l, the rest height of d6 (currently 2m!).
The rest height of d8 is the distance between planes of opposing bottom and top faces.
Chossing the planes of faces with all the coords sharing sign: x+y+z=d and x+y+z=-d.
l = |d - (-d)|/sqrt(3) = 2
2d/sqrt(3) = 2
d=sqrt(3)
"""

static func icon() -> Texture2D:
	return preload('./d8_dice.svg')

static func scene() -> PackedScene:
	return preload("./d8_dice.tscn")

func _init():
	var h := sqrt(2)
	sides = {
		4: Vector3(+1,+1,+1).normalized(),
		6: Vector3(-1,+1,+1).normalized(),
		8: Vector3(-1,+1,-1).normalized(),
		2: Vector3(+1,+1,-1).normalized(),
		1: Vector3(+1,-1,+1).normalized(),
		7: Vector3(-1,-1,+1).normalized(),
		5: Vector3(-1,-1,-1).normalized(),
		3: Vector3(+1,-1,-1).normalized(),
	}
	for side in sides.keys():
		highlight_orientation[side] = Vector3.DOWN if sides[side].y < 0.0 else Vector3.UP
	super()
