extends CharacterBody2D


## Maps the current velocity to the acceleration of gravity.
@export_group("jump")
@export var fall_accel_curve: Curve
@export var fall_accel: float = 1000
@export var jump_speed: float = 1000

@export_group("strafe")
@export var floor_walk_speed: float = 1000
@export var floor_walk_accel: float = 1000
@export var air_strafe_speed: float = 1000
@export var air_strafe_accel: float = 1000
@export var floor_friction: float = 0.9


@onready var animation_player: AnimationPlayer = $AnimationPlayer


var _has_jumped_in_air := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor() or not _has_jumped_in_air:
			animation_player.stop()
			animation_player.play("jump")
			velocity.y = -jump_speed
			if not is_on_floor():
				_has_jumped_in_air = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var accel_factor: float = 1.0
		if fall_accel_curve:
			accel_factor = fall_accel_curve.sample_baked(velocity.y)
		velocity.y += accel_factor * fall_accel * delta
	else:
		_has_jumped_in_air = false

	var target_x_speed: float = Input.get_axis("left", "right") * (floor_walk_speed if is_on_floor() else air_strafe_speed)
	var x_accel: float = floor_walk_accel if is_on_floor() else air_strafe_accel

	velocity.x = move_toward(velocity.x, target_x_speed, x_accel * delta)
	velocity.x -= velocity.x * floor_friction * delta

	var was_on_floor := is_on_floor()
	move_and_slide()
	if not was_on_floor and is_on_floor():
		animation_player.stop()
		animation_player.play("land")
