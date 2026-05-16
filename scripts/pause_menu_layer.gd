extends CanvasLayer
## Runs while the game is paused so menu buttons still work.

const TITLE_SCENE := "res://scenes/title_screen.tscn"


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_title_pressed() -> void:
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file(TITLE_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
