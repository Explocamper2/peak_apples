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
@onready var player_health_bar: TextureProgressBar = $playerHealthBar
@onready var boss_health_bar: TextureProgressBar = $bossHealthBar
@onready var player_damage_multi_timer: Timer = $player_damage_multi_timer
@onready var boss_damage_multi_timer: Timer = $boss_damage_multi_timer
@onready var background: AnimatedSprite2D = $background
@onready var boss_timer: Timer = $boss_timer
@onready var boss_choice: AnimatedSprite2D = $BossChoice
@onready var player_combo_display: Label = $player_combo_display
@onready var boss_combo_display: Label = $boss_combo_display
@onready var camera: Camera2D = $Camera
@onready var boss_health_indicator: Label = $boss_health_indicator

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

const DEFAULT_CHANCE = 12.5

var playerHealth = 100
var bossHealth = 100
var choosing_fruit = false
var chosen_fruit = null
var current_stage = 1
var player_combo_count = 0
var boss_combo_count = 0
var damage_multi_active = false
var apple_low_chance = false


enum Difficulty { EASY, MEDIUM, HARD }
var boss_difficulty = Difficulty.EASY


var bosses = [
	{
		"name": "enemy_1",
		"frame": 0,
		"stage": 1
	},
	{
		"name": "enemy_2",
		"frame": 1,
		"stage": 2
	},
	{
		"name": "enemy_3",
		"frame": 2,
		"stage": 3
	},
	{
		"name": "enemy_4",
		"frame": 3,
		"stage": 4
	},
	{
		"name": "Boss",
		"frame": 4,
		"stage": 5
	}
]


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _ready() -> void:
	round_timer.start()
	boss_timer.start()
	update_stage()

func update_stage():
	for v in bosses:
		var boss_stage = v["stage"]
		if boss_stage == current_stage:
			Boss.frame = v.frame
			background.frame = boss_stage

