[![CI Status](https://github.com/vokimon/godot-dice-roller/actions/workflows/runtests.yaml/badge.svg)](https://github.com/vokimon/godot-dice-roller/actions/workflows/runtests.yaml)
[![Last Release](https://img.shields.io/github/release/vokimon/godot-dice-roller.svg?logo=github)](https://github.com/vokimon/godot-dice-roller/releases/latest)
[![Itch.io](https://img.shields.io/badge/itch.io-%23FF0B34.svg?logo=Itch.io&logoColor=white)](https://vokimon.itch.io/godot-dice-roller)
<!-- [![Get it on F-Droid](https://img.shields.io/f-droid/v/net.canvoki.godot_dice_roller.svg?logo=F-Droid)](https://f-droid.org/packages/net.canvoki.godot_dice_roller) -->
<!-- [![Flathub](https://img.shields.io/flathub/v/net.canvoki.godot_dice_roller?label=Flathub&logo=flathub&logoColor=white)][] -->

# godot-dice-roller

A Godot UI control that rolls 3D dices in a box.

![Screenshot Landscape](screenshots/example-landscape.png)

## Features

* Configurable setup:
    - Dynamic set of dices including d4, d6, d8, d10, d10x10, d12, d20
    - Easy dice customization (color, shapes, engraving, material...)
    - Configurable rolling box size and color

* 3 ways to roll:
    - Physics emulated rolling (slow but cool)
    - Turn to random generated values (faster but unrealistic)
    - Turn to given values (useful when the actual rolling is done remotely)

* Easy to integrate in your code:
    - Trigger rolling interactivelly o programmatically
    - A signal notifies after the rolling
    - Obtain results for individual dices or add up.

* Responsive to layouts:
    - The control adapts to the available space given by the layout
    - Whichever the resulting size, the camera adapts the zoom to fully see the rolling box floor
    - Automatically rotates the rolling box if the control aspect ratio is inverse to the one of the box


Documentation: https://github.com/vokimon/godot-dice-roller/blob/main/docs


![Screenshot Portrait](screenshots/example-portrait.png)
![Screenshot Dice set editor](screenshots/example-editor.png)
![Screenshot All avaiable dice shapes](screenshots/example-allshapes.png)
![Screenshot Playing poker](screenshots/example-poker.png)


