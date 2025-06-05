# Custom shape tutorial

Step by step tutorial on how to add a new dice shape.
It is based on the process followed to add the D12 dice.
Check [its documention](../addons/dice/d12_dice/d12-derivations.md)
for more information about formulas and dimensions.

## Project setup

- Consider grouping all files related to a shape in a separate folder
- Exception: blender files.
    - They crash Godot for CI, and for users not having Blender installed.
    - Place them in the blender/ directory excluded from imports
- For Dices distributed with the addon place them in
    `res://addons/dice_roller/mydice`
- For Dices in your own project, you can place them anywhere but we recommend to join them in a single folder.

## Blender construction

- Start with a default cube of side 2
- In edit mode, select two paralel, segments of a face, right click and subdivide
- Do the same with the rest of the faces, not selecting edges already subdivided
- After that, every face aligned with each axis should have a cut in a different direction
- Still in edit mode, select the newly created division edges
- In the header bar, set Pivot point to Individual Origins
- In the header bar, Set Transformation Orientation to Global -> Normal
- Scale (S) 0.618 (golden ratio - 1 = (1+sqrt(5))/2 -1) = (sqrt(5)-1)/2
- Grab (G) Z 0.618
- This will generate a dodecahedron with:
    - 2/phi as side (1.236)
    - 2phi as the width
    - 2sqrt(3) as the diagonal
    - There is an edge crossing every axis
- Reset the Pivot point and Transformation orientation
- Rotate in order to have resting face down (and a selected face up)
    - Rotate along the axis (X or Y) the lower edge is oriented up to
    - Since Dihedral angle dha is 116.565°  (180-116.565)/2 = 31,7175
        - a R X 31,7175 (yes, from edit mode 'a' to rotate all vertexes)
- Determine the scale:
    - We are using a d6 of sides 2 of reference
    - Real sets d6 is 16mm while d12 have 8mm of edge size, a half
    - Current side is 2/phi so in order to be 2/2 = 1, we should scale by phi/2=0.8090169943749474
    - Also from edit mode selecting all the vertexes "aS0.8090169943749474"
    - Either scale in edit mode, or apply the transform afterward.
- UV map
    - Mark the seams
        - In edit mode/ edge, select all edges
        - unselect the ones on top and botton and one of the median edges, connecting the lower and upper sides
        - Menu UV/Mark seam
    - Generate map
        - 'a' to select all the geometry
        - Uv/Unwrapp/Conformal 
        - Go to the UV Workspace
        - In edit mode, select all the geometry
        - rotate the uvmap in increments of 90 and 72 degrees with two purposes:
            - having some pentagons oriented (4) with the writing orientation
            - the figure extends on the diagonal so it can be escaled
        - scale the uvmap to maximize the covered area
    - Once satisfied: UV/Export UV Layout
        - choose SVG as format
        - place it in the `d12_dice` folder
        - name it d12-blueprint.svg
- Bevel
    - Back to the Layout workspace, Object mode
    - Modifiers pannel, Add Modifier, Bevel
    - Edges 3, amount 0.1m
- Rename objects to be accessible in Godot
    - Object mode, F2 (rename)
    - Rename "Cube" object -> "DiceMesh"
