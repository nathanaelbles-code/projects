extends State


## Vitesse de course maximale
@export var maxRunningSpeed : float
## Le temps pour atteindre la vitess de course maximale
@export var accelerationMaxTime : float


@export var speedCurve : Curve

var accelerationTime : float
var direction : int
var airSpeed : float
var overSpeeding : bool
var startSpeed : float
var landOnWall : bool = false


func _enter(_previous : State) -> void:	
	if not _previous.name == "OnWall":
		airSpeed = abs(_previous.velocity())


	startSpeed = abs(startSpeed)
	if startSpeed > maxRunningSpeed:
		overSpeeding = true
	else:
		if startSpeed == 0:
			accelerationTime = accelerationMaxTime
		else:
			# Calcul du temps pour arriver à la vitesse max depuis une vitesse intermédiaire
			var adjusted = abs(startSpeed/maxRunningSpeed)
			accelerationTime = accelerationMaxTime * (1 - dichotomia(adjusted))

	if not _previous.name == "OnWall":
		if Input.is_action_pressed("Left"):
			direction = -1
		else:
			direction = 1

	stateMachine.time = 0


func velocity() -> float:
	var speed = 0

	if not stateMachine.isGrounded:
		speed = airSpeed
	else:
		if stateMachine.time > accelerationTime:
			speed = maxRunningSpeed
		else:
			var progression = speedCurve.sample(stateMachine.time/accelerationTime)			
			speed = remap(progression, 0, 1, startSpeed, maxRunningSpeed)

	return speed * direction


func dichotomia(_value : float) -> float:
	var right = 1.0
	var left = 0.0
	var mid = 0.5
	var current = speedCurve.sample(mid)
	
	while abs(current - _value) > 0.01:
		
		if current < _value:
			left = mid
		else:
			right = mid
		
		mid = (left + right) / 2.0
		current = speedCurve.sample(mid)
	
	return mid


func _transitions() -> State:
	var collisionsTestVector = Vector2(velocity(), 0)

	# On appuie sur la direction opposée
	if direction == -1 and not Input.is_action_pressed("Left"):
		return statesList["Sliding"]
	elif direction == 1 and not Input.is_action_pressed("Right"):
		return statesList["Sliding"]

	# On va trop vite pour courrir
	elif overSpeeding and stateMachine.isGrounded:
		return statesList["Sliding"]
		
	# On veut surfer
	elif Input.is_action_just_pressed("Surf"):
		statesList["Sliding"].preSurf = true
		return statesList["Sliding"]

	# On se prend un mur
	elif stateMachine.collider.test_collision(collisionsTestVector):
		if landOnWall:
			landOnWall = false
			return statesList["OnWall"]
		else:
			return statesList["Idle"]

	#elif landOnWall:
		#landOnWall = false
		#return statesList["OnWall"]

	return null


func _exit(_next : State) -> void:
	overSpeeding = false
	if _next.name == "Idle" or _next.name == "OnWall":
		if direction == 1:
			stateMachine.collider.adjust2("Right")
		else:
			stateMachine.collider.adjust2("Left")		


func _on_grounded_leaving_ground() -> void:
	airSpeed = velocity() * direction


func _on_grounded_landing_on_ground() -> void:
	overSpeeding = abs(stateMachine.velocity) > maxRunningSpeed


func _on_up_wall_running_land_on_wall() -> void:
	landOnWall = true
