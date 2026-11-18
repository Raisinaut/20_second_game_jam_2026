@tool
class_name SkullItem
extends Item

signal note_just_played(note_name)

@export var note_data: NoteData : set = set_note_data
@export var note_audio: AudioStream
@export var light_color: Color = Color.WHITE : set = set_light_color

@onready var impact_sfx: AudioStreamPlayer3D = %ImpactSFX
@onready var eye_light_1: FlickerLight3D = $EyeLight1
@onready var eye_light_2: FlickerLight3D = $EyeLight2


func _ready() -> void:
	if Engine.is_editor_hint():
		note_data.data_changed.connect(_on_note_data_changed)
		return
	impact_sfx.stream = note_audio
	eye_light_1.show()
	eye_light_2.show()
	eye_light_1.turn_off()
	eye_light_2.turn_off()

func interact(with_item: Item) -> void:
	if with_item.data.item_name == "Mallet":
		play_impact_sfx()
		flash_eye_lights()

func play_impact_sfx() -> void:
	impact_sfx.play()
	note_just_played.emit(note_data)

func flash_eye_lights() -> void:
	eye_light_1.turn_on()
	eye_light_2.turn_on()
	eye_light_1.fade_out()
	eye_light_2.fade_out()


# SETTERS ----------------------------------------------------------------------
func set_light_color(color: Color) -> void:
	light_color = color
	if not is_node_ready():
		await ready
	eye_light_1.light_color = light_color
	eye_light_2.light_color = light_color

func set_note_data(d: NoteData) -> void:
	note_data = d


# SIGNALS ----------------------------------------------------------------------
# EDITOR ONLY
func _on_note_data_changed(note_name: String) -> void:
	name = "Skull" + note_name
