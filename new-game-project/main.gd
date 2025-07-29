extends Node2D

# assets
@onready var option_up: AnimatedSprite2D       = $OptionUp
@onready var option_down: AnimatedSprite2D     = $OptionDown
@onready var option_left: AnimatedSprite2D     = $OptionLeft
@onready var option_right: AnimatedSprite2D    = $OptionRight
@onready var press_debounce: Timer             = $press_debounce
@onready var Boss: AnimatedSprite2D            = $boss
@onready var Player: Sprite2D                  = $player
@onready var round_timer: Timer                = $roundTimer
@onready var timer_text_box: Label             = $timerTextBox
@onready var arrow_down: Sprite2D              = $ArrowDown
@onready var arrow_left: Sprite2D              = $ArrowLeft
@onready var arrow_right: Sprite2D             = $ArrowRight
@onready var arrow_up: Sprite2D                = $ArrowUp
@onready var player_health_bar: ProgressBar    = $playerHealthBar
@onready var boss_health_bar: ProgressBar      = $bossHealthBar
@onready var background: AnimatedSprite2D      = $background
@onready var damage_multi_timer: Timer         = $damage_multi_timer

# images
const ARROW_UP_RELEASED    = preload("res://art/placeholders/arrow_up.png")
const ARROW_DOWN_RELEASED  = preload("res://art/placeholders/arrow_down.png")
const ARROW_LEFT_RELEASED  = preload("res://art/placeholders/arrow_left.png")
const ARROW_RIGHT_RELEASED = preload("res://art/placeholders/arrow_right.png")
const ARROW_UP_PRESSED     = preload("res://art/placeholders/arrow-up_pressed.png")
const ARROW_DOWN_PRESSED   = preload("res://art/placeholders/arrow_down_pressed.png")
const ARROW_LEFT_PRESSED   = preload("res://art/placeholders/arrow_left_pressed.png")
const ARROW_RIGHT_PRESSED  = preload("res://art/placeholders/arrow_right_pressed.png")

# game state
var playerHealth         = 100.0
var bossHealth           = 100.0
var choosing_fruit       = false
var chosen_fruit         = null
var current_stage        = 1
var combo_count          = 0
var damage_multi_active  = false
var apple_low_chance     = false

var bossTurn  = false
var playerTurn = true

enum Difficulty { EASY, MEDIUM, HARD }
var boss_difficulty = Difficulty.MEDIUM

var boss_base_position   : Vector2
var player_base_position : Vector2

var bosses = [
	{ "name": "Boss",    "frame": 0, "stage": 1 },
	{ "name": "enemy_1", "frame": 1, "stage": 2 },
	{ "name": "enemy_2", "frame": 2, "stage": 3 },
	{ "name": "enemy_3", "frame": 3, "stage": 4 },
	{ "name": "enemy_4", "frame": 4, "stage": 5 },
]

var fruit_chances = {
	"apple": 12.5,
	"rotten apple": 12.5,
	"banana": 12.5,
	"berry": 12.5,
	"durian": 12.5,
	"eaten apple": 12.5,
	"hot pepper": 12.5,
	"reaper pepper": 12.5,
}

func round_to_dec(num: float, digit: int) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _ready() -> void:
	# cache base positions to avoid tween drift
	boss_base_position   = Boss.position
	player_base_position = Player.position

	round_timer.start()
	update_stage()

func update_stage() -> void:
	for v in bosses:
		if v.stage == current_stage:
			Boss.frame       = v.frame
			background.frame = v.stage

