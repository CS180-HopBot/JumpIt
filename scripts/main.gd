extends Node2D
const LEVEL_PATH_TEMPLATE := "res://scenes/levels/level%d.tscn"
const TITLE_SCENE := "res://scenes/title_screen.tscn"

@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var pause_layer: CanvasLayer = $PauseLayer

var score: int = 0
## Monotonic clock for rhythm (whole-second beats).
var rhythm_time: float = 0.0
var _level_index: int = 0
var _apples_total: int = 0
var _apples_collected: int = 0


func _ready() -> void:
	get_tree().paused = false
	pause_layer.hide()
	if not _load_level_at_index(0):
		push_error("Missing level: " + (LEVEL_PATH_TEMPLATE % 1))
		get_tree().change_scene_to_file(TITLE_SCENE)


func _process(delta: float) -> void:
	rhythm_time += delta


func is_within_beat_window(tolerance_sec: float) -> bool:
	var phase := fmod(rhythm_time, 1.0) + 0.5
	return minf(phase, 1.0 - phase) <= tolerance_sec


func toggle_pause_menu() -> void:
	if pause_layer.visible:
		pause_layer.hide()
		get_tree().paused = false
	else:
		pause_layer.show()
		get_tree().paused = true


func _load_level_at_index(idx: int) -> bool:
	var path: String = LEVEL_PATH_TEMPLATE % (idx + 1)
	if not ResourceLoader.exists(path):
		return false
	var old := get_node_or_null("LevelRoot")
	if old:
		remove_child(old)
		old.queue_free()
	var packed := load(path) as PackedScene
	var inst := packed.instantiate()
	inst.name = "LevelRoot"
	add_child(inst)
	move_child(inst, 0)
	_level_index = idx
	_apples_collected = 0
	_setup_level()
	score_label.text = "SCORE: %s" % score
	return true


func _setup_level() -> void:
	var apples := $LevelRoot.get_node_or_null("Apples")
	_apples_total = apples.get_child_count() if apples else 0
	if apples:
		for child in apples.get_children():
			if child.has_signal("collected"):
				child.collected.connect(_on_apple_collected)
	var enemies := $LevelRoot.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			if enemy.has_signal("player_died"):
				enemy.player_died.connect(_on_player_died)


func _on_apple_collected() -> void:
	increase_score()
	_apples_collected += 1
	if _apples_collected >= _apples_total and _apples_total > 0:
		call_deferred("_on_level_complete")


func _on_level_complete() -> void:
	if get_tree().paused:
		return
	var next_idx := _level_index + 1
	if not _load_level_at_index(next_idx):
		_exit_to_title()


func _exit_to_title() -> void:
	get_tree().paused = false
	if pause_layer:
		pause_layer.hide()
	get_tree().change_scene_to_file(TITLE_SCENE)


func _on_player_died(body) -> void:
	body.die()


func increase_score() -> void:
	score += 1
	score_label.text = "SCORE: %s" % score
