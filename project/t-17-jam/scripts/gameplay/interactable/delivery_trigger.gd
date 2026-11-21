## Trigger for deliveries.
extends InteractableObject

func interact() -> void:
	DeliveryManager.instance.show_menu()
