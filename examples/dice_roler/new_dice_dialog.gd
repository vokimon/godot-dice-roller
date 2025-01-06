class_name NewDiceDialog
extends ConfirmationDialog

@export var dice_name := "dice"
@export var dice_color := Color.ANTIQUE_WHITE
@export var dice_faces := 6

const face6_texture : Texture2D = preload("res://addons/dice_roller/dice/d6_dice/d6_dice_icon.svg")

func _ready() -> void:
	pass

func _on_about_to_popup() -> void:
	var face_select: ItemList = $VBoxContainer/GridContainer/SidesEdit
	face_select.clear()
	face_select.add_item("6", face6_texture, true)
	#face_select.add_item("4", face6_texture, false)
	face_select.select(0)
	$VBoxContainer/GridContainer/ColorEdit.color = Color.ANTIQUE_WHITE
	$VBoxContainer/GridContainer/NameEdit.text = "dice"

## Gather dialog information as DiceDef
func dice_def() -> DiceDef:
	var dice = DiceDef.new()
	dice.name = $VBoxContainer/GridContainer/NameEdit.text
	dice.color = $VBoxContainer/GridContainer/ColorEdit.color
	var face_select: ItemList = $VBoxContainer/GridContainer/SidesEdit
	var selected := face_select.get_selected_items()
	dice.sides = int(face_select.get_item_text(selected[0])) if selected else 6
	return dice
