class_name EffectSpawner
extends Node2D
## Instantiates a scene at this node, and deletes it after a set time.


@export var scene: PackedScene
## Time in seconds from spawning an effect before it is freed.
@export var free_delay: float = 1


func spawn() -> void:
	if not scene: return

	var node := scene.instantiate() as Node2D
	if not node: return

	# Effects don't move from their initial position in global space.
	node.top_level = true
	add_child(node)
	node.global_position = global_position
	node.global_scale = global_scale
	node.global_rotation = global_rotation

	get_tree().create_timer(free_delay).timeout.connect(node.queue_free)
