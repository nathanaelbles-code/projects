extends RayCast2D


signal collideLeft
signal collideRight
signal collideTop
signal collideBottom


@export var printCollisions : bool
@export var extents : Vector2

var collisions = {}
var entityPos : Vector2


@onready var entity = get_parent()
@onready var horizontalMotion : DynamicCharacter = $"../HorizontalMotion"
@onready var verticalMotion : DynamicCharacter = $"../VerticalMotion"


func _ready() -> void:
	collisions["Right"] = Vector2.ZERO
	collisions["Left"] = Vector2.ZERO
	collisions["Top"] = Vector2.ZERO
	collisions["Bottom"] = Vector2.ZERO


func _process(delta: float) -> void:
	if printCollisions:
		print("Right : ", collisions["Right"])
		print("Left : ", collisions["Left"])
		print("Top : ", collisions["Top"])
		print("Bottom : ", collisions["Bottom"])
		print("////////////////")


func precise_raycast(from: Vector2, to: Vector2, collision_mask: int = 1, exclude: Array = []) -> Dictionary:

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = collision_mask
	query.exclude = exclude
	query.hit_from_inside = true

	var result = space_state.intersect_ray(query)
	
	return result


# Envoie deux rayons sur les extrémités avec
# un vecteur horizontal ou vertical donnant la longueur.
# Renvoie la position de contact.
# Ne marche qu'avec des vecteurs horizontaux ou verticaux.
func rays(_direction : Vector2) -> Vector2:
	var sideOffset = Vector2.ZERO
	if _direction.x != 0:
		sideOffset.y = extents.y
		sideOffset.x = 0
	else:
		sideOffset.x = extents.x
		sideOffset.y = 0

	sideOffset *= 0.9
	
	var pushOutside = _direction.normalized() * extents * 1

	var offset1 = sideOffset + pushOutside
	var offset2 = -sideOffset + pushOutside

	if _direction.x < 0:
		$Debug1.global_position = entityPos + offset2
		$Debug2.global_position = entityPos + offset2 + _direction


	var hit = precise_raycast(entityPos + offset1, entityPos + _direction + offset1, 1, [self])
	if hit:
		return hit.position
	
	hit = precise_raycast(entityPos + offset2, entityPos + _direction + offset2, 1, [self])
	if hit:
		return hit.position


	return Vector2.ZERO


func adjust2(_direction : String) -> void:
	var wallPos = collisions[_direction]

	# Il est important d'utiliser entity ici (ou d'accéder au joueur avec get_parent()) sinon sa fout la merde
	if _direction == "Left" or _direction == "Right":
		if wallPos.x  > entity.position.x:
			entity.position.x = wallPos.x - extents.x
		else:
			entity.position.x = wallPos.x + extents.x

	elif _direction == "Top" or _direction == "Bottom":
		if wallPos.y > entity.position.y:
			entity.position.y = wallPos.y - extents.y
		else:
			entity.position.y = wallPos.y + extents.y
	
	entityPos = entity.position


func test_collision(_ray : Vector2) -> bool:
	var wallPos = rays(_ray * horizontalMotion.deltaTime * 100)

	if wallPos == Vector2.ZERO:
		return false

	if _ray.x > 0:
		collisions["Right"] = wallPos
	elif _ray.x < 0:
		collisions["Left"] = wallPos
	elif _ray.y > 0:
		collisions["Bottom"] = wallPos
	elif _ray.y < 0:
		collisions["Top"] = wallPos

	return true
