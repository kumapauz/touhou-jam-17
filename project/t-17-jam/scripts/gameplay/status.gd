### Manages the game status.
extends Node

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
const DAY_LENGTH: float = 10.0

func _process(delta: float) -> void:
	if !is_day_active:
		return
	
	current_time = move_toward(current_time, DAY_LENGTH, delta)
	time_bar.value = current_time / DAY_LENGTH

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_label.text = "x%08d" % money
