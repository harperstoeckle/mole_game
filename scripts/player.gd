extends CharacterBody2D


const OUT_OF_GROUND_COLLISION_MASK: int = 0b01
const IN_GROUND_COLLISION_MASK: int = 0b10


## Maps the current velocity to the acceleration of gravity.
@export_group("jump")
@export var allow_double_jump: bool = true
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

@export_group("dig")
## We must be moving at least this fast to enter the ground on contact.
@export var min_speed_to_enter_ground: float = 1000
@export var dig_speed: float = 1000
## Maximum angle between surface normal and negative entry direction that ground can be entered.
@export_range(0, 360, 0.1, "radians_as_degrees") var max_dig_angle: float = PI / 4

@export_group("dash")
@export var dash_speed: float = 1600


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_hold_timer: Timer = $JumpHoldTimer
@onready var leave_ground_detection_area: Area2D = $LeaveGroundDetectionArea
@onready var dig_effect_spawner: EffectSpawner = $DigEffectSpawner
@onready var out_of_ground_collision_shape: CollisionShape2D = $OutOfGroundCollisionShape
@onready var in_ground_collision_shape: CollisionShape2D = $InGroundCollisionShape


var _has_jumped_in_air := false
var _is_holding_jump := false
var _is_in_ground := false
var _facing_direction := 1.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if not _is_in_ground and (is_on_floor() or allow_double_jump and not _has_jumped_in_air):
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
	elif event.is_action_pressed("dash"):
		velocity = Vector2.RIGHT * _facing_direction * dash_speed


func _physics_process(delta: float) -> void:
	# Leave the ground if there's enough room (i.e., we're not overlapping with any ground).
	if _is_in_ground and not leave_ground_detection_area.get_overlapping_bodies():
		leave_ground()

	if not _is_in_ground:
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

		if not is_zero_approx(target_x_speed):
			_facing_direction = sign(target_x_speed)

		velocity.x = move_toward(velocity.x, target_x_speed, x_accel * delta)
		velocity.x -= velocity.x * floor_friction * delta

	var was_on_floor := is_on_floor()
	var prev_velocity := velocity
	move_and_slide()
	if not _is_in_ground and not was_on_floor and is_on_floor():
		animation_player.stop()
		animation_player.play("land")

	var c := get_last_slide_collision()
	if c:
		if _is_in_ground:
			# Reflect when colliding while underground.
			velocity = prev_velocity.bounce(c.get_normal())
		else:
			# Only enter the ground if we are moving fast enough, we are colliding with non-reflective ground,
			# and our angle of entry isn't too shallow.
			if prev_velocity.length() >= min_speed_to_enter_ground \
					and PhysicsServer2D.body_get_collision_layer(c.get_collider_rid()) & 0b10 == 0 \
					and abs(c.get_normal().angle_to(-prev_velocity)) <= max_dig_angle:
				dig_effect_spawner.global_position = c.get_position()
				dig_effect_spawner.global_rotation = c.get_normal().angle()
				velocity = -c.get_normal() * dig_speed
				enter_ground()

func stop_holding_jump() -> void:
	_is_holding_jump = false

func enter_ground() -> void:
	animation_player.stop()
	animation_player.play("enter_ground")
	collision_mask = IN_GROUND_COLLISION_MASK
	out_of_ground_collision_shape.disabled = true
	_is_in_ground = true

func leave_ground() -> void:
	animation_player.stop()
	animation_player.play("leave_ground")
	collision_mask = OUT_OF_GROUND_COLLISION_MASK
	out_of_ground_collision_shape.disabled = false
	_is_in_ground = false
