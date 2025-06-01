extends Node2D

func _on_play_button_pressed() -> void:
	SignalBus.main_menu_play_pressed.emit()


func _on_settings_button_pressed() -> void:
	GameManager.open_settings_menu()
