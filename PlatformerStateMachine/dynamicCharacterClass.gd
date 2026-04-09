extends StateMachine
class_name DynamicCharacter

@export var printVelocity : bool
@export var printTime : bool
@export var printState : bool

var time : float = 0
var velocity : float = 0

@onready var collider : RayCast2D = $"../Collider"
@onready var entity : Node2D = $".."


func _velocity_update(_delta : float) -> void:
	if printState:
		print(name, "| State : ", currentState.name)
	if printVelocity:
		print(name, "| Velocity : ", velocity)
	if printTime:
		print(name, "| Time : ", time)

	velocity = currentState.velocity()
	time += 1