- Export
    - Select the dice
    - File/Export/GLTF
    - In the saving options
        - Include / Limit To / selected objects
        - Transform / +Y up (for godot compatibility
        - Mesh: Apply Modifiers, UV's, Normals
        - Material / Material -> Placeholder
        - Consider clicking "Remember Export Settings"


## Engravings inkscape

- Copy d12-layout.svg as d12-texture.svg
- Open d12-texture.svg
- Move all the layout to a layer Layout
- Add a white box as background in its own layer at the bottom
- Create a new layer for the numbers
- Use the align tool Cn-sh-A to center the text on the faces (select first the face, then the content)
- Use the transform tool Cn-sh-M to rotate the numbers +-36 degrees in a controlled way
- When the text is done, copy the layer with the text, select all the copied texts and Path/Object to Path
- Hide the layout and the original text layer before saving


## Godot import

- Move the glb and the texture layout to a folder for all the d12 files
    - but `.blend` since it gives problems if you don't have it installed
    - In your app just create a folder for it.
    - Integrated in `addons/dice_roller/dice/dice_d12/`
- Select the glb file in the godot file browser
- Select the Import tab (besides scene tree tab) and change
    - Root Type to "Dice"
    - Root Name to "d12"
    - Click on "Reimport"
    - Add
- Right click the glb file and select "New inherited Scene"
- Right click the root of the scene "Extend Script"
    - name it `d12_dice.gd` in the `d12_dice` folder
    - Ensure the base class is "Dice"
- Provide minimal metadata:
    ```
    @icon("./d12_dice-icon.svg")
    class_name D12Dice
    extends Dice

    static func icon() -> Texture2D:
        return preload('./d12_dice.svg')

    static func scene() -> PackedScene:
        return preload("./d12_dice.tscn")
    ```
- Collider:
    - Open the 3D view. Menu Mesh/Create Collision Shape
    - Select Placement: Sibbling and Type: Single Convex
    - Rename the new shape to "CollisionShape3D" -> "Collider" (important for the code to work)
- Material
    - Click on DiceMesh
    - Geometry/Material Override (not Overlay!) / New Standar Material
    - Material Override / Albedo /Texture/ Load and select the d12-texture.svg

- Normals: indicate which are the normal orientations of each face
    - 
- Face orientations indicate how to align the highlight with the face (which way is up) to rotate it around the normal.

- Highlight
    - Create a sub node named FaceHighligth (sic. with the typo)
    - Inside FaceHighligth create a MeshInstance3D named Mesh
    - Mesh -> New Cylinder Mesh (for regular polygons as faces)
        - Adjust Radial segments to the number of sides of the faces
        - Reduce the height to have a coin proportion
        - As material, load `addons/dice_roller/dice/highlight_material.tres`
    - Initial transforms:
        - Transform/Rotate X 90 (or -90) To make it face the z axis (in godot, front)
            - The Dice class will orientate the z axis to the normal of the selected face
        - Scale it So that it is a little bigger than an actual face
        - Translate aproximately toward z, more or less, the height of the dice
        - Translation and scale will be fine adjusted later, but good initial guesses help.



## Scale, face normals and highlight orientation


Faces are regular pentagons of size l.
The height of the pentagon is:

    h = l * sqrt(5+2*sqrt(5))/2 ~= 1.539 l

Faces intersect at dha = 116.565°.




By expliting the shape symmetrically aligned with one of the edges,
If we put two oposite faces horizontally,
faces adjacents to the top one are at elevation 116.565 - 90 = 26.565°
Azimuths are just multiples or 360/5=72°.
Lower half faces normals and orientations are just
the opposites of the ones on top.

Distance from an edge to the center is phi.


Proportions:

- https://crystalmaggie.com/pages/dice-size-chart
    - 16mm cube -> 19mm height dodecahedron
- https://www.etsy.com/listing/781780501/dnd-dice-d20-dice-set-dd-dice-table-game?ga_order=most_relevant&pro=1
    - 14mm cube -> 20mm width dodecahedron
    - width is the width of the pentagon formed by the widths of the pentagons on one side.
    - the width of a pentagon is the segment connecting two further edges.
    - the width of the faces is 1 (they are the edges of the original cube to generate the dodecahedron
- 






2h = sqrt(phi² + 1/phi² ) = sqrt( (sqrt(5)+1)^2 + (sqrt(5)-1)^2 ) / 2
 = sqrt( (sqrt(5)+1)^2 + (sqrt(5)-1)^2 ) / 2
 = sqrt( (sqrt(5)+1)^2 + (sqrt(5)-1)^2 ) / 2
 = sqrt(6)


(a+1)² + (a-1)^2 = 2(a^2 + 1)