func apply_damage(target: String, amt: float) -> void:
	var amount = amt
	if damage_multi_active:
		amount *= (combo_count + 1)
	damage_multi_active = false
	if damage_multi_timer.time_left > 0:
		amount *= damage_multi_timer.get_meta("multi_amount")

	if target == "boss":
		var tween = get_tree().create_tween()
		tween.tween_property(Player, "position",
			player_base_position + Vector2(30, 0), 0.075
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Player, "position",
			player_base_position, 0.03
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		bossHealth -= amount

	elif target == "player":
		var tween = get_tree().create_tween()
		tween.tween_property(Boss, "position",
			boss_base_position + Vector2(-30, 0), 0.075
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Boss, "position",
			boss_base_position, 0.03
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		playerHealth -= amount

func heal(target: String, amount: float) -> void:
	if target == "player":
		playerHealth += amount
	elif target == "boss":
		bossHealth += amount

func choose_random_fruits() -> Array:
	var chosen = []
	var pool = fruit_chances.duplicate()
	if apple_low_chance:
		pool["apple"] = 5.0
	for fruit in pool.keys():
		if fruit != "apple" and apple_low_chance:
			pool[fruit] = 12.5

	while chosen.size() < 4 and pool.size() > 0:
		var total = 0.0
		for c in pool.values():
			total += c
		var rand = randi() % int(total)
		var cum = 0.0
		for f in pool.keys():
			cum += pool[f]
			if rand < cum:
				chosen.append(convert_num_name(f))
				pool.erase(f)
				break
	return chosen

func convert_num_name(input) -> Variant:
	if typeof(input) == TYPE_STRING:
		for f in FruitsDB.fruits:
			if f.name.to_lower() == input:
				return f.index
	elif typeof(input) == TYPE_INT:
		for f in FruitsDB.fruits:
			if f.index == input:
				return f.name
	return null

func use_fruit(fruit_index: int) -> void:
	for f in FruitsDB.fruits:
		if f.index == fruit_index:
			var e = f.effects
			match e.type:
				"damage":
					apply_damage(e.target, e.amount)
				"heal":
					heal(e.target, e.amount)
				"power up":
					match e.action:
						"multi next hit":
							damage_multi_active = true
							combo_count += 1
						"2x damage":
							damage_multi_timer.wait_time = e.length
							damage_multi_timer.set_meta("multi_amount", e.amount)
						"reduce apple spawn":
							apple_low_chance = true

func evaluate_fruit(index: int) -> float:
	var fruit = FruitsDB.fruits.find(f -> f.index == index)
	if fruit == null:
		return -INF
	var e = fruit.effects
	var score = 0.0

	var aggression       = 1.0
	var self_preservation = 1.0
	var strategy         = 1.0

	match boss_difficulty:
		Difficulty.EASY:
			aggression = 0.5
			self_preservation = 0.5
			strategy = 0.3
		Difficulty.MEDIUM:
			aggression = 1.0
			self_preservation = 1.0
			strategy = 1.0
		Difficulty.HARD:
			aggression = 1.5
			self_preservation = 1.2
			strategy = 1.3

	match e.type:
		"damage":
			if e.target == "player":
				score += aggression * (20.0 * (1.0 - playerHealth / 100.0))
			else:
				score -= 100.0
		"heal":
			if e.target == "boss" and bossHealth < 60:
				score += self_preservation * ((100.0 - bossHealth) * 0.5)
			else:
				score -= 10.0
		"power up":
			if e.target == "player":
				score -= 15.0 * strategy
			else:
				score += 10.0 * strategy
				if e.action == "2x damage" and playerHealth > 40:
					score += 10.0 * strategy
				if e.action == "reduce apple spawn":
					score += (5.0 if not apple_low_chance else -10.0) * strategy
				if e.action == "multi next hit":
					score += (5.0 + combo_count * 2.0) * strategy

	return score

func handle_boss_turn() -> void:
	# short delay before boss acts
	await get_tree().create_timer(0.5).timeout

	var options = choose_random_fruits()
	var best = options[0]
	var best_score = -INF
	for idx in options:
		var sc = evaluate_fruit(idx)
		if sc > best_score:
			best_score = sc
			best = idx

	use_fruit(best)

	# delay before returning control
	await get_tree().create_timer(0.5).timeout

	bossTurn = false
	playerTurn = true
	choosing_fruit = false

func _process(_delta: float) -> void:
	# update difficulty by stage
	match current_stage:
		1, 2:
			boss_difficulty = Difficulty.EASY
		3, 4:
			boss_difficulty = Difficulty.MEDIUM
		5:
			boss_difficulty = Difficulty.HARD

	update_stage()

	# timer display
	timer_text_box.text = str(round(round_timer.time_left))

	# health bars
	player_health_bar.value = round_to_dec(playerHealth, 1)
	boss_health_bar.value   = round_to_dec(bossHealth, 1)

	if player_health_bar.value <= 0:
		print("PLAYER HAS DIED")
	elif boss_health_bar.value <= 0:
		print("BOSS HAS DIED MOVING ONTO NEXT ROUND")

	# player input & turn
	if playerTurn:
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

		# reset arrow visuals
		if Input.is_action_just_released("up_arrow"):
			arrow_up.texture = ARROW_UP_RELEASED
		elif Input.is_action_just_released("down_arrow"):
			arrow_down.texture = ARROW_DOWN_RELEASED
		elif Input.is_action_just_released("left_arrow"):
			arrow_left.texture = ARROW_LEFT_RELEASED
		elif Input.is_action_just_released("right_arrow"):
			arrow_right.texture = ARROW_RIGHT_RELEASED

		# once chosen, apply and hand off to boss
		if not choosing_fruit and chosen_fruit != null:
			use_fruit(chosen_fruit)
			var fruits = choose_random_fruits()
			option_up.frame    = fruits[0]
			option_down.frame  = fruits[1]
			option_left.frame  = fruits[2]
			option_right.frame = fruits[3]
			choosing_fruit = true
			playerTurn = false
			bossTurn = true
			handle_boss_turn()
