### Manages the game status.
extends Node
class_name StatusManager

static var instance: StatusManager

## Tracks whether customers can come into the store.
var is_open: bool = true

@export_file("*.tscn") var good_ending_path: String
@export_file("*.tscn") var bad_ending_path: String

@export_group("Components")
@export var money_label: Label
@export var day_label: Label
@export var time_bar: TextureProgressBar
@export var day_animator: AnimationPlayer
@export var result_animator: AnimationPlayer
@export var result_point_parent: Node
@export var goal_rect: Control
var _result_points: Array[Control]

## Amount of money the player has.
var money: int = 500
## History of money at the end of each day.
var money_history: PackedInt64Array
const TARGET_MONEY: int = 10000
## How many days the game should last.
const NUMBER_OF_DAYS: int = 7

var game_state: GAME_STATE = GAME_STATE.INIT
enum GAME_STATE {
	INIT,
	DAY_STARTED, # Player is organizing before opening the store
	STORE_OPEN, # Shoppers are coming in
	STORE_CLOSED, # Waiting for shoppers to leave
	DAY_FINISHED, # Day is officially over
	RESULTS_FINISHED # Results have been reviewed
}

var current_time: float
## How many seconds each business day is.
const DAY_LENGTH: float = 30.0
const MAX_MONEY_AMOUNT: int = 99999

signal store_opened
signal store_closed

signal day_reset
signal day_started
signal day_finished

func _enter_tree() -> void:
	instance = self
	init_result_points()
	add_money(0)
	start_day()

func init_result_points() -> void:
	for point in result_point_parent.get_children():
		_result_points.append(point)

func _process(delta: float) -> void:
	if game_state == GAME_STATE.DAY_FINISHED && Input.is_action_just_pressed("confirm"):
		reset_day()
	
	if !PlayerController.instance.is_input_enabled():
		return
	
	if game_state != GAME_STATE.STORE_OPEN:
		return
	
	current_time = move_toward(current_time, DAY_LENGTH, delta)
	time_bar.value = current_time / DAY_LENGTH
	if is_time_finished():
		# Store has closed
		game_state = GAME_STATE.STORE_CLOSED
		store_closed.emit()

func open_store() -> void:
	game_state = GAME_STATE.STORE_OPEN
	store_opened.emit()

func add_money(amount: int) -> void:
	money = clamp(0, money + amount, MAX_MONEY_AMOUNT)
	money_label.text = "x%05d" % money

func reset_day() -> void:
	if money_history.size() >= NUMBER_OF_DAYS:
		if money >= TARGET_MONEY:
			get_tree().change_scene_to_file(good_ending_path)
		else:
			get_tree().change_scene_to_file(bad_ending_path)
		return

	current_time = 0
	time_bar.value = 0
	day_reset.emit()
	day_animator.play("reset")
	result_animator.play("reset")
	game_state = GAME_STATE.RESULTS_FINISHED

func is_time_finished() -> bool:
	return is_equal_approx(current_time, DAY_LENGTH)

func start_day() -> void:
	day_label.text = "Day %s" % (money_history.size() + 1)
	day_animator.play("start")

func on_day_started() -> void:
	game_state = GAME_STATE.DAY_STARTED
	day_started.emit()

func finish_day() -> void:
	SoundManager.instance.play_sfx("day_cleared")
	game_state = GAME_STATE.DAY_FINISHED
	day_finished.emit()
	
	money_history.append(money)
	day_animator.play("finished")
	# Redraw bars
	result_animator.play("finished")
	var max_range: float = TARGET_MONEY
	for i in money_history:
		if i > max_range:
			max_range = i
	
	goal_rect.offset_transform_position_ratio = Vector2.UP * (TARGET_MONEY / max_range)
	
	for i in range(_result_points.size()):
		var ratio: float = 0.0
		if i < money_history.size():
			ratio = money_history.get(i) / max_range
		_result_points.get(i).show_bar(ratio, i + 1, 0.1 * i)
