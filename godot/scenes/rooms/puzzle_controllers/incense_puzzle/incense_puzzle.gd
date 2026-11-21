extends Node

signal just_solved

@export var target: Array[String] = []

@onready var incenses = get_tree().get_nodes_in_group("scent_puzzle")
@onready var validity_check_timer: Timer = %ValidityCheckTimer

var current_scents: Array[String] = []
var solved: bool = false : set = set_solved


func _ready() -> void:
	validity_check_timer.timeout.connect(_on_validity_check_timer_timeout)
	connect_element_signals()

func connect_element_signals() -> void:
	for i: Incense in incenses:
		i.tree_exited.connect(_on_incense_tree_exited.bind(i))
		i.started_burning.connect(_on_incense_started_burning)
		i.stopped_burning.connect(_on_incense_stopped_burning)


# INPUT RESULTS ----------------------------------------------------------------
## Checks the current array against the target array
func current_is_valid() -> bool:
	target.sort()
	current_scents.sort()
	return target == current_scents

func correct() -> void:
	print("Correct solution: ", name)

func validate() -> void:
	if current_is_valid():
		correct()
		solved = true


# SIGNALS ----------------------------------------------------------------------
func _on_incense_started_burning(scent: String) -> void:
	if current_scents.size() == 0:
		validity_check_timer.start() # start timer on first burnwWw
	current_scents.append(scent)
	print("Added scent: ", scent)
	print("Current scents: ", current_scents)

func _on_incense_stopped_burning(scent: String) -> void:
	current_scents.erase(scent)
	print("Removed scent: ", scent)
	print("Current scents: ", current_scents)

func _on_incense_tree_exited(i: Incense) -> void:
	incenses.erase(i)
	current_scents.erase(i.scent)

func _on_validity_check_timer_timeout() -> void:
	validate()


# SETTERS ----------------------------------------------------------------------
func set_solved(state: bool) -> void:
	if state == true && not solved:
		just_solved.emit() # Emit signal when first solved
		GameManager.player.hallucinate() # FIXME: Hacky solution
	solved = state
