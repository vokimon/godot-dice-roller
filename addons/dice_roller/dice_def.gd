@icon("./dice/d6_dice/d6_dice.svg")
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
		shape=value
	get():
		return shape

## @deprecated use `shape` instead
@export_storage var sides: int = 0:
	set(value):
		if value:
			push_warning("Migrating legacy DiceDef named ", name, ": sides attribute was ", value)
			shape = DiceShape.from_sides(value)
			sides = 0 # zero means migrated
	get():
		return sides

func _init():
	if sides != 0:
		self.sides = sides # force migration to shape

func _to_string() -> String:
	return "DiceDef('"+ name + "' " + str(shape) + " "  + str(color) + ")"
