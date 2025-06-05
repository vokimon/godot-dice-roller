
## Usage

* Install the addon in your project from the AssetLib
    - Exclude files outside `addons/` to avoid conflicts
* Enable the plugin in the project settings
* Insert a `DiceRollerControl` as part of your UI
    - Depending on the layout you might want to set a minimum control size
    - Setup the dice set attribute with some dices
    - You might want to adapt the box size to the number of dices to avoid rolls impossible to fit in
* Trigger a roll by calling `roll()` method on the control.
    - Alternativelly, use the `quick_roll() to skip physics simulation
    - Also you may enable the `interactive` flag to roll on click or quickroll on right-click
* Connect the `rollFinished(value)` to your code
    - Use the incoming value from the signal as the added value or use the `result()` method
    - You can also use the `per_dice_result()` to get individual values for each dice
* You can emulate external rolls with  `show_faces(result)`


