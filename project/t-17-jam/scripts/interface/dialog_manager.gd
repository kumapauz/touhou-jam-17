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
@export var haggle_manager: Menu
@export var speaker_frame: Control
@export var speaker: TextureRect
@export var dialog_label: Label

@export var confirm_animator: AnimationPlayer
@export var dialog_animator: AnimationPlayer

var is_reading_inputs: bool
var is_dialog_active: bool

func _ready() -> void:
	instance = self

func _process(_delta: float) -> void:
	if !is_dialog_active:
		return
	
	if !is_reading_inputs:
		return
	
	if Input.is_action_just_pressed("confirm"):
		advance_dialog()

func enable_inputs() -> void:
	is_reading_inputs = true

func disable_inputs() -> void:
	is_reading_inputs = false

## Plays an entire dialog sequence. Useful for cutscenes.
func start_dialog_sequence() -> void:
	# TODO pass in a dialog object
	pass

func set_speaker(npc: NpcResource) -> void:
	var expressions: Array[Texture2D] = npc.expressions
	if expressions.size() > 0:
		speaker_frame.visible = true
		speaker.texture = expressions.get(0)
	else:
		speaker_frame.visible = false

func play_random_quote(quotes: PackedStringArray, fallback: String) -> void:
	if quotes.size() > 0:
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
