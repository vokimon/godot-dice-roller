@icon("./d10x10_dice.svg")
class_name D10x10Dice
extends D10Dice

static func icon() -> Texture2D:
	return preload('./d10x10_dice.svg')

static func scene() -> PackedScene:
	return preload("./d10x10_dice.tscn")

func _generate_faces():
	sides = {
		50: +face_orientation(+2),
		30: +face_orientation(+1),
		70: +face_orientation(+0),
		10: +face_orientation(-1),
		90: +face_orientation(-2),
		40: -face_orientation(+2),
		60: -face_orientation(+1),
		20: -face_orientation(+0),
		80: -face_orientation(-1),
		0:  -face_orientation(-2),
	}
