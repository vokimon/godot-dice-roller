# godot-dice-roller

A Godot UI control that rolls 3D dices in a box.

![Screenshot Landscape](screenshots/example-landscape.png)

## Features

* Configurable setup:
    - Dynamic set of dices (all dices of 6 faces, by now)
    - Custom colors for each dice
    - Configurable box size

* 3 ways to roll:
    - Physics based dice rolling (slow but cool)
    - Turning dice to a computer generated random value (faster but unnatural)
    - Turning dice to a given value (useful when the actual rolling is done remotely)

* Easy to integrate in your code:
    - Trigger rolling programmatically from buttons or shortcuts
    - A signal notifies after the rolling
    - Then you can extract the overall value or the specific face value for each dice

* Responsive to layouts:
    - The control adapts to the available space given by the layout
    - Whichever the resulting size, the camera adapts the zoom to fully see the rolling box floor
    - Automatically rotates the rolling box if the control aspect ratio is inverse to the one of the box

![Screenshot Portrait](screenshots/example-portrait.png)


