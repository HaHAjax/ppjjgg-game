extends CharacterBody2D

@export var speed: float = 6000.0
@export var jump_force: float = 250.0
@export var gravity: int = 981
@export var slide_slowdown_speed: float = 200.0

var input_move_dir: int = 0
var input_jump: bool = false
var input_duck: bool = false

var is_ducking: bool :
	get: return input_duck
var is_jumping: bool :
	get: return input_jump and is_on_floor()
var is_moving: bool :
	get: return input_move_dir != 0

var slide_lerp_t: float = 0.0

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	animation_player.current_animation = "duck"
	animation_player.pause()

	slide_slowdown_speed /= 100


func _process(_delta: float) -> void:
	update_inputs()


func _physics_process(delta: float) -> void:
	if is_moving:
		move_player(delta)
	else:
		velocity.x = 0.0
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
	elif is_ducking and is_moving:
		slide_lerp_t += delta * slide_slowdown_speed
		slide_lerp_t = clampf(slide_lerp_t, 0.0, 1.0)
		velocity.x = lerp(velocity.x, 0.0, slide_lerp_t)
	elif is_ducking:
		slide_lerp_t += delta * slide_slowdown_speed
		slide_lerp_t = clampf(slide_lerp_t, 0.0, 1.0)
		velocity.x = lerp(velocity.x, 0.0, slide_lerp_t)
	
	move_and_slide()


func update_inputs() -> void:
	input_move_dir = ceili(Input.get_axis("move_left", "move_right"))
	input_jump = Input.is_action_pressed("jump")
	input_duck = Input.is_action_pressed("duck")


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
		velocity.y += (gravity * 2) * delta
