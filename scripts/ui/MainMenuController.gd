extends Control

## Main menu: lists the levels and loads the selected one.

## Add new levels here. An empty scene path shows the level as "coming soon".
const LEVELS: Array[Dictionary] = [
	{"title": "Level 1: The Ferryman's Crossing", "scene": "res://scenes/levels/Level01_Tutorial.tscn"},
	{"title": "Level 2: The Hall of Nine Portals", "scene": "res://scenes/levels/Level02_NinePortals.tscn"},
	{"title": "Level 3: The Sun Courtyard", "scene": "res://scenes/levels/Level03_SunCourtyard.tscn"},
	{"title": "Level 4: The Knight's Chasm", "scene": "res://scenes/levels/Level04_KnightsChasm.tscn"},
	{"title": "Level 5: Dreadbury Manor", "scene": ""},
]

@onready var level_list: VBoxContainer = %LevelList
@onready var btn_quit: Button = %BtnQuit

var level_buttons: Array[Button] = []

func _ready() -> void:
	for level in LEVELS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(380, 44)
		var path: String = level["scene"]
		if path == "":
			b.text = "%s (coming soon)" % level["title"]
			b.disabled = true
		else:
			b.text = level["title"]
			b.pressed.connect(_start_level.bind(path))
		level_list.add_child(b)
		level_buttons.append(b)
	btn_quit.pressed.connect(func(): get_tree().quit())

func _start_level(path: String) -> void:
	get_tree().change_scene_to_file(path)
