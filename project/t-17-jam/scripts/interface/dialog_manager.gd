extends Node
class_name DialogManager

static var instance: DialogManager

signal dialog_started
signal dialog_finished
signal sale_confirmed

enum DIALOG_MODE {
	DIALOG, #
	SELL # A shopper is buying an item.
}

@export_group("Components")
@export var item: TextureRect
@export var speaker_frame: Control
@export var speaker: TextureRect
@export var dialog_label: Label

@export var confirm_animator: AnimationPlayer
@export var dialog_animator: AnimationPlayer

var is_dialog_active: bool
var _current_haggle_target: NpcController

func _ready() -> void:
	instance = self

func _process(_delta: float) -> void:
	if !is_dialog_active:
		return
	
	if Input.is_action_just_pressed("confirm"):
		if is_haggling():
			finish_sale()
		else:
			advance_dialog()

func is_haggling() -> bool:
	return is_instance_valid(_current_haggle_target)

## Plays an entire dialog sequence. Useful for cutscenes.
func start_dialog_sequence() -> void:
	# TODO pass in a dialog object
	pass

func start_sale(npc: NpcController) -> void:
	_current_haggle_target = npc
	var expressions: Array[Texture2D] = npc.npc.expressions
	if is_instance_valid(expressions) && expressions.size() > 0:
		speaker_frame.visible = true
		speaker.texture = expressions.get(0)
	else:
		speaker_frame.visible = false
	
	item.visible = true
	item.texture = _current_haggle_target._target_holder.item.ui_texture
	play_random_quote(_current_haggle_target.npc.inquiry_quotes, "Buying this!")

func finish_sale() -> void:
	StatusManager.instance.add_money(_current_haggle_target._target_holder.item.price)
	play_random_quote(_current_haggle_target.npc.purchase_quotes, "Thanks!")
	_current_haggle_target.purchase_item()
	_current_haggle_target = null
	item.visible = false

func play_random_quote(quotes: PackedStringArray, fallback: String) -> void:
	if is_instance_valid(quotes) && quotes.size() > 0:
		play_dialog(quotes.get(randi_range(0, quotes.size() - 1)))
	else:
		play_dialog(fallback)

func play_dialog(dialog: String) -> void:
	is_dialog_active = true
	dialog_label.text = dialog
	dialog_animator.play("show")

func advance_dialog() -> void:
	is_dialog_active = false
	dialog_animator.play("hide")
