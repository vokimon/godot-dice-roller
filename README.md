# godot-dice-roller

A Godot UI control that rolls 3D dices in a box.

![Screenshot Landscape](screenshots/example-landscape.png)

## Features

* Configurable setup:
    - Dynamic set of dices including d4, d6, d8, d10, d10x10, d20
    - Easy dice customization (color, shapes, engraving, material...)
    - Configurable rolling box size and color

* 3 ways to roll:
    - Physics based dice rolling (slow but cool)
    - Turning dices to a computer generated random value (faster but unnatural)
    - Turning dices to a given value (useful when the actual rolling is done remotely)

* Easy to integrate in your code:
    - Trigger rolling programmatically from buttons or shortcuts
    - A signal notifies after the rolling
    - Obtain results for individual dices or add up.

* Responsive to layouts:
    - The control adapts to the available space given by the layout
    - Whichever the resulting size, the camera adapts the zoom to fully see the rolling box floor
    - Automatically rotates the rolling box if the control aspect ratio is inverse to the one of the box


Documentation: https://github.com/vokimon/godot-dice-roller/blob/main/docs


![Screenshot Portrait](screenshots/example-portrait.png)
![Screenshot Dice set editor](screenshots/example-editor.png)
![Screenshot Dice set editor](screenshots/example-allshapes.png)
![Screenshot Dice set editor](screenshots/example-poker.png)


