## Trigger for deliveries.
extends InteractableObject

func interact() -> void:
	DeskManager.instance.show_menu()
