extends Node2D

@onready var play_button: TextureButton = $play_button
@onready var credits_button: TextureButton = $credits_button
@onready var title: Label = $title
@onready var anim_player: AnimationPlayer = $AnimPlayer
@onready var fadeframe: ColorRect = $fade_frame

const MAIN = preload("res://main.tscn")

func fade_frame(state : bool) -> void:
	if state == true: anim_player.play("FadeFrameIn")
	else: anim_player.play("FadeFrameOut")
	await anim_player.animation_finished


func _ready() -> void:
	pass




func _on_play_button_pressed() -> void:
	fadeframe.z_index = 5
	await fade_frame(true)
	get_tree().change_scene_to_file("res://main.tscn")


func _on_credits_button_pressed() -> void:
	fadeframe.z_index = 5
	await fade_frame(true)
	get_tree().change_scene_to_file("res://credits.tscn")
