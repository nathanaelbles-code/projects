extends DynamicCharacter

## Active ou pas les mouvements horizontaux
var deltaTime : float
var isGrounded : bool

@onready var verticalMotion : DynamicCharacter = $"../VerticalMotion"



func physics_process(delta: float) -> void:
	if not enabled:
		return

	if verticalMotion.enabled:
		isGrounded = verticalMotion.currentState.name == "Grounded"
	else:
		isGrounded = true

	deltaTime = delta
	_velocity_update(delta)
	updatePosition.call_deferred()

func updatePosition() -> void:
	entity.position.x += velocity * deltaTime * 100
