# D12 (Regular Dodecahedron)

In common sets, the side is half (8mm) of the side of a d6 (16mm).
For the derivation just consider convenient vertex locations and later we will scale and rotate:

Cannonical vertex location: (+-1, +-1, +-1), (0, +-phi, +-1/phi), (+-1/phi, 0, +-phi), (+-phi, +-1/phi, 0).

Being phi = (1+sqrt(5))/2 ≃ 1.618, and 1/phi=(sqrt(5)-1)/2 ≃ 0.618

For these vertex locations we obtain the following distances:

- **Side:** length for every edge

	l = 2 / phi = sqrt(5)-1 ≃ 1.236

- **Width:** distance between opposite edges

	w = 2 * phi = sqrt(5)+1 ≃ 3.236

- **Diagonal:** distance between opposite vertexes

	D = 2 sqrt(3) ≃ 3.4641

- **Pentagon height:** Longest segment within a face

	H = sqrt((5+2 sqrt(5)) / phi²) = sqrt(phi+2) ≃ 1.902

- **Height:** distance between opposite faces)

	h = 2 sqrt((+4phi +3 ) /5) ≃ 2.753

In summary:

| Parameter | Model (l=2/phi)      |  Approx   | Normalized (l=1)    | Aprox   | Real (l=8 mm)|
|-----------|----------------------|-----------|---------------------|---------|--------------|
| l         | 2/phi                | 1.236     | 1                   | 1       | 8 mm         |
| h         | 2 sqrt((4 phi +3)/5) | 2.753     | sqrt((11 phi +7)/5) | 2.227   | 17.82 mm     |
| w         | 2 phi                | 3.236     | phi +1              | 2.618   | 20.96 mm     |
| D         | 2 sqrt(3)            | 3.464     | phi * sqrt(3)       | 2.80    | 22.4 mm      |
| H         | sqrt(phi +2)         | 1.902     | sqrt(phi +3/4)      | 1.5388  | 12.31 mm     |

## Derived from canonical vertex distances

Distance from vertex to the center:

	(+-1, +-1, +-1)
		sqrt(1²+1²+1²) = sqrt(3)
	(0, +-phi, +-1/phi), (+-1/phi, 0, +-phi), (+-phi, +-1/phi, 0)
		sqrt(phi² + 1/phi² + 0)
		= sqrt(phi +1 + (phi-1)²)
		= sqrt(phi +1 + phi² -2phi +1)
		= sqrt(phi +1 + phi +1 -2phi +1)
		= sqrt(3)

Diagonal is twice this distance.

Distance between two adjacent vertex (edge/side length):
	
	|(0, +phi, +1/phi) - (0, +phi, -1/phi)| = 2/phi

Distance between two oposites edges (width):

	|(0, +phi, +1/phi) - (0, -phi, +1/phi)| = 2 phi


## Pentagon height (H) derivation

Canonical

	H = l sqrt(5+2sqrt(5))/2 [from formula]
	H = (2/phi) sqrt((5+2sqrt(5))/4)
	H = (2/phi) sqrt(3/4+ (2+2sqrt(5))/4)
	H = (2/phi) sqrt(3/4+ (1+sqrt(5))/2)
	H = (2/phi) sqrt(3/4 + phi)
	H = (2/phi) sqrt((3-4)/4 + phi +1)
	H = (2/phi) sqrt(phi² - 1/4)
	H = 2 sqrt((1+1/2phi)(1-1/2phi))
	H = 2 sqrt((1+(phi-1)/2)(1-(phi-1)/2))
	H = 2 sqrt(((phi+1)/2)((3-phi)/2))
	H = sqrt((phi+1)(3-phi))
	H = sqrt(-phi -1 +3phi +3 -phi)
	H = sqrt(phi +2)
	H = sqrt(phi² +1)

Normalized:

	H = sqrt(phi +2) l phi/2
	H = l sqrt(phi +2) phi/2
	H = l sqrt((phi +2)(phi +1)) /2
	H = l sqrt(4phi +3) /2
	H = l sqrt(phi +3/4)
	H = l sqrt(phi² -1/4)

