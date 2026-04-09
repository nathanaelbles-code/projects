extends State


signal leavingGround
signal landingOnGround

## Le temps laissé après une chute pour sauter
@export var coyoteTime : float

@onready var jumpBuffered : bool = false


func _enter(_previous : State) -> void:
	landingOnGround.emit()
	
	if _previous.name == "Falling" and not _previous.jumpBufferTimer.is_stopped():
		jumpBuffered = true
		_previous.jumpBufferTimer.stop()


func velocity() -> float:
	return 0


func _transitions() -> State:
	var collisionDetectionVector = Vector2(0, stateMachine.collider.extents.x + 1)

	if Input.is_action_just_pressed("Jump"):
		return statesList["Jumping"]
	elif jumpBuffered:
		return statesList["Jumping"]

	elif not stateMachine.collider.test_collision(collisionDetectionVector):
		return statesList["Falling"]


	return null


func _exit(_next : State) -> void:
	leavingGround.emit()
	
	if _next.name == "Jumping" and jumpBuffered:
		jumpBuffered = false
	elif _next.name == "Falling":
		_next.coyoteTimer.start(coyoteTime)
