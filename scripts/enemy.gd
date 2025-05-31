@tool
extends CharacterBody2D
class_name Enemy
## Base class for all enemies in the game.

enum EnemyType {
	CHOOSE = 0, ## This is a placeholder for the editor to choose an enemy type.
	MILITARY, ## Military enemy, typically placed in level 1
	SCIENTIST, ## Scientist enemy, typically placed in level 2
	TOURIST, ## Tourist enemy, typically placed in level 3
	DRUNK ## Drunk enemy, typically placed in level 4
}

@export var type_enemy: EnemyType = EnemyType.CHOOSE ## The selected enemy type for this enemy instance.
@export_tool_button("Initialize Enemy", "Callable") var initialize_enemy_button: Callable = _initialize_enemy ## Button to simply initialize the enemy in the editor.
@export var attributes: Array[AttributeBase] = [] ## Attributes added here will be added to the end of this enemy's attributes array.

var enemy_data_uids: Dictionary = {
	EnemyType.CHOOSE: null,
	EnemyType.MILITARY: "uid://ddm6i68a2ri6a",
	EnemyType.SCIENTIST: "uid://dykw5ve8ot8vr",
	EnemyType.TOURIST: "uid://dqgpg7r2trkce",
	EnemyType.DRUNK: "uid://cwrseu87t0r0n"
}

var sprite_node: Sprite2D = Sprite2D.new()
var collision_node: CollisionShape2D = CollisionShape2D.new()

var enemy_data: EnemyData = null


func _ready() -> void:
	if Engine.is_editor_hint(): return
	_initialize_enemy()


func _initialize_enemy() -> void:
	if not Engine.is_editor_hint(): _initialize_signals(); _initialize_groups()
	_initialize_children_as_variables()
	_initialize_enemy_data()
	if type_enemy != EnemyType.CHOOSE: _initialize_children_things()
	else: push_error("no enemy type set, bucko")
	if enemy_data != null: _initialize_children_things()
	else: push_error("no enemy data, bucko")
	_initialize_collision_stuff()


func _initialize_collision_stuff() -> void:
	self.set_collision_layer_value(2, true)
	self.set_collision_layer_value(4, true)
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)



func _initialize_enemy_data() -> void:
	if enemy_data_uids[type_enemy] == "null" or enemy_data_uids[type_enemy] == null: push_error("don't have enemy data")
	else: enemy_data = ResourceLoader.load(enemy_data_uids[type_enemy]) as EnemyData


func _initialize_children_things() -> void:
	self.name = enemy_data.enemy_name + "Enemy"
	sprite_node.texture = enemy_data.sprite
	collision_node.shape = enemy_data.collision_shape
	collision_node.position = enemy_data.collision_shape_offset
	attributes.clear()
	attributes.append_array(enemy_data.attributes)


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


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	apply_gravity(delta)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 981 * delta
	else:
		velocity.y = 0
	
	move_and_slide()
