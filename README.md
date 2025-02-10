# godot-dice-roller

A Godot UI control that rolls 3D dices in a box.

![Screenshot Landscape](screenshots/example-landscape.png)

## Features

* Configurable setup:
    - Dynamic set of dices: d4, d6 and d10
    - Custom colors for each dice
    - Configurable box size and color

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

## Usage

- Install the addon in your project from the AssetLib
    - Exclude files outside `addons/` to avoid conflicts
- Enable the plugin in the project settings
- Insert a `DiceRollerControl` as part of your UI
    - Depending on the layout you might want to set a minimum size
- Trigger a roll by calling `roll()` method on the control.
    - You can alternativelly use the `quick_roll() to skip physics simulation
    - You can also enable the `interactive` flag to roll on click or quickroll on right-click
- Connect the `rollFinished(value)` to your code
    - Use the incoming value from the signal as the overall value or use the `result()` method
    - You can also use the `per_dice_result()` to get individuals values for each dice
- You can represent external rolls with 


![Screenshot Portrait](screenshots/example-portrait.png)
![Screenshot Dice set editor](screenshots/example-editor.png)


