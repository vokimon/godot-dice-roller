@icon("./d10_dice.svg")
class_name D10Dice
extends Dice

static func icon() -> Texture2D:
	return preload('./d10_dice.svg')

static func scene() -> PackedScene:
	return preload("./d10_dice.tscn")

const face_elevation_radians := deg_to_rad(50.0)
func face_orientation(sector: int):
	var azimuth := sector * TAU / 5.0
	var elevation := deg_to_rad(39.0)
	return Vector3(
		+ cos(elevation) * sin(azimuth),
		+ sin(elevation),
		+ cos(elevation) * cos(azimuth),
	)

func _generate_faces():
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

func _init():
	_generate_faces()
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
	build_highlight()
	super()
	mass = mass / 4. # tetraedron is a qu artrof a cube

func build_highlight():
	var hl: Node3D = $FaceHighligth
	var hlinstance: MeshInstance3D = $FaceHighligth/Mesh
	var mesh: ArrayMesh = hlinstance.mesh
	var primitive = []
	primitive.resize(Mesh.ARRAY_MAX)
	var d := -0.18
	var n := +1.
	var m := -0.78
	var s := -1.18
	var w := +0.8
	var tex_fact := 0.15
	primitive[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3(+0.0, n, d),
		Vector3(+w, m, d),
		Vector3(-w, m, d),
		Vector3(+0.0, s, d),
	])
	primitive[Mesh.ARRAY_TEX_UV] = PackedVector2Array([
		tex_fact * Vector2(+0.0, n),
		tex_fact * Vector2(+w, m),
		tex_fact * Vector2(-w, m),
		tex_fact * Vector2(+0.0, s),
	])
	primitive[Mesh.ARRAY_INDEX] = PackedInt32Array([
		1, 0, 3, 2,
	])
	primitive[Mesh.ARRAY_NORMAL] = PackedVector3Array([
		Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, -1.0),
		Vector3(0.0, 0.0, -1.0),
	])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, primitive)
	
