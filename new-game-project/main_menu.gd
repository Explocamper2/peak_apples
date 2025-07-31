extends Node2D

@onready var play_button: Button = $play_button
@onready var credits_button: Button = $credits_button
@onready var exit_button: Button = $exit_button
@onready var title: Label = $title
@onready var anim_player: AnimationPlayer = $AnimPlayer
const MAIN = preload("res://main.tscn")

func fade_frame(state : bool) -> void:
	if state == true: anim_player.play("FadeFrameIn")
	else: anim_player.play("FadeFrameOut")
	await anim_player.animation_finished


func _ready() -> void:
	pass




func _on_play_button_pressed() -> void:
	fade_frame(false)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_credits_button_pressed() -> void:
	fade_frame(false)
	get_tree().change_scene_to_file("res://credits.tscn")


func _on_exit_button_pressed() -> void:
	# play really loud sound
	get_tree().quit()
