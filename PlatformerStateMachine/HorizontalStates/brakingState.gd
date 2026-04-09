extends State


## La proportion du temps pour ralentir que l'on aurait mit en glissant que l'on garde.
@export_range (0, 1) var timeDeccelerationFactor : float


var startSpeed : float
var direction : int
var deccelerationTime : float


func _enter(_previous : State) -> void:
	var startVelocity = _previous.velocity()

	startSpeed = abs(startVelocity)
	direction = sign(startVelocity)

	deccelerationTime = (exp(startSpeed*_previous.deccelerationTimeFactor) - 1)*timeDeccelerationFactor

	stateMachine.time = 0


func velocity() -> float:
	var speed = max(startSpeed * (1 - stateMachine.time/deccelerationTime), 0)
	return speed * direction


func _transitions() -> State:
	var collisionsTestVector = Vector2(velocity(), 0)
	
	if Input.is_action_just_released("Left") and direction == -1:
		return statesList["Sliding"]
	elif Input.is_action_just_released("Right") and direction == 1:
		return statesList["Sliding"]
	elif Input.is_action_just_pressed("Surf"):
		statesList["Sliding"].preSurf = true
		return statesList["Sliding"]

	elif abs(velocity()) < 0.1:
		return statesList["Idle"]
	elif stateMachine.collider.test_collision(collisionsTestVector):
		return statesList["Idle"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Running":
		_next.startSpeed = 0

	elif _next.name == "Idle" and abs(velocity()) > 0.1:
		if direction == 1:
			stateMachine.collider.adjust2("Right")
		else:
			stateMachine.collider.adjust2("Left")
