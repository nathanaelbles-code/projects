extends DynamicCharacter

## Active ou pas les mouvements verticaux
var deltaTime : float
@onready var horizontalMotion : DynamicCharacter = $"../HorizontalMotion"


func physics_process(delta: float) -> void:
	if not enabled:
		return

	deltaTime = delta
	_velocity_update(delta)
	updatePosition.call_deferred()

func updatePosition() -> void:
	entity.position.y += velocity * deltaTime * 100
