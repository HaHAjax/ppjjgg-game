extends CharacterBody2D
class_name Player

var speed: float = 6000.0
var jump_force: float = 250.0
var gravity: int = 981
var slide_slowdown_speed: float = 125.0
var possess_aim_scalar: float = 125.0

@export var default_player_stats: PlayerStats

var attributes: Array[AttributeBase] = []

var input_move_dir: int = 0
var input_jump: bool = false
var input_duck: bool = false
var input_toggle_possess: bool = false
var input_possess_enemy: bool = false
var input_possess_aim: Vector2 = Vector2.ZERO

var is_ducking: bool :
	get: return input_duck
var is_jumping: bool :
	get: return input_jump and is_on_floor()
var is_moving: bool :
	get: return input_move_dir != 0
var possess_mode: bool = false
var attempt_possess_enemy: bool :
	get: return input_possess_enemy and possess_mode

var slide_lerp_t: float = 0.0
var possess_aim_dir: Vector2 = Vector2.ZERO
var all_inputs_disabled: bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var possess_raycast: RayCast2D = %PossessDetection
@onready var sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	set_player_stats(default_player_stats)

	animation_player.current_animation = "duck"
	animation_player.pause()

	slide_slowdown_speed /= 100

	possess_raycast.enabled = false

	SignalBus.enemy_possessed.connect(on_enemy_possessed)
	SignalBus.door_entered.connect(play_door_animation)


func _process(_delta: float) -> void:
	if not all_inputs_disabled:
		change_sprite_direction()


func _physics_process(delta: float) -> void:
	if not all_inputs_disabled: 
		update_inputs()
		update_all_movement(delta)
		attempt_to_possess_enemy()


func play_door_animation(door_type: Door.DoorFloor, door_node: Door) -> void:
	all_inputs_disabled = true
	animation_player.play("door")
	self.global_position.x = door_node.global_position.x
	# while not abs(self.global_position.x - door_node.global_position.x) <= 0.25:
	# 	await get_tree().process_frame
	# 	self.global_position.x = lerp(self.global_position.x, door_node.global_position.x, get_process_delta_time() * 3.0)
	await animation_player.animation_finished
	SignalBus.door_animation_finished.emit(door_type)


func change_sprite_direction() -> void:
	match input_move_dir:
		-1: sprite.flip_h = true
		1: sprite.flip_h = false
		0: pass


func attempt_to_possess_enemy() -> void:
	if attempt_possess_enemy:
		possess_raycast.target_position = input_possess_aim.normalized() * possess_aim_scalar
		possess_raycast.force_raycast_update()
		if possess_raycast.is_colliding():
			if possess_raycast.get_collider() is Enemy:
				var enemy: Enemy = possess_raycast.get_collider()
				if enemy.is_in_group("possessable"):
					SignalBus.player_possess_enemy.emit(enemy)
					possess_mode = false
				else:
					possess_mode = false
			else:
				possess_mode = false
		else:
			possess_mode = false
	# else:
	# 	ProjectSettings.set_setting("display/mouse_cursor/custom_image", "res://assets/misc/cursor_regular.png")


func set_player_stats(stats: PlayerStats) -> void:
	speed = stats.speed
	jump_force = stats.jump_force
	gravity = stats.gravity
	slide_slowdown_speed = stats.slide_slowdown_speed
	possess_aim_scalar = stats.possess_aim_scalar


func on_enemy_possessed(new_attributes: Array[AttributeBase], new_position: Vector2) -> void:
	attributes.clear()
	attributes.append_array(new_attributes)

	self.global_position = new_position

	for attribute in attributes:
		if attribute.player_stats_to_inherit != null:
			set_player_stats(attribute.player_stats_to_inherit)


func update_all_movement(delta: float) -> void:
	if is_moving:
		move_player(delta)
	if is_jumping:
		apply_jump_force()
	else:
		apply_gravity(delta)
	if is_ducking and not is_equal_approx(animation_player.current_animation_position, 0.1):
		duck_player()
	elif not is_ducking and is_equal_approx(animation_player.current_animation_position, 0.1):
		unduck_player()

	if slide_lerp_t == 1.0 and not is_ducking: # only here to avoid unneccessary calculations
		slide_lerp_t = 0.0
	elif is_ducking and not is_zero_approx(velocity.x):
		slide_lerp_t += delta * slide_slowdown_speed
		slide_lerp_t = clampf(slide_lerp_t, 0.0, 1.0)
		velocity.x = lerp(velocity.x, 0.0, slide_lerp_t)
	elif is_ducking:
		slide_lerp_t += delta * slide_slowdown_speed
		slide_lerp_t = clampf(slide_lerp_t, 0.0, 1.0)
		velocity.x = lerp(velocity.x, 0.0, slide_lerp_t)
	elif is_ducking and not is_zero_approx(velocity.x) and not is_moving:
		slide_lerp_t += delta * slide_slowdown_speed
		slide_lerp_t = clampf(slide_lerp_t, 0.0, 1.0)
		velocity.x = lerp(velocity.x, 0.0, slide_lerp_t)
	elif is_moving:
		slide_lerp_t = 0.0
	else:
		slide_lerp_t = 1.0
		velocity.x = 0.0
	
	move_and_slide()


func update_inputs() -> void:
	input_move_dir = ceili(Input.get_axis("move_left", "move_right"))
	input_jump = Input.is_action_pressed("jump")
	input_duck = Input.is_action_pressed("duck")
	if Input.is_action_just_pressed("toggle_possess_mode"): possess_mode = not possess_mode; GameManager.player_possess_mode = possess_mode; GameManager.change_mouse_cursor("regular")
	input_possess_enemy = Input.is_action_just_pressed("possess_enemy")

	input_possess_aim = get_local_mouse_position()


func move_player(delta: float) -> void:
	velocity.x = input_move_dir * speed * delta


func apply_jump_force() -> void:
	velocity.y -= jump_force


func duck_player() -> void:
	animation_player.play("duck")


func unduck_player() -> void:
	animation_player.play_backwards("duck")


func apply_gravity(delta: float) -> void:
	if sign(velocity.y) <= 0:
		velocity.y += gravity * delta
	elif sign(velocity.y) == 1:
		velocity.y += (gravity * 1.5) * delta
	
	if sign(velocity.y) <= 0 and not input_jump:
		velocity.y *= 0.5 # variable jump height
