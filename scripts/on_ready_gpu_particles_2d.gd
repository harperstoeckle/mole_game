class_name OnReadyGPUParticles2D
extends GPUParticles2D
## One-shot particle effect that plays when ready.


func _ready() -> void:
	one_shot = true
	emitting = true
