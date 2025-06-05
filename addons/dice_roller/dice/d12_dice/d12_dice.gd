@icon("./d12-icon.svg")
class_name D12Dice
extends Dice

"""
A D12 is a regular dodecahedron.
See d12-derivations.md for more information.
"""

static func icon() -> Texture2D:
	return preload('./d12-icon.svg')

static func scene() -> PackedScene:
	return preload("./d12_dice.tscn")

const cose = 2.0/sqrt(5.0)
const sine = 1.0/sqrt(5.0)
func face_orientation(sector: int):
	if not sector:
		return Vector3.UP
	var azimuth := sector * TAU / 5.0
	return Vector3(
		+ cose * sin(azimuth),
		+ sine,
		+ cose * cos(azimuth),
	)

func _generate_faces():
	sides = {
		1:  +face_orientation(0),
		3:  +face_orientation(1),#
		11: +face_orientation(2),#
		9:  +face_orientation(3),#
		7:  +face_orientation(4),#
		5:  +face_orientation(5),
		12: -face_orientation(0),
		10: -face_orientation(1),
		2:  -face_orientation(2),
		4:  -face_orientation(3),
		6:  -face_orientation(4),
		8:  -face_orientation(5),
	}

func _init():
	_generate_faces()
	highlight_orientation = {}
	for value in sides:
		highlight_orientation[value] = Vector3.UP * sign(sides[value].y)
	highlight_orientation[1] = Vector3.BACK
	highlight_orientation[12] = Vector3.FORWARD
	super()