func apply_damage(target, a, damageCombo):
	var amount = a
	var combo = damageCombo
	if damage_multi_active == true:
		combo += 1
		damage_multi_active = false
	if boss_damage_multi_timer.time_left > 0:
		combo += 1
	if player_damage_multi_timer.time_left > 0:
		combo += 1
	amount = amount * combo
	boss_health_indicator.text = str(-amount)
	print("Dealing ", amount, " damage to ", target)
	
	# actually take the damage
	if target == "boss":
		var tween = get_tree().create_tween()
		var original_pos = Player.position
		var attack_offset = Vector2(30, 0)
		# camera shake
		camera.apply_shake(amount)
		tween.tween_property(Player, "position", original_pos + attack_offset, 0.075).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Player, "position", original_pos, 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		bossHealth -= amount
		await get_tree().create_timer(0.5).timeout
		camera.apply_shake(0)
		
	elif target == "player":
		var tween = get_tree().create_tween()
		var original_pos = Boss.position
		var attack_offset = Vector2(-30, 0)
		# camera shake
		camera.apply_shake(amount)
		tween.tween_property(Boss, "position", original_pos + attack_offset, 0.075).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(Boss, "position", original_pos, 0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		playerHealth -= amount
		await get_tree().create_timer(0.5).timeout
		camera.apply_shake(0)

func heal(target, amount):
	print("Healing", target, " by ", amount, " points")
	if target == "player":
		playerHealth += amount
	elif target == "boss":
		bossHealth += amount



var fruit_chances = {
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
	var chosen = []
	var pool = fruit_chances.duplicate()
	if apple_low_chance == true:
		for fruit in fruit_chances:
			if fruit == "apple":
				fruit_chances["apple"] = 5
			else: fruit = "13.57"
	else: for fruit in fruit_chances: fruit = DEFAULT_CHANCE
	
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

func use_fruit(fruit_index: int, by_boss: bool) -> void:
	# find the fruit dict
	if by_boss: print("Boss using ", convert_num_name(fruit_index))
	else: print("Player using ", convert_num_name(fruit_index))
	var fruit = null
	for f in FruitsDB.fruits:
		if f["index"] == fruit_index:
			fruit = f
	if fruit == null:
		ERR_DOES_NOT_EXIST
		return

	var effect = fruit["effects"]
	var intended = effect["target"]
	var actual_target = ""
	if intended == "self":
		if by_boss: actual_target = "boss"
		else: actual_target = "player"
	else:
		if by_boss: actual_target = "player"
		else: actual_target = "boss"

	# apply effect
	match effect["type"]:
		"damage":
			if by_boss:
				apply_damage(actual_target, effect["amount"], boss_combo_count)
				boss_combo_count = 0
			else:
				apply_damage(actual_target, effect["amount"], player_combo_count)
				player_combo_count = 0
		"heal":
			heal(actual_target, effect["amount"])
			if by_boss:
				boss_combo_count = 0
			else:
				player_combo_count = 0
		"power up":
			match effect["action"]:
				"multi next hit":
					if by_boss:
						boss_combo_count += 1
						print("Boss combo: ", boss_combo_count)
					else:
						player_combo_count += 1
						print("Player combo: ", player_combo_count)
				"2x damage":
					if by_boss:
						boss_damage_multi_timer.wait_time = effect["length"]
						boss_damage_multi_timer.set_meta("multi_amount", effect["amount"])
						boss_damage_multi_timer.start()
					else:
						player_damage_multi_timer.wait_time = effect["length"]
						player_damage_multi_timer.set_meta("multi_amount", effect["amount"])
						player_damage_multi_timer.start()
				"reduce apple spawn":
					apple_low_chance = true
					if by_boss:
						boss_combo_count = 0
					else:
						player_combo_count = 0

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
			aggression = 0.25; self_preservation = 0.25; strategy = 0.3
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
					score += (5.0 + boss_combo_count * 2.0) * strategy

	# --- Boss‐specific adjustments ---
	# current_stage 1→E1, 2→E2, 3→E3, 4→E4, 5→E5
	match current_stage:
		1:  # E1: normal hits (favours Apple)
			if fruit.name == "Apple":
				score += 50.0 * aggression
			else:
				score -= 10.0
		2:  # E2: heavy healer (favours Banana)
			if fruit.name == "Banana":
				score += 30.0 * self_preservation
			else:
				score -= 15.0
		3:  # E3: charge with Berries, then one‐shot Apples
			if fruit.name == "Berry":
				if boss_combo_count < 3:
					score += 25.0 * strategy
				else:
					score += 5.0
			elif fruit.name == "Apple":
				if boss_combo_count >= 3:
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
	print("boss turn time")
	var options = choose_random_fruits()
	
	var best_index = options[0]
	var best_score = -INF
	
	for index in options:
		var score = evaluate_fruit(index)
		if score > best_score:
			best_score = score
			best_index = index
	print("best option for boss out of ", options, " is ", best_index)
	boss_choice.frame = best_index
	use_fruit(best_index, true)





func _process(_delta) -> void:
	
	# UI
	player_combo_display.text = "Current Combo: " + str(player_combo_count) 
	boss_combo_display.text = "Current Combo: " + str(boss_combo_count)
	# Timer
	timer_text_box.text = str(round(round_timer.time_left))
	
	# health bar
	player_health_bar.value = round_to_dec(playerHealth,1)
	boss_health_bar.value = round_to_dec(bossHealth,1)
	
	if player_damage_multi_timer.time_left == 0:
		player_damage_multi_timer.set_meta("multi_amount", 0)
	if boss_damage_multi_timer.time_left == 0:
		boss_damage_multi_timer.set_meta("multi_amount", 0)
	
	if player_health_bar.value <= 0:
		print("PLAYER HAS DIED")
	elif boss_health_bar.value <= 0:
		print("BOSS HAS DIED MOVING ONTO NEXT ROUND")
		current_stage += 1
		bossHealth = 100
		playerHealth = 100
		print("Now on round: ", current_stage)
		update_stage()
		
	
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


	# boss behavior
	if boss_timer.time_left == 0:
		handle_boss_turn()
		boss_timer.start()
		
	if choosing_fruit == false:
		print("player chosen fruit: ", chosen_fruit)
		if chosen_fruit != null:
			use_fruit(chosen_fruit, false)
		var fruits = choose_random_fruits()
		print("player fruits: ", fruits)
		option_up.frame = fruits[0]
		option_down.frame = fruits[1]
		option_left.frame = fruits[2]
		option_right.frame = fruits[3]
		choosing_fruit = true
		
		
