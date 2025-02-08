@icon("./dice/d6_dice/d6_dice_icon.svg")
class_name DiceDef
extends Resource

@export var name: String
@export var color: Color = Color.ANTIQUE_WHITE
@export_enum("D6:6", "D4:4", "D10:10", "D10x10:100", "D20:20") var sides = 6

const icons =  {
	4: preload("res://addons/dice_roller/dice/d4_dice/d4_dice.svg"),
	6: preload("res://addons/dice_roller/dice/d6_dice/d6_dice.svg"),
	10: preload("res://addons/dice_roller/dice/d10_dice/d10_dice.svg"),
	100: preload("res://addons/dice_roller/dice/d10_dice/d10x10_dice.svg"),
	20: preload("res://addons/dice_roller/dice/d20_dice/d20_dice.svg"),
}
