@icon("./d20_dice.svg")
class_name D20Dice
extends Dice

"""
An icosahedron is formed by equilateral triangles.
As such if the side is l, their height will be:
h = sqrt(l^2-(l/2)^2) = l*sqrt(3)/2
By bisectioning an icosahedron with a plane passing
by one of their edges, we have an irregular hexagon
of sides: h h l h h l.

l sides are the ones matching an edge and the h sides
are bisected triangles by their height.
We are interested in the normals of the bisected ones.
Notice that the first two h's are the negated of the
later pair of h's.
In spherical coordinates, the bisecting plane defines
the the azimuth of the normal, and the tilt of the
bisecting segment, the elevation.

e1 = asin(r/h)
e2 = asin((R-r)/h)
h = l * cos(pi/6) = l * sqrt(3)/2 # from equilateral triangle
R = l / (2 * sin(pi/5)) # From the top pentagon
r = R * cos(pi/5) # Also from the pentagon

R-r = l * (1-cos(pi/5)) / (2 * sin(pi/5) )

(R-r)/h = l * (1-cos(pi/5)) / (2 *sin(pi/5)) / l /(sqrt(3) / 2)
(R-r)/h = l * (1-cos(pi/5)) / sin(pi/5) / l /sqrt(3)
(R-r)/h = (1-cos(pi/5)) / ( sqrt(3) * sin(pi/5) )
e2 = asin(1-cos(pi/5)) / ( sqrt(3) * sin(pi/5) )

h = 2 * r * tan(pi/5) * sin(pi/6) = r * tan(pi/5) =
e1 = asin(r/h)
e1 = asin(R * cos(pi/5) / h)    # inline r
e1 = asin(l * cos(pi/5) / (2 * sin(pi/5) * h))    # inline R
e1 = asin(l * cos(pi/5) / (2 * sin(pi/5) * l * sqrt(3) / 2))  # inline h
e1 = asin(cos(pi/5) / (sin(pi/5) * sqrt(3) ))    # l and 2 factors out

Relative size: d6 is 14mm, while d20 is 22mm, so 1.571428571428571
Source: https://www.dice.co.uk/outlines.htm
"""

static func icon() -> Texture2D:
	return preload('./d20_dice.svg')

static func scene() -> PackedScene:
	return preload("./d20_dice.tscn")

func spherical(azimuth: float, elevation: float) -> Vector3:
	return Vector3(
		+ cos(elevation) * cos(azimuth),
		+ sin(elevation),
		+ cos(elevation) * sin(azimuth),
	)

func cap_face_normal(count: int) -> Vector3:
	var elevation := asin(cos(PI/5) / (sqrt(3) * sin(PI/5)))
	var azimuth := 2 * count * PI / 5 + PI
	return spherical(azimuth, elevation)

func mid_face_normal(count: int) -> Vector3:
	var elevation := asin( (1.0-cos(PI/5)) /2.0/sin(PI/5) / cos(PI/6) )
	var azimuth := 2 * count * PI / 5 + PI
	return spherical(azimuth, elevation)

func _init():
	sides = {
		13: +cap_face_normal(-2),
		20: +cap_face_normal(-1),
		12: +cap_face_normal(+0),
		19: +cap_face_normal(+1),
		6:  +cap_face_normal(+2),
		11: +mid_face_normal(-2),
		5:  +mid_face_normal(-1),
		9:  +mid_face_normal(+0),
		3:  +mid_face_normal(+1),
		17: +mid_face_normal(+2),
		14: -cap_face_normal(-2),
		1:  -cap_face_normal(-1),
		8:  -cap_face_normal(+0),
		15: -cap_face_normal(+1),
		7:  -cap_face_normal(+2),
		16: -mid_face_normal(-2),
		10: -mid_face_normal(-1),
		4:  -mid_face_normal(+0),
		18: -mid_face_normal(+1),
		2:  -mid_face_normal(+2),
	}
	highlight_orientation = {
		13: +Vector3.UP,
		20: +Vector3.UP,
		12: +Vector3.UP,
		19: +Vector3.UP,
		6:  +Vector3.UP,
		7:  -Vector3.UP,
		15: -Vector3.UP,
		1:  -Vector3.UP,
		8:  -Vector3.UP,
		14: -Vector3.UP,
		11: +Vector3.DOWN,
		5:  +Vector3.DOWN,
		9:  +Vector3.DOWN,
		3:  +Vector3.DOWN,
		17: +Vector3.DOWN,
		2:  -Vector3.DOWN,
		18: -Vector3.DOWN,
		10: -Vector3.DOWN,
		4:  -Vector3.DOWN,
		16: -Vector3.DOWN,
	}
	super()
