extends AudioStreamPlayer
class_name SoundManager

var boss_sounds = {
	"Enemy1": {
		"hit": [
			preload("res://Sound/Lines/Raph/take damage/AHHH.wav"),
			preload("res://Sound/Lines/Raph/take damage/grunt 1.wav"),
			preload("res://Sound/Lines/Raph/take damage/grunt 2.wav"),
			preload("res://Sound/Lines/Raph/take damage/ow that hurt.wav"),
			preload("res://Sound/Lines/Raph/take damage/oww-2.wav"),
			preload("res://Sound/Lines/Raph/take damage/OWW.wav")
		],
		"attack": [
			preload("res://Sound/Lines/Raph/do damage/how do you like dem apples.wav"),
			preload("res://Sound/Lines/Raph/do damage/take that.wav")
		]
	},
	"Enemy2": {
		"hit": [
			preload("res://Sound/Lines/Jason/take damage/OWWWWW.wav"),
			preload("res://Sound/Lines/Jason/take damage/owww.wav"),
			preload("res://Sound/Lines/Jason/take damage/ow-that-hurt.wav")
		],
		"attack": [
			preload("res://Sound/Lines/Jason/do damage/ahhhh.wav"),
			preload("res://Sound/Lines/Jason/do damage/grunt-1.wav"),
			preload("res://Sound/Lines/Jason/do damage/grunt-2.wav"),
			preload("res://Sound/Lines/Jason/do damage/take-that.wav")
		]
	},
	"Enemy3": {
		"hit": [
			preload("res://Sound/Lines/Alex/take damage/AHHH.wav"),
			preload("res://Sound/Lines/Alex/take damage/grunt 1.wav"),
			preload("res://Sound/Lines/Alex/take damage/grunt 2.wav"),
			preload("res://Sound/Lines/Alex/take damage/ow that hurt.wav"),
			preload("res://Sound/Lines/Alex/take damage/oww-2.wav"),
			preload("res://Sound/Lines/Alex/take damage/OWW.wav"),
			preload("res://Sound/Lines/Alex/take damage/owww.wav")
		],
		"attack": [
			preload("res://Sound/Lines/Alex/do damage/how do you like dem apples.wav"),
			preload("res://Sound/Lines/Alex/do damage/take that.wav")
		]
	}
}


func play_boss_sound(boss_name: String, sound_type: String) -> void:
	if boss_sounds.has(boss_name) and boss_sounds[boss_name].has(sound_type):
		var sounds = boss_sounds[boss_name][sound_type]
		stream = sounds[randi() % sounds.size()]
		play()
	else:
		push_warning("Missing sound for %s - %s" % [boss_name, sound_type])
