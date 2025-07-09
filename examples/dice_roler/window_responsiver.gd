extends Node
## Resizes the parent (expected to be a Dialog) to fit into the screen when it is resized
class_name WindowResponsiver

## Size for the parent to be expanded if available
@export var size := Vector2i(800,500)

## Changes parent size (suposedly a Dialog) to fit within the viewport

func _ready() -> void:
	resize()
	get_tree().get_root().size_changed.connect(resize)

func resize():
	# KLUDGE: For some reason dialog buttons are not part of the dialog size
	var buttons_adjust  := Vector2i(0, 46)
	var screen_size := get_tree().get_root().size
	var parent : AcceptDialog = get_parent()
	parent.size = size.min(screen_size - buttons_adjust)
	# Also when resized, as Godot 4.4.1, it loses the centered position
	parent.position = (screen_size - parent.size)/2
