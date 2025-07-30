extends Node

@onready var FruitsDB = get_node("/root/FruitsDB")


enum Difficulty { EASY, MEDIUM, HARD }
var boss_difficulty: Difficulty = Difficulty.MEDIUM

# Boss stats
var bossHealth = 100.0
var boss_combo_count = 0
var apple_low_chance_boss = false
var damage_multi_active_boss = false

const DEFAULT_CHANCE = 12.5

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
	if apple_low_chance_boss:
		pool["apple"] = 5.0
		for key in pool.keys():
			if key != "apple":
				pool[key] = DEFAULT_CHANCE + 1.07
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


func evaluate_fruit(index: int, current_stage: int, playerHealth: float) -> float:
	var fruit = null
	for f in FruitsDB.fruits:
		if f["index"] == index:
			fruit = f
			break
	if fruit == null:
		return -INF

	var effect = fruit["effects"]
	var score: float = 0.0

	var aggression: float = 1.0
	var self_preservation: float = 1.0
	var strategy: float = 1.0
	match boss_difficulty:
		Difficulty.EASY:
			aggression = 0.5; self_preservation = 0.5; strategy = 0.3
		Difficulty.MEDIUM:
			aggression = 1.0; self_preservation = 1.0; strategy = 1.0
		Difficulty.HARD:
			aggression = 1.5; self_preservation = 1.2; strategy = 1.3

	match effect["type"]:
		"damage":
			if effect["target"] == "player":
				score += aggression * (20.0 * (1.0 - playerHealth / 100.0))
			else:
				score -= 100.0
		"heal":
			if effect["target"] == "boss" and bossHealth < 60:
				score += self_preservation * ((100.0 - bossHealth) * 0.5)
			else:
				score -= 10.0
		"power up":
			if effect["target"] == "player":
				score -= 15.0 * strategy
			else:
				score += 10.0 * strategy
				if effect["action"] == "2x damage" and playerHealth > 40:
					score += 10.0 * strategy
				if effect["action"] == "reduce apple spawn":
					score += (5.0 if not apple_low_chance_boss else -10.0) * strategy
				if effect["action"] == "multi next hit":
					score += (5.0 + boss_combo_count * 2.0) * strategy

	match current_stage:
		1:
			if fruit["name"] == "Apple":
				score += 20.0 * aggression
			else:
				score -= 10.0
		2:
			if fruit["name"] == "Banana":
				score += 30.0 * self_preservation
			else:
				score -= 15.0
		3:
			if fruit["name"] == "Berry":
				if boss_combo_count < 3:
					score += 25.0 * strategy
				else:
					score += 5.0
			elif fruit["name"] == "Apple":
				if boss_combo_count >= 3:
					score += 50.0 * aggression
				else:
					score += 10.0
			else:
				score -= 10.0
		4:
			if fruit["name"] == "Durian":
				score += 25.0 * strategy
		5:
			if fruit["name"] == "Reaper Pepper":
				score += 50.0 * aggression
			elif effect["type"] == "damage":
				score += 5.0
	return score

func apply_damage_to_player(amount: float) -> void:
	var damage = null
	if damage_multi_active_boss:
		amount = amount * boss_combo_count
	damage_multi_active_boss = false
	get_parent().tween_boss_attack_animation()
	get_parent().playerHealth -= damage


func heal_boss(amount: float) -> void:
	bossHealth += amount

func handle_turn(current_stage: int, playerHealth: float) -> void:
	print("boss turn time")
	var options = choose_random_fruits()
	var best_index = options[0]
	var best_score = -INF
	for idx in options:
		var sc = evaluate_fruit(idx, current_stage, playerHealth)
		if sc > best_score:
			best_score = sc
			best_index = idx
	print("best option for boss out of ", options, " is ", best_index)
	get_parent().boss_choice.frame = best_index
	use_fruit(best_index)

func use_fruit(fruit_index: int) -> void:
	print("Boss using ", convert_num_name(fruit_index))
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
			apply_damage_to_player(effect["amount"])
		"heal":
			heal_boss(effect["amount"])
		"power up":
			match effect["action"]:
				"multi next hit":
					damage_multi_active_boss = true
					boss_combo_count += 1
				"2x damage":
					get_parent().boss_damage_multi_timer.set_meta("multi_amount", effect["amount"])
				"reduce apple spawn":
					apple_low_chance_boss = true
