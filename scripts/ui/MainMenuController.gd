extends Control

## Main menu: lists the levels and loads the selected one.

## Add new levels here. An empty scene path shows the level as "coming soon".
const LEVELS: Array[Dictionary] = [
	{"title": "Level 1: The Ferryman's Crossing", "scene": "res://scenes/levels/Level01_Tutorial.tscn"},
	{"title": "Level 2: The Hall of Nine Portals", "scene": "res://scenes/levels/Level02_NinePortals.tscn"},
	{"title": "Level 3: The Sun Courtyard", "scene": "res://scenes/levels/Level03_SunCourtyard.tscn"},
	{"title": "Level 4: The Knight's Chasm", "scene": "res://scenes/levels/Level04_KnightsChasm.tscn"},
	{"title": "Level 5: Dreadbury Manor", "scene": "res://scenes/levels/Level05_DreadburyManor.tscn"},
	{"title": "Level 6: The Cat (Showcase)", "scene": "res://scenes/levels/Level06_Cat.tscn"},
]

@onready var level_list: VBoxContainer = %LevelList
@onready var btn_quit: Button = %BtnQuit

var level_buttons: Array[Button] = []

const LEVEL_ACCENTS: Array[Color] = [
	Color(0.35, 0.85, 0.58), # Level 1: Emerald Riverbank
	Color(0.95, 0.76, 0.28), # Level 2: Royal Gold & Burgundy
	Color(0.98, 0.68, 0.22), # Level 3: Solar Courtyard Amber
	Color(0.35, 0.82, 1.0),  # Level 4: Frost-Cyan Chasm
	Color(0.76, 0.46, 0.95), # Level 5: Gothic Amethyst Manor
	Color(0.96, 0.58, 0.68), # Level 6: Sanctuary Coral-Rose
]

func _make_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	return sb

func _style_button(b: Button, bg: Color, accent: Color) -> void:
	b.add_theme_stylebox_override("normal", _make_button_style(bg, accent))
	b.add_theme_stylebox_override("hover", _make_button_style(bg.lightened(0.14), accent.lightened(0.25)))
	b.add_theme_stylebox_override("pressed", _make_button_style(bg.lightened(0.22), Color.WHITE))
	b.add_theme_stylebox_override("disabled", _make_button_style(Color(0.1, 0.1, 0.14, 0.7), Color(0.3, 0.3, 0.38, 0.6)))
	b.add_theme_color_override("font_color", Color(0.96, 0.95, 1.0))
	b.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	b.add_theme_color_override("font_pressed_color", accent.lightened(0.35))
	b.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	b.add_theme_constant_override("outline_size", 2)

func _ready() -> void:
	for i in LEVELS.size():
		var level: Dictionary = LEVELS[i]
		var b := Button.new()
		b.custom_minimum_size = Vector2(380, 44)
		var path: String = level["scene"]
		var accent: Color = LEVEL_ACCENTS[i % LEVEL_ACCENTS.size()]
		_style_button(b, Color(0.14, 0.12, 0.26, 0.96), accent)
		if path == "":
			b.text = "%s (coming soon)" % level["title"]
			b.disabled = true
		else:
			b.text = level["title"]
			b.pressed.connect(_start_level.bind(path))
		level_list.add_child(b)
		level_buttons.append(b)
	_style_button(btn_quit, Color(0.24, 0.10, 0.16, 0.96), Color(0.85, 0.38, 0.52))
	btn_quit.pressed.connect(func(): get_tree().quit())

func _start_level(path: String) -> void:
	get_tree().change_scene_to_file(path)
