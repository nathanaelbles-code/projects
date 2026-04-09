extends State

## Plus c'est haut plus le saut est serré
@export var jumpFactor : float
## Hauteur du saut
@export var jumpHeight : float
## Plus c'est bas, moins la vitesse de course fait flotter le saut
@export var speedInfluence : float
@export var wallRunningBoostFactor : float
@export var wallRunBoostCurve : Curve


var horizontalStartSpeed : float
var verticalStartSpeed : float
var summit : float



func _enter(_previous : State) -> void:
	horizontalStartSpeed = stateMachine.horizontalMotion.statesList["Running"].airSpeed
	
	# Pour que on saute plus haut si on saute d'un mur en courant
	verticalStartSpeed = 1.0
	if _previous.name == "UpWallRunning":
		verticalStartSpeed = -stateMachine.velocity;

	summit = sqrt(jumpHeight/(jumpFactor * jump_factor_scaling(horizontalStartSpeed * speedInfluence)))
	
	stateMachine.time = 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Surf"):
		var surfingState = stateMachine.horizontalMotion.statesList["Surfing"]
		surfingState.maxTime = summit

func velocity() -> float:
	return -time_to_speed(stateMachine.time)


func time_to_speed(_time : float) -> float:
	var a = jumpFactor * jump_factor_scaling(horizontalStartSpeed * speedInfluence)
	var height = jumpHeight

	if verticalStartSpeed != 1.0:
		height = clamp(height * verticalStartSpeed * wallRunningBoostFactor, jumpHeight, 500)

	return -2 * a * _time + 2 * sqrt(a * height)


func jump_factor_scaling(_speed : float) -> float:
	return sqrt(exp(-_speed))


func _transitions() -> State:
	var collisionDetectionVector = Vector2(0, velocity())
	if stateMachine.collider.test_collision(collisionDetectionVector):
		return statesList["Falling"]
	elif velocity() >= 0:
		return statesList["Falling"]


	elif stateMachine.horizontalMotion.velocity != 0:
		var wallDetectionVectorLenght = 1 + stateMachine.collider.extents.x
		if stateMachine.collider.test_collision(Vector2(wallDetectionVectorLenght, 0)) and Input.is_action_pressed("Right"):
			return statesList["UpWallRunning"]
		elif stateMachine.collider.test_collision(Vector2(-wallDetectionVectorLenght, 0)) and Input.is_action_pressed("Left"):
			return statesList["UpWallRunning"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Falling" and velocity() < 0:
		stateMachine.collider.adjust2("Top")

	if _next.name == "UpWallRunning":

		var boost = wallRunBoostCurve.sample(1 - stateMachine.time/summit)

		var horizontalSpeed = abs(stateMachine.horizontalMotion.velocity)
		_next.startSpeed = horizontalSpeed * boost
