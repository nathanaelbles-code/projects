extends State


signal landOnWall
signal leavingWall


## Plus c'est haut plus le temps pour ralentir croit vite
@export var deccelerationTimeFactor : float
@export var speedCurve : Curve


var deccelerationTime : float
var startSpeed : float
var direction : int
var jumpingStraight : bool = false


@onready var player = $"../.."
@onready var hitBox = $"../../Collider".extents


func _enter(_previous : State) -> void:	
	if Input.is_action_pressed("Left"):
		direction = -1
	elif Input.is_action_pressed("Right"):
		direction = 1
	
	
	deccelerationTime = exp(startSpeed * deccelerationTimeFactor)
	
	landOnWall.emit()

	stateMachine.time = 0


func velocity() -> float:
	var progression = speedCurve.sample(stateMachine.time/deccelerationTime)
	var speed = remap(progression, 0, 1, 0, startSpeed)
	return -speed


func _transitions() -> State:
	var wallDetectionVector =  Vector2((hitBox.x + 1) * direction, 0);
	
	if Input.is_action_just_pressed("Jump"):
		return statesList["Jumping"]

	elif not stateMachine.collider.test_collision(wallDetectionVector):
		if Input.is_action_pressed("Right") and direction == 1:
			return statesList["Grounded"]
		elif Input.is_action_pressed("Left") and direction == -1:
			return statesList["Grounded"]
		else:
			jumpingStraight = true
			return statesList["Jumping"]

	elif Input.is_action_just_pressed("Down"):
		return statesList["UpWallBraking"]

	elif abs(velocity()) < 0.1:
		return statesList["WallStance"]
	elif stateMachine.collider.test_collision(Vector2(0, velocity())):
		return statesList["WallStance"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Jumping":
		leavingWall.emit()
		if jumpingStraight:
			jumpingStraight = false
			stateMachine.horizontalMotion.statesList["OnWall"].wallJumpSpeed = 0
		else:
			stateMachine.horizontalMotion.statesList["OnWall"].wallJumpSpeed = max(abs(velocity()), 5) 

	elif _next.name == "Grounded":
		leavingWall.emit()
		stateMachine.horizontalMotion.statesList["OnWall"].runningSpeed = stateMachine.velocity
