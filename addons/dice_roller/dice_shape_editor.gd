@tool
extends EditorProperty

var option_button := OptionButton.new()

func _init():
	add_child(option_button)
	update_options()
	option_button.connect("item_selected", _on_item_selected)

func _on_item_selected(index):
	var selected = option_button.get_item_text(index)
	#print("Emiting ", get_edited_property(), " ", DiceShape.new(selected))
	emit_changed(get_edited_property(), DiceShape.new(selected), "", true)

func update_options():
	option_button.clear()
	for shape in DiceShape.options():
		var icon := DiceShape.icon_for_shape(shape)
		option_button.add_icon_item(icon, shape)

func _set_read_only(read_only: bool):
	option_button.disabled = read_only

func get_index_by_text(text: String) -> int:
	for i in option_button.get_item_count():
		if option_button.get_item_text(i) == text:
			return i
	return -1  # not found

func update_property():
	var value := get_edited_object().get(get_edited_property())
	set_control_value(value)

func _set(property: StringName, value: Variant) -> bool:
	#print("- ", property, " = ", value)
	return false

func setup(property_name: String, initial_value: DiceShape) -> void:
	update_options()
	set_control_value(initial_value)

func set_control_value(value: DiceShape):
	if value == null:
		#print("Null value arrived to the control for ", get_edited_object())
		return
	#print("Setting the control to the value ", value, " ", value.name)
	var idx := get_index_by_text(value.name)
	if idx >= 0:
		option_button.selected = idx
