extends GutTest

var _cleanups := []

func add_cleanup(action: Callable) -> void:
	_cleanups.insert(0, action)

func after_each():
	for cleanup in _cleanups:
		cleanup.call()
	_cleanups.clear()

func test__default_shape():
	var dice = DiceDef.new()
	assert_eq(dice.shape.name, "D6", "Default shape should be D6")

func test__shape_migration():
	var dice = DiceDef.new()
	dice.sides = 10  # This should migrate to shape 'D10'
	assert_eq(dice.shape.name, "D10", "Shape migration from sides failed")

func legacy_scene_content() -> String:
	return """
[gd_scene load_steps=2 format=3 uid="uid://c6kn26wujp0my"]

[ext_resource type="Script" path="res://tests/node_with_dice_def.gd" id="1_rhmaj"]
[ext_resource type="Script" uid="uid://xsgh2gwr4gub" path="res://addons/dice_roller/dice_shape.gd" id="2_qrebk"]
[ext_resource type="Script" uid="uid://cohd4ovwrydr0" path="res://addons/dice_roller/dice_def.gd" id="3_qrebk"]

[sub_resource type="Resource" id="Resource_ua0tv"]
script = ExtResource("3_qrebk")
name = "Definition 100"
color = Color(0, 1, 0, 1)
sides = 100
metadata/_custom_type_script = "uid://cohd4ovwrydr0"

[node name="Node3D" type="Node3D" node_paths=PackedStringArray("lala")]
script = ExtResource("1_rhmaj")
my_dicedef = SubResource("Resource_ua0tv")
"""
	
func write_file(file, content):
	var f = FileAccess.open(file, FileAccess.WRITE)
	f.store_string(content)
	f.close()
	add_cleanup(func (): DirAccess.remove_absolute(SCENE_PATH))

const SCENE_PATH := "./test_migration.tscn"
const NodeWithDiceDef = preload("./node_with_dice_def.gd")

func test__scene_loading_shape_migration():
	write_file(SCENE_PATH, legacy_scene_content())

	var packed_scene : PackedScene = ResourceLoader.load(SCENE_PATH)
	var scene : Node = packed_scene.instantiate()
	add_cleanup(func(): scene.free())
	var dice_def = scene.get("my_dicedef")

	assert_eq(dice_def.sides, 0) # deprecated field marked as migrated
	assert_eq(dice_def.shape.name, "D10x10") # new field properly filled
