extends Node
## Stays active while the scene tree is paused so Escape can close the pause menu.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var main := get_parent()
		if main and main.has_method("toggle_pause_menu"):
			main.toggle_pause_menu()
			get_viewport().set_input_as_handled()
