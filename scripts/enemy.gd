@tool
extends CharacterBody2D
class_name Enemy
## Base class for all enemies in the game.

enum EnemyType {
	CHOOSE = 0,
	MILITARY,
	SCIENTIST,
	TOURIST,
	DRUNK
}

@export var type_enemy: EnemyType = EnemyType.CHOOSE
@export_tool_button("Initialize Enemy", "Callable") var initialize_enemy_button: Callable = _initialize_enemy
@export var attributes: Array[AttributeBase] = []

var enemy_data_uids: Dictionary = {
	EnemyType.CHOOSE: null,
	EnemyType.MILITARY: "null",
	EnemyType.SCIENTIST: "uid://dykw5ve8ot8vr",
	EnemyType.TOURIST: "null",
	EnemyType.DRUNK: "null"
}

var sprite_node: Sprite2D = Sprite2D.new()
var collision_node: CollisionShape2D = CollisionShape2D.new()

var enemy_data: EnemyData = null


func _init() -> void:
	if Engine.is_editor_hint(): return
	# _initialize_enemy()


func _ready() -> void:
	if Engine.is_editor_hint(): return
	_initialize_enemy()


func _initialize_enemy() -> void:
	if not Engine.is_editor_hint(): _initialize_signals(); _initialize_groups()
	_initialize_children_as_variables()
	_initialize_enemy_data()
	if type_enemy != EnemyType.CHOOSE: _initialize_children_things()
	else: push_error("no enemy type set, fucko")
	if enemy_data != null: _initialize_children_things()
	else: push_error("no enemy data, fucko")


func _initialize_enemy_data() -> void:
	if enemy_data_uids[type_enemy] == "null" or enemy_data_uids[type_enemy] == null: push_error("don't have enemy data")
	else: enemy_data = ResourceLoader.load(enemy_data_uids[type_enemy]) as EnemyData


func _initialize_children_things() -> void:
	sprite_node.texture = enemy_data.sprite
	collision_node.shape = enemy_data.collision_shape
	collision_node.position = enemy_data.collision_shape_offset


func _initialize_children_as_variables() -> void:
	if not has_node("Sprite2D"): add_child(sprite_node)
	else: sprite_node = get_node("Sprite2D") as Sprite2D
	if not has_node("CollisionShape2D"): add_child(collision_node)
	else: collision_node = get_node("CollisionShape2D") as CollisionShape2D


func _initialize_groups() -> void:
	if not self.is_in_group("possessable"): add_to_group("possessable")
	if not self.is_in_group("enemy"): add_to_group("enemy")


func _initialize_signals() -> void:
	SignalBus.player_possess_enemy.connect(on_player_possess)


func on_player_possess(enemy: Enemy) -> void:
	if enemy != self: return # makes sure we only respond to our own possession
	
	SignalBus.enemy_possessed.emit(attributes, self.global_position) # Emit the signal with our attributes

	self.queue_free()
