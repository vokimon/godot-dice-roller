@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return true

func get_property_info(object: Object, name: String) -> Dictionary:
	var props = object.get_property_list()
	for prop in props:
		if prop.name == name:
			return prop
	return {}

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool,
) -> bool:

	var prop_info = get_property_info(object, name)
	if not prop_info:
		return false
	if prop_info.hint != PROPERTY_HINT_RESOURCE_TYPE:
		return false
	# prop_info.class_name is just informed in top level attributes,
	# using hint_string, to work with nested ones.
	if prop_info.hint_string != "DiceShape":
		return false
	var editor = preload("./dice_shape_editor.gd").new()
	editor.setup(name, object.get(name))
	add_property_editor(name, editor)
	return true
