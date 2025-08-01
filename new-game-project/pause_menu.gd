extends TextureRect
@onready var pause_menu: TextureRect = $"."

var paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = not paused
		get_tree().paused = paused
		pause_menu.visible = paused
