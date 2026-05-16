extends Control
## Helix-style motion: eased angle traces a semicircle (horizontal sin θ, vertical cos θ).
## Smoothstep on phase zeros speed at the beat (center line) and at both meter tips.

@onready var _indicator: Control = $Indicator
@onready var _track: Control = $Track

@onready var _signal: bool = false

#func _process(_delta: float) -> void:
	#var scene := get_tree().current_scene
	#if scene == null or not is_instance_valid(scene) or not scene.has_method("is_within_beat_window"):
		#return
	#var phase: float = fmod(scene.rhythm_time as float, 1.0)
	## 0 at beat (center), ±1 at mid-second (ends); one crossing per second.
	#var offset: float = 2 * sin(phase * PI) * _swing_radius()
	#_indicator.position.x = - _indicator.size.x * 0.5 + offset
	#_indicator.position.y = (size.y - _indicator.size.y) * 0.5

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null or not is_instance_valid(scene) or not scene.has_method("is_within_beat_window"):
		return
	var phase: float = fmod(scene.rhythm_time as float, 1.0)
	_indicator.position.x = _track.get_rect().size.x * phase
	if _indicator.position.x > _track.get_rect().size.x:
		_indicator.position.x = _track.position.x

func _ease_io(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)


func _swing_radius() -> float:
	return maxf(0.0, size.x * 0.5 - _indicator.size.x * 0.5)


func _vertical_radius() -> float:
	return maxf(0.0, (size.y - _indicator.size.y) * 0.5 * 0.42)
