@icon("./dice/d6_dice/d6_dice_icon.svg")
class_name DiceDef
extends Resource

@export var name: String
@export var color: Color = Color.ANTIQUE_WHITE
@export_enum("D6:6", "D4:4") var sides = 6
