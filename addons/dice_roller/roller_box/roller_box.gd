@icon("./roller_box.svg")
class_name RollerBox
extends StaticBody3D

@export var height = 16.0:
	set(new_value):
		height = new_value
		resize_children()

@export var width = 10.0:
	set(new_value):
		width = new_value
		resize_children()

@export var depth = 6.0:
	set(new_value):
		depth = new_value
		resize_children()

@export var debug = false:
	set(new_value):
		debug = new_value
		if not is_node_ready():
			return
		if debug:
			addDebugTokens()
		else:
			removeDebugTokens()

@export var debug_camera := false:
	set(new_value):
		if not $DebugCamera3D: return
		$DebugCamera3D.current = new_value

var colliders = {}
var debug_tokens = []

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	create_colliders()

func _ready() -> void:
	$DebugCamera3D.current = debug_camera
	resize_children()
	if debug:
		addDebugTokens()
	get_viewport().size_changed.connect(focus_camera)
	focus_camera()

func size() -> Vector3:
	if not $CSGBox3D:
		return Vector3.ZERO
	return $CSGBox3D.size

func offsets() -> Dictionary:
	return {
		"UP": height/2,
		"DOWN": height/2,
		"LEFT": width/2,
		"RIGHT": width/2,
		"FORWARD": depth/2,
		"BACK": depth/2,
	}

func normals() -> Dictionary:
	return {
		"UP": Vector3.UP,
		"DOWN": Vector3.DOWN,
		"LEFT": Vector3.LEFT,
		"RIGHT": Vector3.RIGHT,
		"FORWARD": Vector3.FORWARD,
		"BACK": Vector3.BACK,
	}

func create_colliders() -> void:
	var normals = normals()
	var offsets = offsets()
	for direction in offsets:
		var shape := WorldBoundaryShape3D.new()
		var normal = normals[direction]
		var collider := CollisionShape3D.new()
		colliders[direction] = collider
		collider.name = "PlaneCollider"+direction
		shape.plane = Plane(normal)
		collider.shape = shape
		collider.position = - normal * offsets[direction]
		add_child(collider)

func adapt_colliders() -> void:
	var normals = normals()
	var offsets = offsets()
	for direction in offsets:
		var collider = colliders[direction]
		var normal = normals[direction]
		collider.position = - normal * offsets[direction]

func removeDebugTokens() -> void:
	for token: MeshInstance3D in debug_tokens:
		token.queue_free()
	debug_tokens = []

func addDebugTokens() -> void:
	removeDebugTokens()
	var offsets = offsets()
	for direction in offsets:
		var collider = colliders[direction]
		var token = MeshInstance3D.new()
		token.mesh = CylinderMesh.new()
		debug_tokens.append(token)
		collider.add_child(token)

func resize_children() -> void:
	if !is_node_ready(): return
	position = Vector3.UP * height/2
	$CSGBox3D.size = Vector3(width, height, depth)
	adapt_colliders()
	focus_camera()

func focus_camera() -> void:
	var viewport: Viewport = get_viewport()
	if not viewport:
		return
	var viewport_size: Vector2 = viewport.size
	var box_size: Vector3 = size()
	const margin = 0.05
	var floor_height := box_size.z + margin
	var floor_width := box_size.x + margin
	var floor_aspect := floor_width / floor_height
	var camera: Camera3D = $OverCamera
	var is_viewport_landscape := viewport_size.aspect() >= 1.0
	var is_floor_landscape := floor_aspect >= 1.0
	var tilt_camera := is_floor_landscape != is_viewport_landscape
	camera.rotation_degrees.y = -90 if tilt_camera else 0
	if tilt_camera:
		var temp = floor_width
		floor_width = floor_height
		floor_height = temp
		floor_aspect = floor_width / floor_height
	var camera_to_floor = $OverCamera.position.y + box_size.y/2
	var wider_viewport := viewport_size.aspect() > floor_aspect
	camera.keep_aspect = Camera3D.KEEP_HEIGHT if wider_viewport else Camera3D.KEEP_WIDTH
	var dimension_to_adapt := floor_height if wider_viewport else floor_width
	camera.fov = rad_to_deg(atan2(dimension_to_adapt/2, camera_to_floor))*2
