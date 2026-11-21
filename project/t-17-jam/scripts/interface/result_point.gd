extends Control

@export var day: Label
@export var bar: ColorRect

func show_bar(ratio: float, date: int, delay: float) -> void:
	day.text = str(date)
	bar.offset_transform_scale = Vector2.RIGHT
	if is_zero_approx(ratio):
		return
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(bar, "offset_transform_scale", Vector2(1, ratio), 0.2).set_delay(delay)
