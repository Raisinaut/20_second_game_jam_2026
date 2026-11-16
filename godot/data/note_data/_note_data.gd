class_name NoteData
extends Resource

enum Modifiers {
	NATURAL,
	FLAT,
	SHARP
}

var notes : Array [String] = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G"
]

@export var note: String
@export var modifier: Modifiers

func equals(comparison_data: NoteData) -> bool:
	#print("Compare: ", get_name_string(), " to ", comparison_data.get_name_string())
	return comparison_data.get_name_string() == get_name_string()

func get_name_string() -> String:
	var note_idx: int = notes.find(note.to_upper())
	if note_idx == -1:
		print("Note not included in notes array.")
		return "[error]"
	
	var note_string: String = ""
	var modifier_string: String = ""
	match(modifier):
		Modifiers.NATURAL:
			pass
		Modifiers.FLAT:
			if note == "C" or note == "F":
				note_idx += 1
			else:
				modifier_string = "b"
		Modifiers.SHARP:
			if note == "B" or note == "E":
				note_idx += 1
			else:
				modifier_string = "#"
	
	note_string = notes[note_idx]
	return note_string + modifier_string
