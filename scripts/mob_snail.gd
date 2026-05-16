extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal player_died
const SPEED = 100.0
## Horizontal probe from snail origin (matches CollisionShape2D extents).
const WALL_PROBE_X = 58.0
const WALL_PROBE_Y = 14.0
const WALL_CAST_LEN = 28.0
## Forward-down probe: no solid tile ahead of feet → ledge, turn around.
const LEDGE_PROBE_X = 52.0
const LEDGE_PROBE_Y = 28.0
const LEDGE_CAST = Vector2(10, 56)

var direction := -1
var _wall_ray: RayCast2D
var _floor_ray: RayCast2D


func _ready() -> void:
	add_to_group("snail")
	_wall_ray = RayCast2D.new()
	_floor_ray = RayCast2D.new()
	for ray in [_wall_ray, _floor_ray]:
		ray.collision_mask = 1
		ray.collide_with_areas = false
		ray.collide_with_bodies = true
		ray.enabled = true
		add_child(ray)


func _physics_process(delta: float) -> void:
	_update_ray_positions()
	_wall_ray.force_raycast_update()
	_floor_ray.force_raycast_update()
	if _terrain_hit(_wall_ray) or _ledge_ahead():
		_turn_around()
	position.x += direction * SPEED * delta


func _update_ray_positions() -> void:
	_wall_ray.position = Vector2(WALL_PROBE_X * direction, WALL_PROBE_Y)
	_wall_ray.target_position = Vector2(direction * WALL_CAST_LEN, 0.0)
	_floor_ray.position = Vector2(LEDGE_PROBE_X * direction, LEDGE_PROBE_Y)
	_floor_ray.target_position = Vector2(direction * LEDGE_CAST.x, LEDGE_CAST.y)


func _terrain_hit(ray: RayCast2D) -> bool:
	if not ray.is_colliding():
		return false
	var col := ray.get_collider()
	return col is TileMapLayer


func _ledge_ahead() -> bool:
	return not _terrain_hit(_floor_ray)


func _turn_around() -> void:
	direction *= -1
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h


func kill() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and body.alive: # player node
		emit_signal("player_died", body)# Replace with function body.
