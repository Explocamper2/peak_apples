extends Node

var fruits = [
	{
		"name": "Apple",
		"image": preload("res://art/placeholders/fruit_apple.png"),
		"index": 0,
		"effects": {
			"type": "damage",
			"amount": 1,
			"action": "",
			"target": "opponent",
		},
	},
	{
		"name": "Rotten Apple",
		"image": preload("res://art/placeholders/fruit_apple_rotten.png"),
		"index": 1,
		"effects": {
			"type": "damage",
			"amount": 1,
			"action": "",
			"target": "self",
		},
	},
	{
		"name": "Banana",
		"image": preload("res://art/placeholders/fruit_banana.png"),
		"index": 2,
		"effects": {
			"type": "heal",
			"amount": 1,
			"action": "",
			"target": "self",
		},
	},
	{
		"name": "Berry",
		"image": preload("res://art/placeholders/fruit_berry.png"),
		"index": 3,
		"effects": {
			"type": "power up",
			"amount": 2,
			"action": "multi next hit",
			"target": "self",
		},
	},
	{
		"name": "Durian",
		"image": preload("res://art/placeholders/fruit_durian.png"),
		"index": 4,
		"effects": {
			"type": "power up",
			"amount": 1,
			"action": "reduce apple spawn",
			"target": "self",
		},
	},
	{
		"name": "Eaten Apple",
		"image": preload("res://art/placeholders/fruit_eaten_apple.png"),
		"index": 5,
		"effects": {
			"type": "damage",
			"amount": 0.5,
			"action": "",
			"target": "self",
		},
	},
	{
		"name": "Hot Pepper",
		"image": preload("res://art/placeholders/fruit_hot_pepper.png"),
		"index": 6,
		"effects": {
			"type": "power up",
			"amount": 2,
			"length": 5,
			"action": "2x damage",
			"target": "self",
		},
	},
	{
		"name": "Reaper Pepper",
		"image": preload("res://art/placeholders/fruit_reaper_pepper.png"),
		"index": 7,
		"effects": {
			"type": "damage",
			"amount": 3,
			"action": "",
			"target": "self",
		},
	}
]
