extends Node2D


@onready var round_timer: Timer = $roundTimer
@onready var timer_text_box: Label = $timerTextBox
@onready var arrow_down: Sprite2D = $ArrowDown
@onready var arrow_left: Sprite2D = $ArrowLeft
@onready var arrow_right: Sprite2D = $ArrowRight
@onready var arrow_up: Sprite2D = $ArrowUp
@onready var player_health_bar: ProgressBar = $playerHealthBar
@onready var boss_health_bar: ProgressBar = $bossHealthBar
const ARROW_UP_RELEASED = preload("res://art/placeholders/arrow_up.png")
const ARROW_DOWN_RELEASED = preload("res://art/placeholders/arrow_down.png")
const ARROW_LEFT_RELEASED = preload("res://art/placeholders/arrow_left.png")
const ARROW_RIGHT_RELEASED = preload("res://art/placeholders/arrow_right.png")
const ARROW_UP_PRESSED = preload("res://art/placeholders/arrow-up_pressed.png")
const ARROW_DOWN_PRESSED = preload("res://art/placeholders/arrow_down_pressed.png")
const ARROW_LEFT_PRESSED = preload("res://art/placeholders/arrow_left_pressed.png")
const ARROW_RIGHT_PRESSED = preload("res://art/placeholders/arrow_right_pressed.png")

var playerHealth = 100
var bossHealth = 100

func _ready() -> void:
	round_timer.start()
	pass



func _process(_delta) -> void:
	timer_text_box.text = str(round(round_timer.time_left))
	
	player_health_bar.value = clamp(round(playerHealth),0,100)
	boss_health_bar.value = clamp(round(bossHealth),0,100)
	
	
	if Input.is_action_pressed("up_arrow"):
		arrow_up.texture = ARROW_UP_PRESSED
	elif Input.is_action_pressed("down_arrow"):
		arrow_down.texture = ARROW_DOWN_PRESSED
	elif Input.is_action_pressed("left_arrow"):
		arrow_left.texture = ARROW_LEFT_PRESSED
	elif Input.is_action_pressed("right_arrow"):
		arrow_right.texture = ARROW_RIGHT_PRESSED
		
	if Input.is_action_just_released("up_arrow"):
		arrow_up.texture = ARROW_UP_RELEASED
	elif Input.is_action_just_released("down_arrow"):
		arrow_down.texture = ARROW_DOWN_RELEASED
	elif Input.is_action_just_released("left_arrow"):
		arrow_left.texture = ARROW_LEFT_RELEASED
	elif Input.is_action_just_released("right_arrow"):
		arrow_right.texture = ARROW_RIGHT_RELEASED
	
	
