extends Node

@export_file("*.tscn") var intro_scene: String
@export var animator: AnimationPlayer

var is_reading_inputs: bool

func _process(_delta: float) -> void:
	if !is_reading_inputs:
		return
	if Input.is_action_just_pressed("confirm"):
		disable_inputs()
		SoundManager.instance.play_sfx("menu_accept")
		animator.play("start")

func enable_inputs() -> void:
	is_reading_inputs = true

func disable_inputs() -> void:
	is_reading_inputs = false

func load_scene() -> void:
	get_tree().change_scene_to_file(intro_scene)
