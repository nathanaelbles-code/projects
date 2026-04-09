extends State


## Plus c'est haut plus le temps pour ralentir croit vite
@export var deccelerationTimeFactor : float
@export var speedCurve : Curve


var startSpeed : float
var direction : int
var timeSurfPressed : int
var deccelerationTime : float


@onready var previousIsSurf : bool = false
@onready var preSurf : bool = false


func _enter(_previous : State) -> void:
	var startVelocity = _previous.velocity()

	startSpeed = abs(startVelocity)
	direction = sign(startVelocity)
	
	deccelerationTime = exp(startSpeed * deccelerationTimeFactor)
	
	
	if _previous.name == "Surfing":
		previousIsSurf = true

	# Si on a lancé le surf déjà au sol on a pas de boost
	if stateMachine.isGrounded:
		timeSurfPressed = -1000
	else:
		timeSurfPressed = stateMachine.time


	stateMachine.time = 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Surf") and not previousIsSurf:
		previousIsSurf = false
		preSurf = true
		if stateMachine.isGrounded:
			timeSurfPressed = -1000
		else:
			timeSurfPressed = stateMachine.time


func velocity() -> float:
	var progression = speedCurve.sample(stateMachine.time/deccelerationTime)
	var speed = remap(progression, 0, 1, 0, startSpeed)
	return speed * direction


func _transitions() -> State:

	if not preSurf:
		var collisionsTestVector = Vector2(velocity(), 0)
		
		# On a plus de vitesse ou on se prend un mur
		if abs(velocity()) < 0.1:
			return statesList["Idle"]
		elif stateMachine.collider.test_collision(collisionsTestVector):
			return statesList["Idle"]

		
		# Si on appuie sur des directions pendant le glissage
		var overSpeeding = statesList["Running"].overSpeeding
		if Input.is_action_pressed("Left"):
			if direction == -1:
				if not overSpeeding:
		# Si on repart dans la même direction et que la vitesse est assez petite
					return statesList["Running"]
			else:
		# On va dans l'autre sens pour freiner
				return statesList["Braking"]
		elif Input.is_action_pressed("Right"):
			if direction == 1:
				if not overSpeeding:
		# Si on repart dans la même direction et que la vitesse est assez petite
					return statesList["Running"]
			else:
		# On va dans l'autre sens pour freiner
				return statesList["Braking"]

	# Si on a activé le surf en l'air
	elif preSurf and stateMachine.isGrounded:
		return statesList["Surfing"]



	return null


func _exit(_next : State) -> void:
	if _next.name == "Surfing":
		preSurf = false
		_next.timeBeforeLanding = stateMachine.time - timeSurfPressed

	elif _next.name == "Running":
		_next.startSpeed = velocity()

	elif _next.name == "Idle" and abs(velocity()) > 0.1:
		if direction == 1:
			stateMachine.collider.adjust2("Right")
		else:
			stateMachine.collider.adjust2("Left")
