@icon("./dice/d6_dice/d6_dice_icon.svg")
class_name DiceDef
extends Resource

@export var name: String
@export var color: Color = Color.ANTIQUE_WHITE
@export_range(6,6) var sides: int = 6
