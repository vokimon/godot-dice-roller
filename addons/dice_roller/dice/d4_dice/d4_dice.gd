@icon("./dice4-icon.svg")
class_name D4Dice
extends RigidBody3D

@export var dice_color := Color.BROWN
@onready var original_position := position

const sides = {
	1: Vector3(+1,-1,-1),
	2: Vector3(-1,-1,+1),
	3: Vector3(+1,+1,+1),
	4: Vector3(-1,+1,-1),
}
const dice_size := 2.0
const dice_density := 10.0
const ANGULAR_VELOCITY_THRESHOLD := 10.
const LINEAR_VELOCITY_THRESHOLD := 0.2 * dice_size
## If the center of the dice stops above this elevation it is considered mounted
const mounted_elevation = 0.8 * dice_size
## The minimal angle between faces (different in a d20)
const face_angle := 90.0
## how up must be a face unit vector for the face to be choosen
var max_tilt := cos(deg_to_rad(face_angle/float(sides.size())))

## Whether the dice is rolling
var rolling := false
## Accomulated roll time
var roll_time := 0.0

## Emited when a roll finishes
signal roll_finished(int)

func _init():
	continuous_cd = false
	can_sleep = true
	gravity_scale = 10
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func _ready():
	original_position = position
	mass = dice_density * dice_size ** 3 / 4
	var collider_shape: ConvexPolygonShape3D = $Collider.shape
	var collider_points = []
	for point in sides.values():
		collider_points.append(dice_size/2.0 * point)
	collider_shape.points = collider_points
	#collider_shape.size = dice_size * Vector3.ONE
	collider_shape.margin = dice_size * 0.1
	$DiceMesh.material_override = $DiceMesh.material_override.duplicate()
	$DiceMesh.material_override.albedo_color = dice_color
	stop()

func stop():
	dehighlight()
	freeze = true
	sleeping = true
	position = original_position
	position.y = 5 * dice_size
	rotation = randf_range(0, 2*PI)*Vector3(1.,1.,1.)
	#lock_rotation = true # TODO: should not be set?
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func roll():
	"""Roll the dice"""
	if position.y < dice_size*2: stop()
	dehighlight()
	linear_velocity = Vector3(-dice_size, 0, -dice_size)
	angular_velocity = Vector3.ZERO
	freeze = false
	sleeping = false
	lock_rotation = false
	roll_time = 0
	rolling = true
	apply_torque_impulse( mass * TAU * Vector3(
		randf_range(-1.,+1.), 0, randf_range(-1.,+1.)
	))
	apply_impulse( mass * Vector3(
		randf_range(-1.,+1.), 0, randf_range(-1.,+1.)
	))


func shake(reason: String):
	"""Move a bad rolled dice"""
	print("Dice {0}: Reshaking {1}".format([name, reason]))
	apply_impulse(
		mass * 10. * Vector3(0,1,0),
		dice_size * Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)),
	)

func _process(_delta):
	if not rolling: return
	roll_time += _delta

	if freeze: return # non physics movement on progress

	if linear_velocity.length() > LINEAR_VELOCITY_THRESHOLD:
		#print("Still moving: ", linear_velocity)
		return
	if angular_velocity.length() > ANGULAR_VELOCITY_THRESHOLD:
		#print("Still rolling: ", angular_velocity)
		return
	# Almost stopped but...
	if position.y > mounted_elevation:
		return shake("mounted")
	var side = upper_side()
	if not side:
		return shake("tilted")

	print("Dice %s solved [%s] - %.02fs"%([name, side, roll_time]))
	freeze = true
	sleeping = true
	show_face(side)

func upper_side() -> int:
	"Returns which dice side is up, or 0 when none is clear"
	var highest_y := -INF
	var highest_side := 0
	for side in sides:
		var y = to_global(sides[side]).y
		if y < highest_y: continue
		highest_y = y
		highest_side = side
	#print("{3} Face {0} from center {1} against threshold {2}".format([
	#	highest_y, highest_y - global_position.y, max_tilt, name
	#]))
	if highest_y - global_position.y < max_tilt:
		return 0
	return highest_side

func face_up_transform(value) -> Transform3D:
	"""Returns the 3D tranform to put the given value up"""
	var face_normal = (to_global(sides[value])-global_position).normalized()
	var cross = face_normal.cross(Vector3.UP).normalized()
	var angle = face_normal.angle_to(Vector3.UP)
	var rotated := Transform3D(transform)
	# Edge case: face is down
	if cross.length_squared()<0.1:
		cross = Vector3.FORWARD
	rotated.basis = rotated.basis.rotated(cross.normalized(), angle)
	return rotated

func show_face(value):
	"""Shows a given face by rotating it up"""
	assert(value in sides)
	dehighlight()
	rolling = true
	const show_face_animation_time := .3
	var rotated := face_up_transform(value)
	var tween: Tweener = create_tween().tween_property(
		self, "transform", rotated, show_face_animation_time
	)
	await tween.finished
	rolling = false
	highlight()
	roll_finished.emit(value)


@onready var highlight_face : Node3D = $FaceHighligth

func highlight():
	var side: int = upper_side()
	var side_orientation: Vector3 = sides[side].normalized()
	var rotation := Quaternion(Vector3.BACK, side_orientation).normalized()
	highlight_face.rotation = rotation.get_euler(rotation_order)
	highlight_face.visible = true

func dehighlight():
	highlight_face.visible = false
	
