@icon("./dice/d6_dice/d6_dice_icon.svg")
class_name DiceDef
extends Resource

## This name will be used to refer the dice in a Dice Set
@export var name: String = "Dice"

## The albedo color of the dice
@export var color: Color = Color.ANTIQUE_WHITE

## The shape of the dice.
## It must be one of the keys a Dice Shape is registered on.
@export var shape: DiceShape = DiceShape.new("D6"):
	set(value):
		print ("DiceDef ", name, " set shape to: ", value)
		shape=value
	get():
		print("DiceDef ", name, " get shape: ", shape)
		return shape

## @deprecated use `shape` instead
@export_storage var sides: int = 0:
	set(value):
		print("DiceDef setting sides to ", sides, " for ", name)
		if value:
			shape = DiceShape.from_sides(value)
			sides = 0
	get():
		# zero means migrated
		print("DiceDef " + name + " get sides: " + str(sides))
		return sides

func _init():
	print("DiceDef init: ", self)
	if sides != 0:
		self.sides = sides # force migration to shape

func _set(property: StringName, value: Variant) -> bool:
	print("DiceSet _set: ", property, value)
	return false

func _to_string() -> String:
	return "DiceDef('"+ name + "' " + str(shape) + " "  + str(color) + " " + str(sides) + ")"
