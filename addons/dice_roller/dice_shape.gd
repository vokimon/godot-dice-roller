@tool
extends Resource
class_name DiceShape

@export var name: String = "D6":
	set(value):
		if value not in _registry.keys():
			push_warning("DiceShape: setting UNREGISTERED shape '", value, "'")
		name=value

static var _registry: Dictionary[String, Script] = {
	'D4': D4Dice,
	'D6': D6Dice,
	'D8': D8Dice,
	'D10': D10Dice,
	'D10x10': D10x10Dice,
	'D20': D20Dice,
	'D12': D12Dice,
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

static func icon_for_shape(shape: String ) -> Texture2D:
	return _registry.get(shape, _registry['D6']).icon()
	
func icon() -> Texture2D:
	return _registry.get(name, _registry['D6']).icon()

func scene() -> PackedScene:
	return _registry.get(name, _registry['D6']).scene()

static func clear_registry():
	_registry.clear()

static func register(
	id: String,
	dice_class: Script,
) -> bool:
	push_warning("DiceShape: registering '%s'" % id)
	if _registry.has(id):
		push_warning("DiceShape '%s' is already registered" % id)
	_registry[id] = dice_class
	return true

static func options() -> Array:
	return _registry.keys()

func _init(_name: String="D6") -> void:
	if not _registry.has(_name):
		push_warning("DiceShape id '%s' is not registered. Available keys: %s" % [_name, _registry.keys()])
	name = _name

func _to_string() -> String:
	return name

func _equals(other) -> bool:
	return typeof(other) == TYPE_OBJECT and other is DiceShape and name == other.name

## Support for legacy DiceDef with sides attribute
static func from_sides(sides: int) -> DiceShape:
	push_warning("Legacy setting DiceDef.sides with value: ", sides)
	return new(sides_to_shapes[sides])