## Height (h) derivation

An axial symmetric section by one of the vertes l results in an irregular hexagon
with 4 sides H and 2 sides l, that can be descomposed as:
- A rectangle of sides l and w, and diagonal D
- Two isosceles trianges of base w, legs H

The height of the dice matches the height of the rectangle diagonal tilted by
alpha (the angle of the diagonal to the w side of the rectangle)
plus beta (the base angle of the isosceles triangle)

 	h = D sin(alpha + beta) =
	= D sin(alpha)cos(beta) + D cos(alpha)sin(beta)

Where:

	D sin(alpha) = l = 2 / phi = sqrt(5) - 1
	D cos(alpha) = w = 2 phi = sqrt(5) + 1
	cos(beta) = w/(2H) = 2/sqrt(5)  = phi/sqrt(phi^2+1)
	sin(beta) = sqrt(1 - w²/4H²) = sqrt(1-4/5) = 1/sqrt(5)

Then

	h = 2(1+phi)/sqrt(1+phi²)
	h = 2(phi²)/sqrt(1+phi²)
	h = 2(phi²)sqrt(1+phi²)/(1+phi²)
	h = 2(phi +1)sqrt(1+phi²)/(1+phi²)
	h = 2 sqrt((phi +1)^2(1+phi²))/(1+phi²)
	h = 2 sqrt((phi^2 + 2phi +1)(1+phi²))/(1+phi²)
	h = 2 sqrt((phi +1 + 2phi +1)(1+phi²))/(1+phi²)
	h = 2 sqrt((3phi +2)(1+phi²))/(1+phi²)
	h = 2 sqrt((3phi +2)(phi+2))/(1+phi²)
	h = 2 sqrt(3phi² + 6phi + 2phi +4)/(1+phi²)
	h = 2 sqrt(3phi + 3 + 6phi + 2phi +4)/(1+phi²)
	h = 2 sqrt(11phi + 7)/(1+phi²)  
	h = 2 sqrt(11phi + 7) (3-phi) /5  using [ 1/(1+phi^2) = (3-phi)/5 ]
	h = 2 sqrt((11phi + 7) (3-phi)^2) /5
	h = 2 sqrt((11phi + 7) (phi^2 -6phi +9)) /5
	h = 2 sqrt((11phi + 7) (phi +1 -6phi +9)) /5
	h = 2 sqrt((11phi + 7) (-5phi +10)) /5
	h = 2 sqrt((11phi + 7) (-phi +2)/5)
	h = 2 sqrt((-11phi -11 +22phi -7phi +14 ) /5)
	h = 2 sqrt((+4phi +3 )/5)

The normalized one is

	h/l = phi * sqrt((+4phi +3 )/5)
	= sqrt(phi² (+4phi +3 )/5)
	= sqrt((phi + 1) (+4phi +3 )/5)
	= sqrt((4phi² + 3phi + 4phi +3)/5)
	= sqrt((4phi +4 + 3phi + 4phi +3)/5)
	= sqrt((11 phi +7)/5)
  

## Canonical to normalized transform

- Rotate on x acos(1/sqrt(5)) ≃ 31,7175 degrees
- Scale phi/2 ≃ 0.809017

## Face normals

For the unrotated canonical dodecahedron, normals are
{(±1,±2,0), (±2,0,±1), (0,±1,±2)} normalized with sqrt(5)

For the rotated dodecahedron, with two horizontal faces.
Top is obviously up, adjacents to top have an elevation of arcos(1/sqrt(5)) ≃ 63.435
and azimuths rotating on intervals of tau/5.
Faces facing down are the oposites of the ones facing up.

## Numbering

The dice is split in two hemispheres one with odd numbers and other with even ones.
Oposites always add to 13 = 1+12 = 3+10 = 5+8 = 7+6 = 9+4 = 11+2
12 and 1 are in the poles and the rest are setup arround it in counter clockwise order:
2, 4, 6... and 3, 5, 7...
