extends Node
class_name State

@onready var stateMachine = get_parent()
@onready var statesList = stateMachine.statesList

func _enter(_previous : State) -> void:
	pass

func _transitions() -> State:
	return null

func _exit(_next : State) -> void:
	pass
