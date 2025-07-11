class_name DiceSetEditor
extends ConfirmationDialog

@onready var tree : Tree = $Tree
@onready var shapes_popup := $SidesPopup
@onready var color_popup := $ColorPopup
@onready var color_picker := $ColorPopup/ColorPicker
@onready var preset_name_edit := $PresetNameDialog/MarginContainer/VBoxContainer/PresetNameEdit
@onready var diceset_preview := $PresetNameDialog/MarginContainer/VBoxContainer/DicesetPreview
@onready var preset_loader := $PresetLoader

const delete_icon := preload("./delete-icon.svg")
const color_icon := preload('./color-icon.svg')
const diceset_dir = "user://dicesets_v1/"
var load_button : Button
var save_button : Button
var preset_list : Array[String] = []

enum {
	BUTTON_DELETE,
	BUTTON_ADD,
}

enum {
	COL_ICON,
	COL_SHAPE,
	COL_COLOR,
	COL_ID,
	COL_REMOVE,
}

func _ready() -> void:
	setup_dice_list()
	setup_preset()

## Preset methods

func setup_preset():

	load_button = add_button("Load", false, "Load")
	save_button = add_button("Save", false, "Save")
	custom_action.connect(_on_custom_action)

	preset_loader.preset_selected.connect(_on_preset_loader_selected)
	preset_name_edit.text_submitted.connect(save_preset)

func _on_custom_action(action: String):
	match action:
		"Save":
			ask_preset_name()
		"Load":
			preset_loader.reload()
			preset_loader.show()

func ask_preset_name():
	for old_dice_icon in diceset_preview.get_children():
		old_dice_icon.free()
	for dicedef in get_dice_set():
		var icon_control := TextureRect.new()
		icon_control.texture = dicedef.shape.icon()
		icon_control.modulate = dicedef.color
		diceset_preview.add_child(icon_control)
	preset_name_edit.text = ''
	$PresetNameDialog.popup_centered()
	preset_name_edit.grab_focus()

func save_preset(preset_name: String):
	$PresetNameDialog.hide()
	DirAccess.make_dir_recursive_absolute(diceset_dir)
	var dice_set := get_dice_set()
	var config = ConfigFile.new()
	config.set_value('default','dice_set', dice_set)
	config.save(diceset_dir.path_join(preset_name + ".diceset"))

#func load_preset(preset_id: int):
#	var preset_name = preset_list[preset_id]
#	load_preset(preset_name)

func _on_preset_loader_selected(preset_name: String):
	var dice_set = read_preset(preset_name)
	if not dice_set: return
	set_dice_set(dice_set)
	preset_loader.hide()

func read_preset(preset_name):
	var config = ConfigFile.new()
	config.load(diceset_dir.path_join(preset_name + ".diceset"))
	var dice_set = config.get_value('default','dice_set')
	return dice_set

## Dice list methods

func setup_dice_list():
	for shape_name: String in DiceShape.options():
		shapes_popup.add_icon_item(DiceShape.icon_for_shape(shape_name), shape_name)
	shapes_popup.index_pressed.connect(_on_shape_popup_index_pressed)
	color_picker.color_changed.connect(_on_color_picker_changed)

	var _root := tree.create_item()
	tree.set_column_expand(COL_ICON, 0)
	tree.set_column_title(COL_SHAPE, "Sides")
	tree.set_column_expand(COL_SHAPE, 0)
	tree.set_column_title(COL_COLOR, "Color")
	tree.set_column_expand(COL_COLOR, 0)
	tree.set_column_title(COL_ID, "Name")
	
	tree.button_clicked.connect(_on_tree_button_clicked)
	tree.item_edited.connect(_on_tree_item_edited)
	add_add_row()
	add_dice_row(DiceShape.new("D6"), Color.CORAL, 'coral dice')
	add_dice_row(DiceShape.new("D4"), Color.FIREBRICK, 'red dice')

func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
	match id:
		BUTTON_DELETE:
			item.free()
		BUTTON_ADD:
			add_dice_row(DiceShape.new("D6"), Color.ANTIQUE_WHITE, "Dice")

func _on_tree_item_edited():
	var item := tree.get_edited()
	var column := tree.get_edited_column()
	#print("item edited: ", item, " column ", column)
	match column:
		COL_COLOR:
			color_picker.color = item.get_metadata(COL_COLOR)
			var target_rect = tree.get_screen_transform()*tree.get_custom_popup_rect()
			color_popup.popup_on_parent(target_rect)
		COL_SHAPE:
			var target_rect = tree.get_screen_transform()*tree.get_custom_popup_rect()
			shapes_popup.popup_on_parent(target_rect)

func _on_color_picker_changed(color: Color):
	var item := tree.get_edited()
	item.set_metadata(COL_COLOR, color)
	item.set_icon_modulate(COL_COLOR, color)
	item.set_icon_modulate(COL_ICON, color)

func _on_shape_popup_index_pressed(index):
	var shape_name = shapes_popup.get_item_text(index)
	var item := tree.get_edited()
	item.set_text(COL_SHAPE, shape_name)
	item.set_icon(COL_ICON, DiceShape.icon_for_shape(shape_name))

func add_add_row():
	var root := tree.get_root()
	var item := tree.create_item(root)
	item.set_expand_right(COL_ICON, true)
	item.add_button(COL_ICON, preload("./add-icon.svg"), BUTTON_ADD)

func add_dice_row(shape: DiceShape, color: Color, id: String):
	#print("Adding dice row: ", shape, " ", color, " ", id)
	var root := tree.get_root()
	var item := tree.create_item(root, root.get_child_count()-1) # left the add row the last
	
	item.set_icon(COL_ICON, shape.icon() if shape else null)
	item.set_icon_max_width(COL_ICON, 32)
	item.set_icon_modulate(COL_ICON, color)

	item.set_cell_mode(COL_SHAPE, TreeItem.CELL_MODE_CUSTOM)
	item.set_text(COL_SHAPE, shape.to_string() if shape else "--")
	item.set_editable(COL_SHAPE, true)
	item.set_text_alignment(COL_SHAPE, HORIZONTAL_ALIGNMENT_CENTER)

	item.set_cell_mode(COL_COLOR, TreeItem.CELL_MODE_CUSTOM)
	item.set_icon(COL_COLOR, color_icon)
	item.set_icon_modulate(COL_COLOR, color)
	item.set_metadata(COL_COLOR, color)
	item.set_editable(COL_COLOR, true)

	item.set_text(COL_ID, id)
	item.set_editable(COL_ID, true)

	item.add_button(COL_ID, delete_icon, BUTTON_DELETE, false, "Remove")

func get_dice_set() -> Array[DiceDef]:
	var dice_set: Array[DiceDef] = []
	var root := tree.get_root()
	for item in root.get_children():
		if not item.get_metadata(COL_COLOR):
			continue
		var def = DiceDef.new()
		def.name = item.get_text(COL_ID)
		def.color = item.get_metadata(COL_COLOR)
		def.shape = DiceShape.new(item.get_text(COL_SHAPE))
		dice_set.append(def)
	#print(dice_set)
	return dice_set

func clear_dice_set():
	var root := tree.get_root()
	for item in root.get_children():
		if not item.get_metadata(COL_COLOR):
			continue
		item.free()

func set_dice_set(dice_set : Array[DiceDef]):
	clear_dice_set()
	for dice in dice_set:
		add_dice_row(dice.shape, dice.color, dice.name)
