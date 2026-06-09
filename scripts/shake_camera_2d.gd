class_name ShakeCamera2D
extends Camera2D


# Maximum damping factor before the
const MAX_AMPLITUDE: float = 1


# Shake sources.
var _partials: Array[Partial] = []


func _process(delta: float) -> void:
	offset = Vector2.ZERO
	for partial in _partials:
		partial.time_running += delta
		var damping_factor: float = exp(-partial.time_running * partial.damping * partial.frequency)
		if partial.vector.length() * damping_factor < MAX_AMPLITUDE:
			partial.should_be_deleted = true
			print("Deleting shake partial")
		offset += partial.vector * damping_factor * sin(partial.time_running * partial.frequency * 2 * PI)

	_partials = _partials.filter(func(p: Partial) -> bool: return not p.should_be_deleted)

## Similar to applying an impulse to the camera with a force given by v. `damping` will always be at least 0.1.
func shake_directional(v: Vector2, frequency: float = 10, damping: float = 0.5) -> void:
	damping = max(damping, 0.1)

	var partial := Partial.new()
	partial.vector = v
	partial.frequency = frequency
	partial.damping = damping
	_partials.push_back(partial)

# Works by shaking in two perpendicular directions, chosen randomly. One has its frequency slightly different to avoid circular motion.
func shake(strength: float, frequency: float = 10, damping: float = 0.5) -> void:
	var dir := Vector2.RIGHT.rotated(randf_range(-PI, PI))
	shake_directional(dir * strength, frequency, damping)
	shake_directional(dir.orthogonal() * strength, frequency * 0.9, damping)


class Partial:
	var vector: Vector2
	var frequency: float
	var damping: float

	var time_running: float = 0.0
	var should_be_deleted: bool = false
