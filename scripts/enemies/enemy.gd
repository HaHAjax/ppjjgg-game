@tool
extends CharacterBody2D
class_name Enemy
## Base class for all enemies in the game.

var attributes: Array[AttributeBase] = []

enum EnemyType {
	CHOOSE = 0,
	MILITARY,
	SCIENTIST,
	TOURIST,
	DRUNK
}

@export var type_enemy: EnemyType = EnemyType.CHOOSE


func _init() -> void:
	_initialize_enemy()


func _initialize_enemy() -> void:
	_initialize_groups()
	_initialize_signals()
	_initialize_attributes()


func _initialize_attributes() -> void:
	for child in get_children():
		if child is AttributeBase:
			attributes.append(child)


func _initialize_groups() -> void:
	if not self.is_in_group("possessable"): add_to_group("possessable")
	if not self.is_in_group("enemy"): add_to_group("enemy")


func _initialize_signals() -> void:
	SignalBus.player_possess_enemy.connect(on_player_possess)


func on_player_possess(enemy: Enemy) -> void:
	if enemy != self: return # makes sure we only respond to our own possession
	
	SignalBus.enemy_possessed.emit(attributes, self.global_position) # Emit the signal with our attributes

	self.queue_free()
