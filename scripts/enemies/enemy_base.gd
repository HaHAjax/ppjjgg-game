extends CharacterBody2D
class_name EnemyBase
## Base class for all enemies in the game.

var attributes: Array[AttributeBase] = []


func _init() -> void:
	initialize_enemy()


## Always call this in _init() of the child class.
## Initializes the enemy by setting up various things.
func initialize_enemy() -> void:
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
	pass
