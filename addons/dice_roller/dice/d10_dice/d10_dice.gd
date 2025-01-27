@icon("./d10_dice.svg")
class_name D10_dice
extends Dice

const face_elevation_radians := deg_to_rad(50.0)
func face_orientation(sector: int):
	var azimuth := sector * TAU / 5.0
	var elevation := deg_to_rad(40.0)
	return Vector3(
		+ cos(elevation) * sin(azimuth),
		+ sin(elevation),
		+ cos(elevation) * cos(azimuth),
	)


func _init():
	sides = {
		5: +face_orientation(+2),
		3: +face_orientation(+1),
		7: +face_orientation(+0),
		1: +face_orientation(-1),
		9: +face_orientation(-2),
		4: -face_orientation(+2),
		6: -face_orientation(+1),
		2: -face_orientation(+0),
		8: -face_orientation(-1),
		0: -face_orientation(-2),
	}
	highlight_orientation = {}
	for value in sides:
		highlight_orientation[value] = Vector3.UP * sign(sides[value].y)
	super()

"""
An equilateral rectangle has height: side * sqrt(1² - 1/2²) = side * sqrt(3)/2 = side * 0,8660254037844386
The prism has its base centered on X axis, with the height pointing +Y, centered as the enclosing rectangle
The center of the equilateral triangle is 1/3 of the triangle height.
The center of the rectangle will be placed at 1/2
It should be moved vertically +1/2 - 1/3 = +1/6 of the side
Tetrahedron edges are diagonals of the 2m side square, so they are 2*sqrt(2) = 2,828427124746190
height = 2,598076211353316 ~= 2.6
"""

func _ready():
	#var hl: Node3D = $FaceHighligth
	#hl.rotate_y(deg_to_rad(120))
	#var hlmesh: PrismMesh = $FaceHighligth/Mesh.mesh
	#var hlinstance: MeshInstance3D = $FaceHighligth/Mesh
	#hlinstance.position.y = hlmesh.size.y / 6.0
	super()
	mass = mass / 4. # tetraedron is a qu artrof a cube
