extends Control


@onready var _master_audio: int = AudioServer.get_bus_index("Master")
@onready var _music_audio: int = AudioServer.get_bus_index("Music")
@onready var _sfx_audio: int = AudioServer.get_bus_index("SFX")


func _ready() -> void:
	$Master.value = db_to_linear(AudioServer.get_bus_volume_db(_master_audio))
	$Music.value = db_to_linear(AudioServer.get_bus_volume_db(_music_audio))
	$SFX.value = db_to_linear(AudioServer.get_bus_volume_db(_sfx_audio))


func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_master_audio, value)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_music_audio, value)


func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_sfx_audio, value)


func _on_back_pressed() -> void:
	GameManager.close_settings_menu()
