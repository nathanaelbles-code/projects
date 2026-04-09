extends State


## La proportion du temps pour ralentir que l'on aurait mit en glissant que l'on garde.
@export_range (0, 1) var timeDeccelerationFactor : float

var startSpeed : float
var direction : int
var slidingDerivative : float
var deccelerationTime : float


func _enter(_previous : State) -> void:
	startSpeed = abs(_previous.velocity())
	
	deccelerationTime = (exp(startSpeed*_previous.deccelerationTimeFactor) - 1)*timeDeccelerationFactor
	
	direction = _previous.direction

	stateMachine.time = 0


func velocity() -> float:
	var speed = max(startSpeed * (1 - stateMachine.time/deccelerationTime), 0)
	return -speed


func _transitions() -> State:
	var collider = stateMachine.collider
	var roofDetectionVector = Vector2(0, -collider.extents.y - abs(velocity()))
	var wallDetectionVector = Vector2((collider.extents.x + 1) * direction, 0)
	
	if Input.is_action_just_released("Down"):
		return statesList["UpWallRunning"]

	elif not collider.test_collision(wallDetectionVector):
		return statesList["Jumping"]
	#elif direction == -1 and not stateMachine.collider.test_collision(Vector2(-stateMachine.collider.extents.x - 1, 0)):
		#return statesList["Jumping"]
	#elif direction == 1 and not stateMachine.collider.test_collision(Vector2(-stateMachine.collider.extents.x - 1, 0)):
		#return statesList["Jumping"]

	elif abs(velocity()) < 0.1:
		return statesList["WallStance"]
	elif collider.test_collision(roofDetectionVector):
		return statesList["WallStance"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "WallStance" and abs(velocity()) > 0.1:
		stateMachine.collider.adjust2("Top")
