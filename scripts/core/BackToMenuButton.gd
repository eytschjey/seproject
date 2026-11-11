class_name BackToMenuButton
extends Button

## Small HUD button that returns to the main menu. Attach to a level's UI root with attach().

const MENU_SCENE: String = "res://scenes/ui/MainMenu.tscn"

static func attach(parent: Control, accent: Color = Color(0.55, 0.78, 0.98)) -> Button:
	var b := BackToMenuButton.new()
	b.text = "< Menu"
	b.position = Vector2(16, 16)
	b.custom_minimum_size = Vector2(84, 38)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.10, 0.15, 0.94)
	normal.border_color = accent
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.15, 0.20, 0.28, 0.98)
	hover.border_color = accent.lightened(0.25)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.22, 0.28, 0.38, 1.0)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
	b.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	b.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	b.add_theme_constant_override("outline_size", 2)
	b.pressed.connect(b._go_to_menu)
	parent.add_child(b)
	return b

func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
