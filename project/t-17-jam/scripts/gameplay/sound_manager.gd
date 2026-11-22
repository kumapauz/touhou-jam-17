extends Node
class_name SoundManager

static var instance: SoundManager

func _enter_tree() -> void:
	instance = self

func play_sfx(sfx: String) -> void:
	var node: AudioStreamPlayer = get_node_or_null(sfx.to_pascal_case())
	if is_instance_valid(node):
		node.play()
