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
var choosing_fruit = true
var chosen_fruit = null
var current_stage = 1
var combo_count = 0
var damage_multi_active = false
var apple_low_chance = false

var bossTurn = false
var playerTurn = true
enum Difficulty { EASY, MEDIUM, HARD }
var boss_difficulty = Difficulty.MEDIUM


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


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

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
		amount = amount * (combo_count+1)
	else: pass
	damage_multi_active = false
	if damage_multi_timer.time_left > 0:
		amount = amount * damage_multi_timer.get_meta("multi_amount")
	print("Dealing ", amount, " damage to ", target)
	
	# actually take the damage
	if target == "boss":
		var tween = get_tree().create_tween()
		var original_pos = Player.position
		var attack_offset = Vector2(30, 0)
		tween.tween_property(Player, "position", original_pos + attack_offset, 0.075).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Player, "position", original_pos, 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		bossHealth -= amount
	elif target == "player":
		var tween = get_tree().create_tween()
		var original_pos = Boss.position
		var attack_offset = Vector2(-30, 0)
		tween.tween_property(Boss, "position", original_pos + attack_offset, 0.075).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Boss, "position", original_pos, 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
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

func use_fruit(fruit_index: int, by_boss: bool=false) -> void:
	# find the fruit dict
	var fruit = null
	for f in FruitsDB.fruits:
		if f["index"] == fruit_index:
			fruit = f
	if fruit == null: return

	var effect = fruit["effects"]
	var intended = effect["target"]
	var actual_target = ""
	if intended == "self":
		if by_boss:
			actual_target = "boss"
		else:
			actual_target = "player"
	else:
		if by_boss:
			actual_target = "player"
		else:
			actual_target = "boss"

	# apply effect
	match effect["type"]:
		"damage": apply_damage(actual_target, effect["amount"])
		"heal":   heal(actual_target, effect["amount"])
		"power up":
			match effect["action"]:
				"multi next hit":
					damage_multi_active = true
					combo_count += 1
				"2x damage":
					damage_multi_timer.wait_time = effect["length"]
					damage_multi_timer.set_meta("multi_amount", effect["amount"])
				"reduce apple spawn":
					apple_low_chance = true

func evaluate_fruit(index: int) -> float:
	var fruit = null
	for f in FruitsDB.fruits:
		if f["index"] == index:
			fruit = f
			break

	var effect = fruit["effects"]
	var score = 0.0

	# Base multipliers by difficulty
	var aggression = 1.0
	var self_preservation = 1.0
	var strategy = 1.0
	match boss_difficulty:
		Difficulty.EASY:
			aggression = 0.5; self_preservation = 0.5; strategy = 0.3
		Difficulty.MEDIUM:
			aggression = 1.0; self_preservation = 1.0; strategy = 1.0
		Difficulty.HARD:
			aggression = 1.5; self_preservation = 1.2; strategy = 1.3

	# --- Generic scoring ---
	match effect.type:
		"damage":
			if effect.target == "player":
				score += aggression * (20.0 * (1.0 - playerHealth / 100.0))
			else:
				score -= 100.0
		"heal":
			if effect.target == "boss" and bossHealth < 60:
				score += self_preservation * ((100.0 - bossHealth) * 0.5)
			else:
				score -= 10.0
		"power up":
			if effect.target == "player":
				score -= 15.0 * strategy
			else:
				score += 10.0 * strategy
				if effect.action == "2x damage" and playerHealth > 40:
					score += 10.0 * strategy
				if effect.action == "reduce apple spawn":
					score += (5.0 if not apple_low_chance else -10.0) * strategy
				if effect.action == "multi next hit":
					score += (5.0 + combo_count * 2.0) * strategy

	# --- Boss‐specific adjustments ---
	# current_stage 1→E1, 2→E2, 3→E3, 4→E4, 5→E5
	match current_stage:
		1:  # E1: normal hits (favours Apple)
			if fruit.name == "Apple":
				score += 20.0 * aggression
			else:
				score -= 10.0
		2:  # E2: heavy healer (favours Banana)
			if fruit.name == "Banana":
				score += 30.0 * self_preservation
			else:
				score -= 15.0
		3:  # E3: charge with Berries, then one‐shot Apples
			if fruit.name == "Berry":
				if combo_count < 3:
					score += 25.0 * strategy
				else:
					score += 5.0
			elif fruit.name == "Apple":
				if combo_count >= 3:
					score += 50.0 * aggression
				else:
					score += 10.0
			else:
				score -= 10.0
		4:  # E4: (favours Durian)
			if fruit.name == "Durian":
				score += 25.0 * strategy
			else:
				score += 0.0
		5:  # E5: (favours Reaper Pepper)
			if fruit.name == "Reaper Pepper":
				score += 50.0 * aggression
			else:
				if effect.type == "damage":
					score += 5.0
				else:
					score += 0.0
	return score

func handle_boss_turn():
	await get_tree().create_timer(0.5).timeout
	var options = choose_random_fruits()
	
	var best_index = options[0]
	var best_score = -INF
	
	for index in options:
		var score = evaluate_fruit(index)
		if score > best_score:
			best_score = score
			best_index = index
	use_fruit(best_index, true)
	await  get_tree().create_timer(0.5).timeout

func _process(_delta) -> void:
	update_stage()
	
	# timer
	timer_text_box.text = str(round(round_timer.time_left))
	
	# health bar
	player_health_bar.value = round_to_dec(playerHealth,1)
	boss_health_bar.value = round_to_dec(bossHealth,1)
	
	if player_health_bar.value <= 0:
		print("PLAYER HAS DIED")
	elif boss_health_bar.value <= 0:
		print("BOSS HAS DIED MOVING ONTO NEXT ROUND")
		
	
	# input
	if playerTurn == true:
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

	elif bossTurn == true:
		# boss behavior
		bossTurn = false
		playerTurn = true
		handle_boss_turn()
		
	if choosing_fruit == false and playerTurn == true:
		if chosen_fruit:
			use_fruit(chosen_fruit)
		var fruits = choose_random_fruits()
		print("fruits: ", fruits)
		option_up.frame = fruits[0]
		option_down.frame = fruits[1]
		option_left.frame = fruits[2]
		option_right.frame = fruits[3]
		choosing_fruit = true
		playerTurn = false
		bossTurn = true
		
		
