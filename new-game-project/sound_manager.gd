extends AudioStreamPlayer
class_name SoundManager

var boss_sounds = {
	"enemy_1": {
		"hit": [
			preload("res://Sound/Lines/Raph/take damage/AHHH.wav"),
			preload("res://Sound/Lines/Raph/take damage/grunt 1.wav"),
			preload("res://Sound/Lines/Raph/take damage/ow that hurt.wav"),
			preload("res://Sound/Lines/Raph/take damage/oww-2.wav"),
			preload("res://Sound/Lines/Raph/take damage/OWW.wav")
		],
		"attack": [
			preload("res://Sound/Lines/Raph/do damage/how do you like dem apples.wav"),
			preload("res://Sound/Lines/Raph/do damage/take that.wav"),
			preload("res://Sound/Lines/Raph/do damage/your going down-2.wav"),
			preload("res://Sound/Lines/Raph/do damage/grunt 2.wav")
		]
	},
	"enemy_2": {
		"hit": [
			preload("res://Sound/Lines/Jason/take damage/OWWWWW.wav"),
			preload("res://Sound/Lines/Jason/take damage/owww.wav"),
			preload("res://Sound/Lines/Jason/take damage/ow-that-hurt.wav"),
			preload("res://Sound/Lines/Jason/take damage/ahhhh.wav")
		],
		"attack": [
			preload("res://Sound/Lines/Jason/do damage/grunt-1.wav"),
			preload("res://Sound/Lines/Jason/do damage/grunt-2.wav"),
			preload("res://Sound/Lines/Jason/do damage/take-that.wav")
		]
	},
	"enemy_3": {
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
	},
	"boss": {
		"hit": [
			preload("res://Sound/Lines/Simon/take damage/AHHH.wav"),
			preload("res://Sound/Lines/Simon/take damage/grunt 1.wav"),
			preload("res://Sound/Lines/Simon/take damage/grunt 2.wav"),
			preload("res://Sound/Lines/Simon/take damage/ow that hurt.wav"),
			preload("res://Sound/Lines/Simon/take damage/ow.wav"),
			preload("res://Sound/Lines/Simon/take damage/oww-2.wav"),
			preload("res://Sound/Lines/Simon/take damage/OWW.wav"),
		],
		"attack": [
			preload("res://Sound/Lines/Simon/do damage/how do you like dem apples.wav"),
			preload("res://Sound/Lines/Simon/do damage/take that.wav"),
			preload("res://Sound/Lines/Simon/do damage/your going down.wav"),
		]
	}
}


func play_boss_sound(boss_name, sound_type) -> void:
	print(boss_name, " ", sound_type)
	if boss_sounds[boss_name] and boss_sounds[boss_name][sound_type]:
		var sounds = boss_sounds[boss_name][sound_type]
		stream = sounds[randi() % sounds.size()]
		print(sounds, stream)
		play()
	else:
		push_warning("Missing sound for %s - %s" % [boss_name, sound_type])
