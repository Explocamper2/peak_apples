extends Node2D

# assets
@onready var option_up: AnimatedSprite2D = $OptionUp
@onready var option_down: AnimatedSprite2D = $OptionDown
@onready var option_left: AnimatedSprite2D = $OptionLeft
@onready var option_right: AnimatedSprite2D = $OptionRight
@onready var press_debounce: Timer = $press_debounce
@onready var Boss: AnimatedSprite2D = $boss
@onready var Player: Sprite2D = $player
@onready var round_timer: Timer = $roundTimer
@onready var timer_text_box: Label = $timerTextBox
@onready var arrow_down: Sprite2D = $ArrowDown
@onready var arrow_left: Sprite2D = $ArrowLeft
@onready var arrow_right: Sprite2D = $ArrowRight
@onready var arrow_up: Sprite2D = $ArrowUp
@onready var player_health_bar: ProgressBar = $playerHealthBar
@onready var boss_health_bar: ProgressBar = $bossHealthBar
@onready var background: AnimatedSprite2D = $background
@onready var damage_multi_timer: Timer = $damage_multi_timer

# images
const ARROW_UP_RELEASED = preload("res://art/placeholders/arrow_up.png")
const ARROW_DOWN_RELEASED = preload("res://art/placeholders/arrow_down.png")
const ARROW_LEFT_RELEASED = preload("res://art/placeholders/arrow_left.png")
const ARROW_RIGHT_RELEASED = preload("res://art/placeholders/arrow_right.png")
const ARROW_UP_PRESSED = preload("res://art/placeholders/arrow-up_pressed.png")
const ARROW_DOWN_PRESSED = preload("res://art/placeholders/arrow_down_pressed.png")
const ARROW_LEFT_PRESSED = preload("res://art/placeholders/arrow_left_pressed.png")
const ARROW_RIGHT_PRESSED = preload("res://art/placeholders/arrow_right_pressed.png")
const PLAYER_AVATAR = preload("res://art/placeholders/Characters/player.png")

var playerHealth = 100
var bossHealth = 100
var choosing_fruit = false
var chosen_fruit = null
var current_stage = 1
var combo_count = 0
var damage_multi_active = false
var apple_low_chance = false



var bosses = [
	{
		"name": "Boss",
		"frame": 0,
		"stage": 1
	},
	{
		"name": "enemy_1",
		"frame": 1,
		"stage": 2
	},
	{
		"name": "enemy_2",
		"frame": 2,
		"stage": 3
	},
	{
		"name": "enemy_3",
		"frame": 3,
		"stage": 4
	},
	{
		"name": "enemy_4",
		"frame": 4,
		"stage": 5
	}
]




func _ready() -> void:
	round_timer.start()
	update_stage()

func update_stage():
	for v in bosses:
		var boss_stage = v["stage"]
		if boss_stage == current_stage:
			Boss.frame = v.frame
			background.frame = boss_stage

func apply_damage(target, a):
	var amount = a
	if damage_multi_active == true:
		amount = amount * 2
	else: pass
	damage_multi_active = false
	if damage_multi_timer.time_left > 0:
		amount = amount * damage_multi_timer.get_meta("multi_amount")
	print("Dealing ", amount, " damage to ", target)
	
	if target == "boss":
		bossHealth -= amount
	elif target == "player":
		playerHealth -= amount

func heal(target, amount):
	print("Healing", target, " by ", amount, " points")
	if target == "player":
		playerHealth += amount
	elif target == "boss":
		bossHealth += amount


var fruit_chances = {
	"apple": 12.5,
	"rotten apple": 12.5,
	"banana": 12.5,
	"berry": 12.5,
	"durian": 12.5,
	"eaten apple": 12.5,
	"hot pepper": 12.55,
	"reaper pepper": 12.5
}

func choose_random_fruits() -> Array:
	var chosen = []
	var pool = fruit_chances.duplicate()
	if apple_low_chance == true:
		for fruit in fruit_chances:
			if fruit == "apple":
				fruit_chances["apple"] = 5
			else: fruit = "13.57"
	else: for fruit in fruit_chances: fruit = 12.5
	
	while chosen.size() < 4 and pool.size() > 0:
		var total_chance = 0
		for chance in pool.values():
			total_chance += chance

		var rand = randi() % int(total_chance)
		var cumulative = 0

		for fruit in pool.keys():
			cumulative += pool[fruit]
			if rand < cumulative:
				chosen.append(convert_num_name(fruit))
				pool.erase(fruit)
				break
	return chosen

func convert_num_name(input):
	if typeof(input) == TYPE_STRING:
		for fruit in FruitsDB.fruits:
			if fruit["name"].to_lower() == input:
				return fruit["index"]
	elif typeof(input) == TYPE_INT:
		for fruit in FruitsDB.fruits:
			if fruit["index"] == input:
				return fruit["name"]

func use_fruit(fruit_index):
	print(fruit_index)
	for fruit in FruitsDB.fruits:
		if fruit["index"] == fruit_index:
			# damage, power up
			var effects = fruit["effects"]
			var type = effects["type"]
			var amount = effects["amount"]
			var action = effects["action"]
			var target = effects["target"]
			
			if type == "damage":
				apply_damage(target, amount)
			elif type == "heal":
					heal(target, amount)
			elif type == "power up": # multi next hit, 2x damage (5 sec), reduce apple spawn
				if action == "multi next hit":
					# apply 2x damage for next hit
					damage_multi_active = true
				elif action == "2x damage":
					# have 2x damage for 5 sec
					damage_multi_timer.wait_time = effects["length"]
					damage_multi_timer.set_meta("multi_amount", amount)
				elif action == "reduce apple spawn":
					apple_low_chance = true
					

func _process(_delta) -> void:
	update_stage()
	# fruits
	if choosing_fruit == false:
		use_fruit(chosen_fruit)
		var fruits = choose_random_fruits()
		# print("fruits: ", fruits)
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
		if Input.is_action_just_pressed("up_arrow"):
			press_debounce.start()
			arrow_up.texture = ARROW_UP_PRESSED
			chosen_fruit = option_up.frame
			choosing_fruit = false
		elif Input.is_action_just_pressed("down_arrow"):
			press_debounce.start()
			arrow_down.texture = ARROW_DOWN_PRESSED
			chosen_fruit = option_down.frame
			choosing_fruit = false
		elif Input.is_action_just_pressed("left_arrow"):
			press_debounce.start()
			arrow_left.texture = ARROW_LEFT_PRESSED
			chosen_fruit = option_left.frame
			choosing_fruit = false
		elif Input.is_action_just_pressed("right_arrow"):
			press_debounce.start()
			arrow_right.texture = ARROW_RIGHT_PRESSED
			chosen_fruit = option_right.frame
			choosing_fruit = false
			
	if Input.is_action_just_released("up_arrow"):
		arrow_up.texture = ARROW_UP_RELEASED
	elif Input.is_action_just_released("down_arrow"):
		arrow_down.texture = ARROW_DOWN_RELEASED
	elif Input.is_action_just_released("left_arrow"):
		arrow_left.texture = ARROW_LEFT_RELEASED
	elif Input.is_action_just_released("right_arrow"):
		arrow_right.texture = ARROW_RIGHT_RELEASED
	
	
