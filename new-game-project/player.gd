extends Node

@onready var FruitsDB = get_node("/root/FruitsDB")
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
@onready var player_damage_multi_timer: Timer = $player_damage_multi_timer
@onready var background: AnimatedSprite2D = $background
@onready var player_combo_display: Label = $player_combo_display

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


var playerHealth = 100.0
var player_combo_count = 0
var apple_low_chance_player = false
var damage_multi_active_player = false
var chosen_fruit = null
var choosing_fruit = false


const DEFAULT_CHANCE: float = 12.5

var fruit_chances := {
	"apple": DEFAULT_CHANCE,
	"rotten apple": DEFAULT_CHANCE,
	"banana": DEFAULT_CHANCE,
	"berry": DEFAULT_CHANCE,
	"durian": DEFAULT_CHANCE,
	"eaten apple": DEFAULT_CHANCE,
	"hot pepper": DEFAULT_CHANCE,
	"reaper pepper": DEFAULT_CHANCE
}

func choose_random_fruits() -> Array:
	var pool = fruit_chances.duplicate()
	if apple_low_chance_player:
		pool["apple"] = 5.0
		for key in pool.keys():
			if key != "apple":
				pool[key] = 13.57
	else:
		for key in pool.keys():
			pool[key] = DEFAULT_CHANCE

	var chosen := []
	while chosen.size() < 4 and pool.size() > 0:
		var total: float = 0.0
		for chance in pool.values():
			total += chance
		var rand = randi() % int(total)
		var cum: float = 0.0
		for key in pool.keys():
			cum += pool[key]
			if rand < cum:
				chosen.append(convert_num_name(key))
				pool.erase(key)
				break
	return chosen

func convert_num_name(input) -> Variant:
	if typeof(input) == TYPE_STRING:
		for fruit in FruitsDB.fruits:
			if fruit["name"].to_lower() == input:
				return fruit["index"]
	elif typeof(input) == TYPE_INT:
		for fruit in FruitsDB.fruits:
			if fruit["index"] == input:
				return fruit["name"]
	return null

func apply_damage_to_boss(amount: float) -> void:
	var damage = null
	if damage_multi_active_player:
		amount = player_combo_count * amount
	damage_multi_active_player = false
	get_parent().tween_player_attack_animation()
	get_parent().bossHealth -= damage

func heal_player(amount: float) -> void:
	playerHealth += amount

func use_fruit(fruit_index: int) -> void:
	print("Player using ", convert_num_name(fruit_index))
	var fruit = null
	for f in FruitsDB.fruits:
		if f["index"] == fruit_index:
			fruit = f
			break
	if fruit == null:
		push_error("Fruit index not found: " + str(fruit_index))
		return

	var effect = fruit["effects"]
	match effect["type"]:
		"damage":
			apply_damage_to_boss(effect["amount"])
		"heal":
			heal_player(effect["amount"])
		"power up":
			match effect["action"]:
				"multi next hit":
					damage_multi_active_player = true
					player_combo_count += 1
				"2x damage":
					get_parent().player_damage_multi_timer.set_meta("multi_amount", effect["amount"])
				"reduce apple spawn":
					apple_low_chance_player = true

func _process(_delta) -> void:
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
		press_debounce.start()
	elif Input.is_action_just_released("down_arrow"):
		arrow_down.texture = ARROW_DOWN_RELEASED
		press_debounce.start()
	elif Input.is_action_just_released("left_arrow"):
		arrow_left.texture = ARROW_LEFT_RELEASED
		press_debounce.start()
	elif Input.is_action_just_released("right_arrow"):
		arrow_right.texture = ARROW_RIGHT_RELEASED
		press_debounce.start()

	if choosing_fruit == false:
		if chosen_fruit != null:
			use_fruit(chosen_fruit)
		var fruits = choose_random_fruits()
		option_up.frame = fruits[0]
		option_down.frame = fruits[1]
		option_left.frame = fruits[2]
		option_right.frame = fruits[3]
		choosing_fruit = true
