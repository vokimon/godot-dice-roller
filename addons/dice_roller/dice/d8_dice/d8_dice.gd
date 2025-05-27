@icon("./d8_dice.svg")
class_name D8Dice
extends Dice

"""
A d8 dice is an octohedron, a square bipyramid with equilateral triangles as sides.
Faces of a d8 are equilateral triangles of side l.
The apotheme of the piramids is the height of the triangles: a² = l² - l²/2² = l² 3/4
The height of the pyramids is h² = a² - l²/2² = l² 3/4 - l²/2² = l²/2 ; [ h = l / sqrt(2) ]
We placed the vertex of the base square on (+-1, 0, +-1),
Then l=2 and h = 2/sqrt(2) = sqrt(2)
and the remaining vertexes are in (0, +-h, 0).
Face normals are in (+-h,+-1,0) and (0,+-1,+-h)
"""

func _init():
	var h := sqrt(2)
	sides = {
		2: Vector3(+h,+1,+0).normalized(),
		6: Vector3(-h,+1,+0).normalized(),
		4: Vector3(+0,+1,+h).normalized(),
		5: Vector3(+0,+1,-h).normalized(),
		3: Vector3(+h,-1,+0).normalized(),
		7: Vector3(-h,-1,+0).normalized(),
		1: Vector3(+0,-1,+h).normalized(),
		8: Vector3(+0,-1,-h).normalized(),
	}
	for side in sides.keys():
		highlight_orientation[side] = Vector3.DOWN if sides[side].y < 0.0 else Vector3.UP
	super()
