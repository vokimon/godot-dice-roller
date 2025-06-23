@tool
extends EditorPlugin

var dice_shape_inspector

func _enter_tree() -> void:
	""" Plugin initialization """
	#print("Reloading plugin")
	add_custom_type("DiceShape", "Resource", preload("./dice_shape.gd"), preload("./dice/d6_dice/d6_dice.svg"))
	dice_shape_inspector = preload("./dice_shape_inspector.gd").new()
	add_inspector_plugin(dice_shape_inspector)

func _exit_tree() -> void:
	""" Clean-up of the plugin goes here."""
	if dice_shape_inspector:
		remove_inspector_plugin(dice_shape_inspector)
	remove_custom_type("DiceShape")
