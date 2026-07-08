extends Node
## Plays non-positional sound effects.


@export var sound_effect_name_to_audio_stream: Dictionary[String, AudioStream]


# Stupidest version of this. We just make a new player for every sound effect.
@onready var _name_to_stream_player: Dictionary[String, AudioStreamPlayer] = {}


func _ready() -> void:
	for sound_effect_name in sound_effect_name_to_audio_stream:
		var player := AudioStreamPlayer.new()
		player.max_polyphony = 8
		player.stream = sound_effect_name_to_audio_stream[sound_effect_name]
		add_child(player)
		_name_to_stream_player[sound_effect_name] = player

func play(sound_effect_name: String) -> void:
	var audio_stream: AudioStream = sound_effect_name_to_audio_stream.get(sound_effect_name)
	var player: AudioStreamPlayer = _name_to_stream_player.get(sound_effect_name)

	if not audio_stream or not player: return

	player.play()
