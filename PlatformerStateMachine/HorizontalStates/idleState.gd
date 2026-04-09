extends State


func velocity() -> float:
	return 0


func _transitions() -> State:
	if Input.is_action_pressed("Left") and not stateMachine.collider.test_collision(Vector2(-5, 0)):
		return statesList["Running"]
	elif Input.is_action_pressed("Right") and not stateMachine.collider.test_collision(Vector2(5, 0)):
		return statesList["Running"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Running":
		_next.startSpeed = 0
