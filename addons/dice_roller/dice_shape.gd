@tool
extends Resource
class_name DiceShape

@export var name: String = "D6":
	set(value):
		if value not in icons.keys():
			push_warning("DiceShape: setting UNREGISTERED shape '", value, "'")
		name=value

static var _registry: Dictionary = {
	"D6": 6,
	"D4": 4,
	"D8": 8,
	"D10": 10,
	"D10x10": 100,
	"D20": 20,
}

static var shapes_to_sides : Dictionary[String, int] = {
	"D6": 6,
	"D4": 4,
	"D8": 8,
	"D10": 10,
	"D10x10": 100,
	"D20": 20,
}
static var sides_to_shapes : Dictionary[int, String] = invert_dict(shapes_to_sides)

static func invert_dict(d: Dictionary[String, int]) -> Dictionary[int, String]:
	var r : Dictionary[int, String]= {}
	for k: String in d:
		r[d[k]] = k
	return r

const icons =  {
	"D4": preload("./dice/d4_dice/d4_dice.svg"),
	"D6": preload("./dice/d6_dice/d6_dice.svg"),
	"D8": preload("./dice/d8_dice/d8_dice.svg"),
	"D10": preload("./dice/d10_dice/d10_dice.svg"),
	"D10x10": preload("./dice/d10x10_dice/d10x10_dice.svg"),
	"D20": preload("./dice/d20_dice/d20_dice.svg"),
}
const scenes = {
	"D6": preload("./dice/d6_dice/d6_dice.tscn"),
	"D4": preload("./dice/d4_dice/d4_dice.tscn"),
	"D8": preload("./dice/d8_dice/d8_dice.tscn"),
	"D10": preload("./dice/d10_dice/d10_dice.tscn"),
	"D10x10": preload("./dice/d10x10_dice/d10x10_dice.tscn"),
	"D20": preload("./dice/d20_dice/d20_dice.tscn"),
}

static func icon_for_shape(shape: String ) -> Texture2D:
	return icons.get(shape, icons['D6'])
	
func icon() -> Texture2D:
	return icons[name]

func scene() -> PackedScene:
	return scenes[name]

static func register(
	id: String,
	dice_class: Script,
) -> void:
	if _registry.has(id):
		push_warning("DiceShape '%s' is already registered" % id)
	_registry[id] = dice_class

## Support for legacy DiceDef with sides attribute
static func from_sides(sides: int) -> DiceShape:
	push_warning("Legacy setting DiceDef.sides with value: ", sides)
	return new(sides_to_shapes[sides])

static func options() -> Array:
	return icons.keys()
	return _registry.keys()

static func get_dice3d(name: String) -> Script:	
	return _registry.get(name, null)

static func get_icon(name: String) -> Texture:
	return get_dice3d(name).get_icon()

static func from_id(name: String) -> DiceShape:
	return DiceShape.new(name)

func _init(_name: String="D6") -> void:
	if not _registry.has(_name):
		push_warning("DiceShape id '%s' is not registered." % _name)
		print(_registry.keys())
	name = _name

func _to_string() -> String:
	return name

func _equals(other) -> bool:
	return typeof(other) == TYPE_OBJECT and other is DiceShape and name == other.name
