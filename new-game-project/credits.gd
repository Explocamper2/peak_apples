extends Control


@onready var background: ColorRect = $Background
@onready var credits_container: Control = $CreditsContainer
@onready var credits_text: Label = $CreditsContainer/credits_text
@onready var title: RichTextLabel = $CreditsContainer/title
@onready var fade_frame: ColorRect = $FadeFrame

const base_speed := 30.0
const speed_up_multiplier := 7.0
const lerp_speed = 3.0
const title_color := Color(0.541176, 0.168627, 0.886275, 1)
var scroll_speed := base_speed
var current_speed := base_speed
var target_speed := base_speed

var started = false
var finished = false




func finish():
	await get_tree().create_timer(1).timeout
	finished = true
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _ready():
	started = true

func _process(delta):
	if credits_text.position.y <= -800:
		finish()
		started = false
	if started:
		current_speed = lerp(current_speed, target_speed, lerp_speed * delta)
		credits_text.position.y -= current_speed * delta
		title.position.y -= current_speed * delta


func _input(event):
	if started:
		if event.is_action_pressed("ui_accept"):
			target_speed = base_speed * speed_up_multiplier
		elif event.is_action_released("ui_accept"):
			target_speed = base_speed
