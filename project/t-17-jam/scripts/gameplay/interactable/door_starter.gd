extends InteractableObject

func interact() -> void:
	StatusManager.instance.open_store()

func is_selectable() -> bool:
	return StatusManager.instance.game_state == StatusManager.GAME_STATE.DAY_STARTED
