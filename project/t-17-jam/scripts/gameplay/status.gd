### Manages the game status.
extends Node
class_name StatusManager

static var instance: StatusManager

## Tracks whether customers can come into the store.
var is_open: bool = true

@export var npc_manager: NpcManager

@export_group("Components")
@export var money_label: Label
@export var time_bar: TextureProgressBar

## Amount of money the player has.
var money: int

## Tracks whether time should be running.
var is_day_active: bool

var current_time: float
## How many seconds each business day is.
const DAY_LENGTH: float = 20.0

signal day_started
signal day_finished

func _enter_tree() -> void:
	instance = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		set_day_active(!is_day_active)
		print("Is Day Active set to %s" % is_day_active)
	
	if !is_day_active:
		return
	
	current_time = move_toward(current_time, DAY_LENGTH, delta)
	time_bar.value = current_time / DAY_LENGTH
	if is_equal_approx(current_time, DAY_LENGTH):
		# Day has finished
		set_day_active(false)

func set_day_active(value: bool) -> void:
	is_day_active = value
	if value:
		day_started.emit()
	else:
		day_finished.emit()

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_label.text = "x%08d" % money
