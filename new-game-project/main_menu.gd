extends Node2D

@onready var play_button: Button = $play_button
@onready var credits_button: Button = $credits_button
@onready var exit_button: Button = $exit_button
@onready var title: Label = $title
@onready var anim_player: AnimationPlayer = $AnimPlayer

func fade_frame(state : bool) -> void:
	if state == true: anim_player.play("FadeFrameIn")
	else: anim_player.play("FadeFrameOut")
	await anim_player.animation_finished


func _ready() -> void:
	pass


func _process(_delta) -> void:
	if play_button.pressed:
		fade_frame(false)
		get_tree().change_scene_to_file("res://main.tscn")
	elif credits_button.pressed:
		fade_frame(false)
		get_tree().change_scene_to_file("res://credits.tscn")
	elif exit_button.pressed:
		pass
		# play really loud sound
		
