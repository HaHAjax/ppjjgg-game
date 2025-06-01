extends Node

signal player_possess_enemy(enemy: Enemy)
signal enemy_possessed(attributes: Array[AttributeBase], global_position: Vector2)
signal door_entered(door_floor: Door.DoorFloor, door_node: Door)
signal door_animation_finished(door_floor: Door.DoorFloor)
signal main_menu_play_pressed()


func _ready() -> void:
	pass
