extends Node2D

func _on_button_pressed() -> void:
	SignalBus.main_menu_play_pressed.emit()
