extends CharacterBody2D


const OUT_OF_GROUND_COLLISION_MASK: int = 0b01
const IN_GROUND_COLLISION_MASK: int = 0b10


## Maps the current velocity to the acceleration of gravity.
@export_group("jump")
@export var fall_accel_curve: Curve
@export var fall_accel: float = 1000
@export var jump_speed: float = 1000
## Gravity is multiplied by this when holding jump.
@export var jump_hold_gravity_factor: float = 0.5

@export_group("strafe")
@export var floor_walk_speed: float = 1000
@export var floor_walk_accel: float = 1000
@export var air_strafe_speed: float = 1000
@export var air_strafe_accel: float = 1000
@export var floor_friction: float = 0.9


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_hold_timer: Timer = $JumpHoldTimer
@onready var leave_ground_detection_area: Area2D = $LeaveGroundDetectionArea


var _has_jumped_in_air := false
var _is_holding_jump := false
var _is_in_ground := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor() or not _has_jumped_in_air:
			animation_player.stop()
			animation_player.play("jump")
			velocity.y = -jump_speed
			_is_holding_jump = true
			jump_hold_timer.start()
			if not is_on_floor():
				_has_jumped_in_air = true
	elif event.is_action_released("jump"):
		stop_holding_jump()
	elif event.is_action_pressed("ui_down"):
		enter_ground()


func _physics_process(delta: float) -> void:
	# Leave the ground if there's enough room (i.e., we're not overlapping with any ground).
	if _is_in_ground and not leave_ground_detection_area.get_overlapping_bodies():
		leave_ground()

	if not is_on_floor():
		var accel_factor: float = 1.0
		if fall_accel_curve:
			accel_factor = fall_accel_curve.sample_baked(velocity.y)
		if _is_holding_jump and velocity.y < 0:
			accel_factor *= jump_hold_gravity_factor
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

func stop_holding_jump() -> void:
	_is_holding_jump = false

func enter_ground() -> void:
	animation_player.stop()
	animation_player.play("enter_ground")
	collision_mask = IN_GROUND_COLLISION_MASK
	_is_in_ground = true

func leave_ground() -> void:
	animation_player.stop()
	animation_player.play("leave_ground")
	collision_mask = OUT_OF_GROUND_COLLISION_MASK
	_is_in_ground = false
