extends Node

## Scene to go load when pressing confirm.
@export_file_path("*.tscn") var target_scene: String
@export var animator: AnimationPlayer
var is_reading_inputs: bool = true

func _process(_delta: float) -> void:
	if !is_reading_inputs:
		return
	
	if Input.is_action_just_pressed("confirm"):
		disable_inputs()
		animator.play("fade")

func enable_inputs() -> void:
	is_reading_inputs = true

func disable_inputs() -> void:
	is_reading_inputs = false

func load_scene() -> void:
	get_tree().change_scene_to_file(target_scene)
