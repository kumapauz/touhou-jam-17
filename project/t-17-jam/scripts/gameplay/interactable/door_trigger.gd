extends InteractableObject

func interact() -> void:
	StatusManager.instance.open_store()
	SoundManager.instance.play_sfx("shop_opened")

func is_selectable() -> bool:
	return StatusManager.instance.game_state == StatusManager.GAME_STATE.DAY_STARTED
