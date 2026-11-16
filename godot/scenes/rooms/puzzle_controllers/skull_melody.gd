extends Node

signal just_solved

@export var target_sequence: Array[NoteData] = []

@onready var skulls = get_tree().get_nodes_in_group("melody_member")
@onready var reset_interval: Timer = %ResetInterval

var reset_interval_timer: SceneTreeTimer = null
var input_sequence: Array[NoteData] = []
var solved: bool = false : set = set_solved


func _ready() -> void:
	connect_to_skull_signals()
	reset_interval.timeout.connect(_on_reset_interval_timeout)

func connect_to_skull_signals() -> void:
	for s: SkullItem in skulls:
		s.note_just_played.connect(_on_skull_note_just_played)


# TIMER ------------------------------------------------------------------------
func refresh_reset_interval() -> void:
	reset_interval.start()


# INPUT RESULTS ----------------------------------------------------------------
func input_is_valid() -> bool:
	var valid: bool = true
	for i in target_sequence.size():
		if not target_sequence[i].equals(input_sequence[i]):
			valid = false
	return valid

func correct_sequence() -> void:
	reset_interval.stop()
	input_sequence.clear()
	print("Correct melody sequence")

func incorrect_sequence() -> void:
	input_sequence.clear()
	print("Incorrect melody sequence")


# SIGNALS ----------------------------------------------------------------------
func _on_skull_note_just_played(note_data: NoteData) -> void:
	refresh_reset_interval()
	input_sequence.append(note_data)
	print("Input melody: ", input_sequence)
	if input_sequence.size() >= target_sequence.size():
		var valid = input_is_valid()
		if valid:
			correct_sequence()
			solved = true
		else:
			incorrect_sequence()

func _on_reset_interval_timeout() -> void:
	incorrect_sequence()


# SETTERS ----------------------------------------------------------------------
func set_solved(state: bool) -> void:
	if state == true && not solved:
		just_solved.emit() # Emit signal when first solved
	solved = state
