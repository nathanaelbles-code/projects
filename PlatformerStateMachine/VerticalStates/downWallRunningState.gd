extends State


## La vitesse de course maximale
@export var fallSpeed : float
## Le temps mis pour arriver à pleine vitesse
@export var accelerationTime : float

@export var speedCurve : Curve


func _enter(_previous : State) -> void:
	stateMachine.time = 0


func velocity() -> float:
	var progression = speedCurve.sample(stateMachine.time/accelerationTime)
	var speed = remap(progression, 0, 1, 0, fallSpeed)
	return speed


func _transitions() -> State:
	var groundDetectionVector = Vector2(0, stateMachine.collider.extents.y + velocity())
	if stateMachine.collider.test_collision(groundDetectionVector):
		return statesList["Grounded"]

	elif Input.is_action_just_pressed("Jump"):
		return statesList["Jumping"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Grounded":
		stateMachine.collider.adjust2("Bottom")
	
	elif _next.name == "Jumping":
		stateMachine.horizontalMotion.statesList["Running"].airSpeed = max(stateMachine.velocity, 5)
