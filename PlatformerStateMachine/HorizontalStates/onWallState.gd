extends State


var runningSpeed : float
var wallJumpSpeed : float
var leavingWall : bool = false
var leavingWallStance : bool = false


func velocity() -> float:
	return 0


func _transitions() -> State:
	if leavingWall or leavingWallStance:
		return stateMachine.statesList["Running"]

	elif stateMachine.isGrounded:
		return stateMachine.statesList["Running"]

	return null
	

func _exit(_next : State) -> void:
	if leavingWall:
		leavingWall = false
		if stateMachine.isGrounded:
			_next.startSpeed = abs(runningSpeed)

			# Pour orienter la course dans la bonne direction
			if Input.is_action_pressed("Left"):
				_next.direction = -1
			else:
				_next.direction = 1
		else:
			_next.airSpeed = wallJumpSpeed

			# Pour orienter le saut mural dans la bonne direction
			var collider = stateMachine.collider
			if collider.test_collision(Vector2(-50, 0)):
				_next.direction = 1
			else:
				_next.direction = -1
				
	elif leavingWallStance:
		leavingWallStance = false
		
		_next.airSpeed = statesList["Running"].maxRunningSpeed
		var collider = stateMachine.collider
		if collider.test_collision(Vector2(-50, 0)):
			_next.direction = 1
		else:
			_next.direction = -1


func _on_up_wall_running_leaving_wall() -> void:
	leavingWall = true


func _on_wall_stance_jumping_wall_stance() -> void:
	leavingWallStance = true
