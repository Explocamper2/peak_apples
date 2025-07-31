extends Control


@onready var credits_container: Control = $CreditsContainer
@onready var line: Label = $CreditsContainer/Line

const base_speed := 30
const speed_up_multiplier := 2.0
const lerp_speed = 5.0
const title_color := Color(0.541176, 0.168627, 0.886275, 1)
var scroll_speed := base_speed
var current_speed := base_speed
var target_speed := base_speed

func _process(delta):
	current_speed = lerp(current_speed, target_speed, lerp_speed)
	line.position.y -= current_speed * delta

func _input(event):
	if event.is_action_pressed("ui_accept"):
		target_speed = base_speed * speed_up_multiplier
	elif event.is_action_released("ui_accept"):
		target_speed = base_speed
