@icon("./custom_dice_example.svg")
extends D6Dice
class_name CustomDiceExample

"""
This example shows how to inherit an existing Dice
shape, in this case a D6Dice,
and change the face engravings texture.
The scene is a copy of the D6 one, but changing
the texture applied to the material override.

Your application should ensure that this
dice is registered before loading the dice definition.
This registration is done on the _init method
of the main scene of the example, for this example.
"""


# Ensure you call this function early in your game
static func register():
	DiceShape.register("Poker", CustomDiceExample)

static func icon() -> Texture2D:
	return preload("./custom_dice_example.svg")

static func scene() -> PackedScene:
	return preload("./custom_dice_example.tscn")
