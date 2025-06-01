extends Node

enum GameState {
	MAIN_MENU,
	IN_GAME,
	CUTSCENE,
	END
}

var curr_game_state: GameState = GameState.MAIN_MENU

const MAIN_MENU_MUSIC: AudioStream = preload("res://assets/audio/music/Man Down.mp3")
const IN_GAME_MUSIC: AudioStream = preload("res://assets/audio/music/The Lift.mp3")
const END_MUSIC: AudioStream = preload("res://assets/audio/music/Carefree.mp3")

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var player_possess_mode: bool = false


func _ready() -> void:
	_initialize_signals()
	_initialize_audio_players()
	change_mouse_cursor("regular")


func _initialize_audio_players() -> void:
	add_child(music_player)
	add_child(sfx_player)

	music_player.bus = "Music"
	music_player.stream = MAIN_MENU_MUSIC
	music_player.play()

	sfx_player.bus = "SFX"


func _initialize_signals() -> void:
	SignalBus.door_animation_finished.connect(_change_floor)
	SignalBus.main_menu_play_pressed.connect(_change_to_in_game)


func change_mouse_cursor(cursor_mode: String) -> void:
	match cursor_mode:
		"regular" when player_possess_mode:
			Input.set_custom_mouse_cursor(load("res://assets/misc/cursor_possess_regular.png"), Input.CURSOR_ARROW, Vector2(26, 26))
		"hover" when player_possess_mode:
			Input.set_custom_mouse_cursor(load("res://assets/misc/cursor_possess_hover.png"), Input.CURSOR_ARROW, Vector2(26, 26))
		"regular":
			Input.set_custom_mouse_cursor(load("res://assets/misc/cursor_regular.png"))
		"hover":
			Input.set_custom_mouse_cursor(load("res://assets/misc/cursor_hover.png"))


func _change_to_in_game() -> void:
	music_player.stop()
	load_floor("military")
	music_player.stream = IN_GAME_MUSIC
	music_player.play()
	curr_game_state = GameState.IN_GAME


func _change_floor(door_entered_from: Door.DoorFloor) -> void:
	await get_tree().physics_frame
	match door_entered_from:
		Door.DoorFloor.MILITARY:
			load_win_scene() # here for testing, change to lab floor when it's ready
			# load_floor("laboratory")
		Door.DoorFloor.LABORATORY:
			load_floor("ground")
		Door.DoorFloor.GROUND:
			load_win_scene() # change to the end cutscene when it's ready
		Door.DoorFloor.UPPER:
			# THIS FLOOR IS SCRAPPED
			pass


func load_floor(floor_to: String) -> void:
	match floor_to:
		"military": get_tree().change_scene_to_file("res://scenes/floors/military_floor.tscn")
		"laboratory": get_tree().change_scene_to_file("res://scenes/floors/laboratory_floor.tscn")
		"ground": get_tree().change_scene_to_file("res://scenes/floors/ground_floor.tscn")
		"upper": get_tree().change_scene_to_file("res://scenes/floors/upper_floor.tscn")		


func load_win_scene() -> void:
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	music_player.stream = END_MUSIC
	music_player.play()


func load_end_cutscene() -> void:
	pass # TODO: add the end cutscene and load it here


func load_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	music_player.stream = MAIN_MENU_MUSIC


func open_settings_menu() -> void:
	if not curr_game_state == GameState.MAIN_MENU: push_error("Settings menu can only be opened from the main menu."); return

	get_tree().get_root().add_child(load("uid://bqyd3doskn8ve").instantiate())


func close_settings_menu() -> void:
	get_tree().get_root().find_child("SettingsMenu", true, false).queue_free()
