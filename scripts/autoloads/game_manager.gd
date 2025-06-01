extends Node

enum GameState {
	MAIN_MENU,
	IN_GAME,
	CUTSCENE,
	END
}

var curr_game_state: GameState = GameState.MAIN_MENU


func _ready() -> void:
	_initialize_signals()


func _initialize_signals() -> void:
	SignalBus.door_animation_finished.connect(_change_floor)
	SignalBus.main_menu_play_pressed.connect(_change_to_in_game)


func _change_to_in_game() -> void:
	get_tree().change_scene_to_file("res://scenes/floors/military_floor.tscn") # change this to level 1 when it's added
	curr_game_state = GameState.IN_GAME


func _change_floor(door_entered_from: Door.DoorFloor) -> void:
	await get_tree().physics_frame
	match door_entered_from:
		Door.DoorFloor.MILITARY:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			pass # load lab floor
		Door.DoorFloor.LABORATORY:
			pass # load ground floor
		Door.DoorFloor.GROUND:
			pass # load upper floor
		Door.DoorFloor.UPPER:
			pass # load the ending cutscene
