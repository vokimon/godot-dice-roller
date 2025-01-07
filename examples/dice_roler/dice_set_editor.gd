class_name DiceSetEditor
extends ConfirmationDialog

@onready var tree : Tree = $Tree
@onready var faces_popup := $FacesPopup
@onready var color_popup := $ColorPopup
@onready var color_picker := $ColorPopup/ColorPicker

enum {
	BUTTON_DELETE,
	BUTTON_ADD,
}

enum {
	COL_ICON,
	COL_FACES,
	COL_COLOR,
	COL_ID,
	COL_REMOVE,
}

func _ready() -> void:
	for faces in DiceDef.icons:
		faces_popup.add_icon_item(DiceDef.icons[faces], str(faces), faces)
	faces_popup.id_pressed.connect(_on_popup_faces_id_pressed)
	
	color_picker.color_changed.connect(_on_color_picker_changed)

	var _root := tree.create_item()
	tree.set_column_expand(COL_ICON, 0)
	tree.set_column_title(COL_FACES, "Faces")
	tree.set_column_expand(COL_FACES, 0)
	tree.set_column_title(COL_COLOR, "Color")
	tree.set_column_expand(COL_COLOR, 0)
	tree.set_column_title(COL_ID, "Name")
	tree.button_clicked.connect(_on_tree_button_clicked)
	tree.item_edited.connect(_on_tree_item_edited)
	add_add_row()
	add_dice_row(6, Color.CORAL, 'coral dice')
	add_dice_row(4, Color.FIREBRICK, 'red dice')

func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
	match id:
		BUTTON_DELETE:
			item.free()
		BUTTON_ADD:
			add_dice_row(6, Color.ANTIQUE_WHITE, "Dice")

func _on_tree_item_edited():
	var item := tree.get_edited()
	var column := tree.get_edited_column()
	print("item edited: ", item, " column ", column)
	match column:
		COL_COLOR:
			color_picker.color = item.get_metadata(COL_COLOR)
			color_popup.popup_on_parent(tree.get_custom_popup_rect())
		COL_FACES:
			faces_popup.popup_on_parent(tree.get_custom_popup_rect())

func _on_color_picker_changed(color: Color):
	var item := tree.get_edited()
	item.set_metadata(COL_COLOR, color)
	item.set_icon_modulate(COL_COLOR, color)
	item.set_icon_modulate(COL_ICON, color)

func _on_popup_faces_id_pressed(id):
	var faces = str(id)
	var item := tree.get_edited()
	item.set_metadata(COL_FACES, id)
	item.set_text(COL_FACES, faces)
	item.set_icon(COL_ICON, DiceDef.icons[id])

func add_add_row():
	var root := tree.get_root()
	var item := tree.create_item(root)
	item.set_expand_right(COL_ICON, true)
	item.add_button(COL_ICON, preload("./add-icon.svg"), BUTTON_ADD)

func add_dice_row(faces: int, color: Color, id: String):
	var root := tree.get_root()
	var item := tree.create_item(root, root.get_child_count()-1) # left the add row the last

	item.set_icon(COL_ICON, DiceDef.icons[faces])
	item.set_icon_max_width(COL_ICON, 32)
	item.set_icon_modulate(COL_ICON, color)

	item.set_cell_mode(COL_FACES, TreeItem.CELL_MODE_CUSTOM)
	item.set_metadata(COL_FACES, faces)
	item.set_text(COL_FACES, str(faces))
	item.set_editable(COL_FACES, true)
	item.set_text_alignment(COL_FACES, HORIZONTAL_ALIGNMENT_CENTER)

	item.set_cell_mode(COL_COLOR, TreeItem.CELL_MODE_CUSTOM)
	item.set_icon(COL_COLOR, preload('./color-icon.svg'))
	item.set_icon_modulate(COL_COLOR, color)
	#item.set_custom_bg_color(COL_COLOR, color)
	item.set_metadata(COL_COLOR, color)
	item.set_editable(COL_COLOR, true)

	item.set_text(COL_ID, id)
	item.set_editable(COL_ID, true)

	item.add_button(COL_ID, preload("./delete-icon.svg"), BUTTON_DELETE, false, "Remove")

func get_dice_set() -> Array[DiceDef]:
	var dice_set: Array[DiceDef] = []
	var root := tree.get_root()
	for item in root.get_children():
		if not item.get_metadata(COL_COLOR):
			continue
		var def = DiceDef.new()
		def.name = item.get_text(COL_ID)
		def.color = item.get_metadata(COL_COLOR)
		def.sides = item.get_metadata(COL_FACES)
		dice_set.append(def)
	print(dice_set)
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
		add_dice_row(dice.sides, dice.color, dice.name)
