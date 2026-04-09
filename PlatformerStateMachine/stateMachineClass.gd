extends Node
class_name StateMachine

@export var enabled : bool = true
@export var baseState : State

var statesList = {}

@onready var currentState : State = baseState
@onready var parent = get_parent()

func _ready() -> void:
	# On récupère tous les états enfants
	for state in get_children():
		statesList[state.name] = state

func _process(delta: float) -> void:
	if not enabled:
		return
	
	# On change d'état si besoin
	var next = currentState._transitions()
	if next != null:
		currentState._exit(next)
		next._enter(currentState)
		
		currentState = next
