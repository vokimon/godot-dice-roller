# Custom shape tutorial

Step by step tutorial on how to add a new dice shape.
It is based on the process followed to add the D12 dice.
Check [its documention](../addons/dice_roller/dice/d12_dice/d12-derivations.md)
for more information about formulas and dimensions.

## Project setup

- Consider grouping all files related to a shape in a separate folder
- Exception: blender files.
    - They crash Godot for CI, and for users not having Blender installed.
    - Place them in the blender/ directory excluded from imports
- For Dices distributed with the addon place them in
    `res://addons/dice_roller/dice/mydice`
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


## Icon and face engravings with inkscape

Icon:

- The icon will represent your dice shape when choosing one in a dice set.
- Just take one of the icons and export the same size and keep same margins
- Godot has problems with fonts in inkscape svg, so if you have any text:
    - Copy the text
    - Move the original to a hiden layer (in case you want to modify it later)
    - Turn the copy into a path (Path/Object to Path)

Face engravings:

- Copy d12-blueprint.svg as d12-texture.svg
- Open d12-texture.svg
- Move all the blueprint to a layer Layout, to hide it later
- Add a white box as background in its own layer at the bottom
- Create a new layer for the numbers
- Use the align tool Cn-sh-A to center the text on the faces (select first the face, then the content)
- Use the transform tool Cn-sh-M to rotate the numbers +-36 degrees in a controlled way
- When the text is done, copy the layer with the text, select all the copied texts and Path/Object to Path
- Hide the blueprint and the original text layer before saving


## Godot import

- Move the glb and the texture blueprint to a folder for all the d12 files
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

## Registration

If the dice is part of this add-on, you have to add the class
in the `DiceShape._registry` dictionary in:

https://github.com/vokimon/godot-dice-roller/blob/78e8a1ea4e6c59878cdd91079e1009d466f41019/addons/dice_roller/dice_shape.gd#L11

```python
static var _registry: Dictionary[String, Script] = {
    ...
	'D12': D12Dice, # You add this one
    ...
}
```


Else, if the dice is part of your own project using this add-on,
just ensure you register your class in a early moment of your setup.

In this case, in the `_init` method of your game, or your autoload scripts.

```python
    D12Dice.register()
```

And then, in `d12_dice.gd`

```python
static func register():
    DiceShape.register("D12", D12Dice)
```

You can test it works, because your dice will be available as option
to choose in either a DiceRoller a DiceRollerController
or in the Dice Set Editor in the Example.


## Collider

- Open the 3D view. Menu Mesh/Create Collision Shape
- Select Placement: Sibbling and Type: Single Convex
- Rename the new shape to "CollisionShape3D" -> "Collider" (important for the code to work)

## Material

- Click on DiceMesh in the scene
- Geometry/Material Override (not Overlay!) / New Standar Material
- Material Override / Albedo /Texture/ Load and select the d12-texture.svg

## Normals and highlight orientation

- `_init`, should define `sides` and `highlight_orientation`, and afterwards call `super`
- They are both dictionaries with the face value as key.
- `sides` contains the normal of each face
- `highlight_orientation` contain the up direction when aligning the highlight to the normal
- If you don't know which normals correspond to each face number
    - Assign them randomly and we will adjust later
    - for the `highlight_orientation` just ensure they are not colinear with their normal
        - colinear orientation and normal generates random orientation which are hard to debug
    - Adjust normals by rolling and swaping the shown value with the result value.

## Highlight

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
- Adjust the `highlight_orientation` vectors so that the highlight is properly oriented with the selected face
- Adjust translation and scale of `Mesh` to show around the face
    - Do not adjust using FaceHighligth, since those transforms will be used to orientate it towards the face.


