@tool
class_name SkullItem
extends Item

signal note_just_played(note_name)

@export var note_data: NoteData : set = set_note_data
@export var note_audio: AudioStream
@export var light_color: Color = Color.WHITE : set = set_light_color

@onready var impact_sfx: AudioStreamPlayer3D = %ImpactSFX
@onready var note_player: AudioStreamPlayer3D = %NotePlayer
@onready var eye_light: FlickerLight3D = %EyeLight


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	note_player.stream = note_audio
	eye_light.show()
	eye_light.turn_off()

func interact(with_item: Item) -> void:
	if with_item.data.item_name == "Mallet":
		impact_sfx.play()
		play_note()
		standard_flash()

func play_note() -> void:
	note_player.play()
	note_just_played.emit(note_data)

func standard_flash() -> void:
	flash_eye_lights(light_color)

func positive_flash() -> void:
	flash_eye_lights(Color.GREEN)

func warning_flash() -> void:
	flash_eye_lights(Color.RED)

func flash_eye_lights(color: Color) -> void:
	eye_light.light_color = color
	eye_light.turn_on()
	eye_light.fade_out()


# SETTERS ----------------------------------------------------------------------
func set_light_color(color: Color) -> void:
	light_color = color
	if not is_node_ready():
		await ready
	eye_light.light_color = light_color

func set_note_data(d: NoteData) -> void:
	note_data = d
	if Engine.is_editor_hint():
		if not is_node_ready():
			await ready
		if not note_data.data_changed.is_connected(_on_note_data_changed):
			note_data.data_changed.connect(_on_note_data_changed)


# SIGNALS ----------------------------------------------------------------------
# EDITOR ONLY
func _on_note_data_changed(note_name: String) -> void:
	name = "Skull" + note_name
