@tool
extends Area2D
class_name Door
## Base class for all doors in the game.

enum DoorFloor {
	CHOOSE = 0,
	MILITARY1,
	MILITARY2,
	LABORATORY,
	GROUND,
	UPPER
}

@export var type_door: DoorFloor = DoorFloor.CHOOSE ## The selected door type for this door instance.

@export_tool_button("Initialize Door", "Callable") var initialize_door_button: Callable = _initialize_door ## Button to simply initialize the door in the editor.

var sprite_node: Sprite2D
var collision_node: CollisionShape2D

var door_closed_sprite: Texture2D
var door_open_sprite: Texture2D


func _ready() -> void:
	if Engine.is_editor_hint(): return
	_initialize_door()


func _initialize_door() -> void:
	_initialize_children()
	_initialize_textures()


func _initialize_textures() -> void:
	match type_door:
		DoorFloor.MILITARY1:
			door_closed_sprite = load("res://assets/doors/military_door_closed.png") as Texture2D
			door_open_sprite = load("res://assets/doors/military_door_open.png") as Texture2D
		DoorFloor.MILITARY2:
			door_closed_sprite = load("res://assets/doors/military_door_closed.png") as Texture2D
			door_open_sprite = load("res://assets/doors/military_door_open.png") as Texture2D
		DoorFloor.LABORATORY:
			door_closed_sprite = load("res://assets/doors/lab_door_closed.png") as Texture2D
			door_open_sprite = load("res://assets/doors/lab_door_open.png") as Texture2D
		DoorFloor.GROUND:
			pass # TODO: add ground door textures
			# door_closed_sprite = load("res://assets/doors/ground_door_closed.png") as Texture2D
			# door_open_sprite = load("res://assets/doors/ground_door_open.png") as Texture2D
		DoorFloor.UPPER:
			pass # TODO: add upper door textures
			# door_closed_sprite = load("res://assets/doors/upper_door_closed.png") as Texture2D
			# door_open_sprite = load("res://assets/doors/upper_door_open.png") as Texture2D
		DoorFloor.CHOOSE:
			push_error("no door type set, bucko")
			return
	
	sprite_node.texture = door_closed_sprite # setting the texture

	# making sure collision shape is slightly larger than the sprite
	collision_node.shape.size.x = sprite_node.texture.get_size().x + 3
	collision_node.shape.size.y = sprite_node.texture.get_size().y + 3


func _initialize_children() -> void:
	if not sprite_node:
		sprite_node = $Sprite2D
	if not collision_node:
		collision_node = $CollisionShape2D


func _on_door_entered(body: Node2D) -> void:
	if not body.name == "Player": return
	sprite_node.texture = door_open_sprite
	SignalBus.door_entered.emit(type_door, self)
