extends State

## Plus c'est haut plus on tombe vite
@export var fallFactor : float
## La vitesse de chute maximale
@export var fallSpeed : float
## Plus c'est bas, moins la vitesse de course rend la chute flottante
@export var speedInfluence : float
## Le temps du buffer de saut avant d'atterrir
@export var jumpBuffer : float
## Le temps du buffer pour courrir sur le mur
@export var wallRunBuffer : float
## Accélération de la chute quand on plonge
@export var diveSpeedFactor : float

var startSpeed : float
@onready var jumpBufferTimer : Timer = $Timer
@onready var coyoteTimer : Timer = $Timer2
@onready var wallRunBufferTimer : Timer = $Timer3


func _enter(_previous : State) -> void:
	if _previous.name == "Jumping":
		startSpeed = _previous.horizontalStartSpeed
		wallRunBufferTimer.start(wallRunBuffer)
	else:
		startSpeed = abs(stateMachine.horizontalMotion.velocity)

	stateMachine.time = 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		jumpBufferTimer.start(jumpBuffer)


func velocity() -> float:
	return time_to_speed(stateMachine.time)


func time_to_speed(_time : float) -> float:
	var factor = fallFactor
	
	if (Input.is_action_pressed("Down")):
		factor = diveSpeedFactor
	
	var a = factor * fall_factor_scaling(startSpeed * speedInfluence)
	var expFactor = -a * _time
	
	return fallSpeed * sqrt(1 - exp(expFactor))


func fall_factor_scaling(_speed : float) -> float:
	return sqrt(exp(-_speed))


func _transitions() -> State:
	var collisionDetectionVector = Vector2(0, velocity())

	if stateMachine.collider.test_collision(collisionDetectionVector):
		return statesList["Grounded"]

	elif Input.is_action_just_pressed("Jump") and not coyoteTimer.is_stopped():
		return statesList["Jumping"]

	# On laisse une petite marge au début de la chute pour wallrun
	elif not wallRunBufferTimer.is_stopped() and stateMachine.horizontalMotion.velocity != 0:
		if Input.is_action_pressed("Left") and stateMachine.collider.test_collision(Vector2(-1 - stateMachine.collider.extents.x, 0)):
			return statesList["UpWallRunning"]
		elif Input.is_action_pressed("Right") and stateMachine.collider.test_collision(Vector2(1 + stateMachine.collider.extents.x, 0)):
			return statesList["UpWallRunning"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Grounded":
		stateMachine.collider.adjust2("Bottom")
	
	if _next.name == "UpWallRunning":
		_next.startSpeed = abs(stateMachine.horizontalMotion.velocity)
