extends Control
class_name Menu

signal menu_shown
signal menu_hidden

@export var cursor: Control
@export var animator: AnimationPlayer
@export var selection_parent: Control

var _is_reading_inputs: bool
var selection_options: Array[Control]
var selection: int
static var menu_stack: Array[Menu]

var previous_input: int
var selection_timer: float
const SELECTION_SCROLL_INTERVAL: float = 0.15

func _ready() -> void:
	initialize_menu()
	StatusManager.instance.day_finished.connect(Callable(self, "force_close"))

func force_close() -> void:
	if is_active_menu():
		hide_menu()

func initialize_menu() -> void:
	for child in selection_parent.get_children():
		selection_options.append(child)

func _process(delta: float) -> void:
	if !is_active_menu():
		return
	process_menu(delta)

func process_menu(delta: float) -> void:
	process_input(delta)
	if Input.is_action_just_pressed("confirm"):
		select()
	elif Input.is_action_just_pressed("cancel"):
		cancel()

func process_input(delta: float) -> void:
	var input: int = sign(Input.get_axis("up", "down"))
	if previous_input == input:
		selection_timer = move_toward(selection_timer, 0, delta)
		if !is_zero_approx(selection_timer):
			return
	
	previous_input = input
	scroll_selection(input)

func scroll_selection(dir: int) -> void:
	if dir == 0:
		return
	selection_timer = SELECTION_SCROLL_INTERVAL
	selection = posmod(selection + dir, selection_options.size())
	process_cursor_position()
	SoundManager.instance.play_sfx("menu_move")

func select() -> void:
	SoundManager.instance.play_sfx("menu_accept")

func cancel() -> void:
	SoundManager.instance.play_sfx("menu_cancel")
	hide_menu()

func process_cursor_position() -> void:
	cursor.global_position = selection_options.get(selection).global_position

func is_active_menu() -> bool:
	return !menu_stack.is_empty() && menu_stack.back() == self && _is_reading_inputs

func show_menu() -> void:
	if !menu_stack.is_empty() && menu_stack.back() == self:
		return
	
	animator.play("show")
	menu_stack.push_back(self)
	selection = 0
	process_cursor_position()
	SoundManager.instance.play_sfx("menu_accept")
	PlayerController.instance.disable_movement()
	menu_shown.emit()

func hide_menu() -> void:
	if is_active_menu():
		print("Menu %s hidden" % name)
		_is_reading_inputs = false
		while !menu_stack.is_empty() && menu_stack.back() == self:
			# Softlock fix
			menu_stack.pop_back()
		if menu_stack.is_empty():
			PlayerController.instance.enable_movement()
		else:
			menu_stack.back().on_menu_focused()
	animator.play("hide")
	menu_hidden.emit()

## Call from the animator.
func on_menu_shown() -> void:
	_is_reading_inputs = true
	print("Menu %s shown" % name)

## Call from the animator.
func on_menu_hidden() -> void:
	pass

## Called after a menu is popped. 
func on_menu_focused() -> void:
	process_cursor_position()
