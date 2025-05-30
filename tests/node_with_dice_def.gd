@tool
extends Node3D

@export var my_dicedef: DiceDef = DiceDef.new()

func _init() -> void:
	print("NodeWithDiceDef init:")
	print("- my_dicedef: ", my_dicedef)

func _set(property: StringName, value: Variant) -> bool:
	print("NodeWithDiceDef _set: ", property, value)
	return false

func _ready() -> void:
	print_debug("NodeWithDiceDef ready:", self)
	print_debug("- my_dicedef: ", my_dicedef)
	print_debug("    script: ", my_dicedef.get_script())
