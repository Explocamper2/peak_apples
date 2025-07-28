extends Node2D

@onready var option_up: AnimatedSprite2D = $OptionUp
@onready var option_down: AnimatedSprite2D = $OptionDown
@onready var option_left: AnimatedSprite2D = $OptionLeft
@onready var option_right: AnimatedSprite2D = $OptionRight
@onready var press_debounce: Timer = $press_debounce

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
var choosing_fruit = false
var chosen_fruit = null


func _ready() -> void:
	round_timer.start()
	pass

func choose_random_fruits():
	var fruits = []
	var numbers = [0,1,2,3,4,5,6,7]
	var count = 0
	while count < 4:
		count += 1
		numbers.shuffle()
		var num = numbers[1]
		fruits.append(num)
		numbers.erase(num)
	return fruits

func use_fruit(fruit):
	print(fruit)

func _process(_delta) -> void:
	# fruits
	if choosing_fruit == false:
		use_fruit(chosen_fruit)
		var fruits = choose_random_fruits()
		option_up.frame = fruits[0]
		option_down.frame = fruits[1]
		option_left.frame = fruits[2]
		option_right.frame = fruits[3]
		choosing_fruit = true
	
	# timer
	timer_text_box.text = str(round(round_timer.time_left))
	
	# health bar
	player_health_bar.value = clamp(round(playerHealth),0,100)
	boss_health_bar.value = clamp(round(bossHealth),0,100)
	
	# input
	if press_debounce.time_left == 0:
		if Input.is_action_pressed("up_arrow"):
			arrow_up.texture = ARROW_UP_PRESSED
			chosen_fruit = option_up.frame
			choosing_fruit = false
			press_debounce.start()
		elif Input.is_action_pressed("down_arrow"):
			arrow_down.texture = ARROW_DOWN_PRESSED
			chosen_fruit = option_down.frame
			choosing_fruit = false
			press_debounce.start()
		elif Input.is_action_pressed("left_arrow"):
			arrow_left.texture = ARROW_LEFT_PRESSED
			chosen_fruit = option_left.frame
			choosing_fruit = false
			press_debounce.start()
		elif Input.is_action_pressed("right_arrow"):
			arrow_right.texture = ARROW_RIGHT_PRESSED
			chosen_fruit = option_right.frame
			choosing_fruit = false
			press_debounce.start()
			
	if Input.is_action_just_released("up_arrow"):
		arrow_up.texture = ARROW_UP_RELEASED
	elif Input.is_action_just_released("down_arrow"):
		arrow_down.texture = ARROW_DOWN_RELEASED
	elif Input.is_action_just_released("left_arrow"):
		arrow_left.texture = ARROW_LEFT_RELEASED
	elif Input.is_action_just_released("right_arrow"):
		arrow_right.texture = ARROW_RIGHT_RELEASED
	
	
