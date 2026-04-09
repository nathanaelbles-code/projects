extends State

@export var maxBoost : float

var speed : float
var direction : int
var timeBeforeLanding : float
var speedBoost : float
var maxTime : float = 0


func _enter(_previous : State) -> void:
	speed = abs(stateMachine.velocity)
	direction = sign(stateMachine.velocity)
	speedBoost = boost_function(timeBeforeLanding)


func velocity() -> float:
	return speed * direction * speedBoost


func boost_function(_time : float) -> float:
	var timeFactor = -log(0.0001)/maxTime
	return (maxBoost - 1) * sqrt(exp(-timeFactor * _time)) + 1


func _transitions() -> State:
	var collisionsTestVector = Vector2(velocity(), 0)
	
	
	if Input.is_action_just_pressed("Surf"):
		return statesList["Sliding"]

	elif stateMachine.collider.test_collision(collisionsTestVector):
		return statesList["Idle"]


	return null


func _exit(_next : State) -> void:
	if _next.name == "Idle":
		if direction == 1:
			stateMachine.collider.adjust2("Right")
		else:
			stateMachine.collider.adjust2("Left")
