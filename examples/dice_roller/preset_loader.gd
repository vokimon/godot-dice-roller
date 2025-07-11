extends AcceptDialog
class_name PresetLoader

## A dialog to choose a saved dice set to load.

const delete_icon := DiceSetEditor.delete_icon
const diceset_dir = DiceSetEditor.diceset_dir
enum {
	BUTTON_DELETE,
}

@onready var tree := $VBoxContainer/ItemList
signal preset_selected(preset_name: String)

var preset_list : Dictionary[String, Array] = {}

func _ready() -> void:
	tree.button_clicked.connect(_on_tree_button_clicked)
	tree.item_selected.connect(_on_item_selected)
	#tree.item_edited.connect(_on_tree_item_edited)
	reload()

func reload():
	load_presets()
	update_tree()

func load_presets():
	preset_list = {}
	for file in DirAccess.get_files_at(diceset_dir):
		if not file.ends_with('.diceset'):
			continue
		var preset_name := file.trim_suffix('.diceset')
		var diceset = read_preset(preset_name)
		preset_list[preset_name] = diceset

func update_tree():
	tree.hide_root = true
	tree.column_titles_visible = true
	tree.clear()
	var root = tree.create_item()
	tree.columns = 1
	tree.select_mode = Tree.SELECT_ROW
	tree.set_column_title(0, "Presets")

	for preset_name in preset_list:
		var preset : Array[DiceDef] = preset_list[preset_name]
		var item : TreeItem = tree.create_item(root)
		item.set_text(0, preset_name)
		var i = 1
		for dice in preset:
			if i >= tree.columns:
				tree.columns = i+1
				tree.set_column_expand(i, false)
			item.set_cell_mode(i, TreeItem.CELL_MODE_ICON)
			item.set_icon(i, dice.shape.icon())
			item.set_icon_max_width(i, 32)
			item.set_icon_modulate(i, dice.color)
			i+=1
	tree.columns +=1
	for item: TreeItem in tree.get_root().get_children():
		item.set_cell_mode(tree.columns-1, TreeItem.CELL_MODE_ICON)
		item.add_button(tree.columns-1, delete_icon, BUTTON_DELETE, false, "Remove")

func _on_tree_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
	match id:
		BUTTON_DELETE:
			var preset_name = item.get_text(0)
			delete_preset(preset_name)
			item.free()

func delete_preset(preset_name: String):
	var diceset_file := diceset_dir.path_join(preset_name + ".diceset")
	var error := DirAccess.remove_absolute(diceset_file)
	if error:
		print(error_string(error))

func _on_item_selected():
	var item : TreeItem = tree.get_selected()
	var preset_name = item.get_text(0)
	preset_selected.emit(preset_name)

func read_preset(preset_name):
	var config = ConfigFile.new()
	config.load(diceset_dir.path_join(preset_name + ".diceset"))
	var dice_set = config.get_value('default','dice_set')
	return dice_set
