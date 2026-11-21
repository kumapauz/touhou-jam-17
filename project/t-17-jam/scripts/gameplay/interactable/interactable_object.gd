extends Area3D
class_name InteractableObject

@export var select_root: Node3D

func select() -> void:
	select_root.visible = true

func deselect() -> void:
	select_root.visible = false

func is_selectable() -> bool:
	return true

func is_selected() -> bool:
	return select_root.visible

func interact() -> void:
	print("Interaction is not implemented.")
