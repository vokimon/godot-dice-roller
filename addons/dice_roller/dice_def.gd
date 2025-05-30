@icon("./dice/d6_dice/d6_dice_icon.svg")
class_name DiceDef
extends Resource

@export var name: String

@export var color: Color = Color.ANTIQUE_WHITE

@export var shape: DiceShape: #  = DiceShape.new("D6")
	set(value):
		print ("DiceDef setting shape to: ", value)
		shape=value
	get():
		return shape
## @deprecated use `shape` instead

@export_storage var sides: int:
	set(value):
		print("DiceDef setting sides to ", sides, " for ", name)
		if value:
			shape = DiceShape.from_sides(value)
	get():
		# zero means migrated
		print("asking for sides")
		return 0

func _to_string() -> String:
	return "DiceDef('"+ name + "' " + str(shape) + " "  + str(color) + ")"
