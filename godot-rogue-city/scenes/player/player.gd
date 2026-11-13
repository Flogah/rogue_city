extends CharacterBody3D
class_name Player

@export var speed: float = 5.0
@export var rotation_speed: float = 10.0

@export var roll_duration: float = 0.6

@onready var camera_arm: Node3D = %Camera_Arm
@onready var mesh: Node3D = %Mesh

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
