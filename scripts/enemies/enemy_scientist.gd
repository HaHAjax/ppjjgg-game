extends EnemyBase
class_name EnemyScientist

func _init() -> void:
	initialize_enemy()


func _ready() -> void:
	SignalBus.player_possess_enemy.connect(on_player_possess)


func on_player_possess(enemy: EnemyBase) -> void:
	if enemy != self: return # makes sure we only respond to our own possession
	
	SignalBus.enemy_possessed.emit(attributes, self.global_position) # Emit the signal with our attributes

	self.queue_free()
