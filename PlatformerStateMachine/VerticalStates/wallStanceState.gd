extends State


signal jumpingWallStance


func velocity() -> float:
	return 0


func _transitions() -> State:
	if Input.is_action_just_pressed("Down"):
		return statesList["DownWallRunning"]

	elif Input.is_action_just_pressed("Jump"):
		return statesList["Jumping"]

	return null


func _exit(_next : State) -> void:
	if _next.name == "Jumping":
		jumpingWallStance.emit()
