extends D6Dice
class_name CustomDiceExample

# Ensure you call this function early in your game
static func register():
	DiceShape.register("Poker", CustomDiceExample)

static func icon() -> Texture2D:
	return preload("./custom_dice_example.png")

static func scene() -> PackedScene:
	return preload("./custom_dice_example.tscn")
