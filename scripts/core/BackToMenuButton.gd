class_name BackToMenuButton
extends Button

## Small HUD button that returns to the main menu. Attach to a level's UI root with attach().

const MENU_SCENE: String = "res://scenes/ui/MainMenu.tscn"

static func attach(parent: Control, accent: Color = Color(0.42, 0.48, 0.56, 0.65)) -> Button:
	var b := BackToMenuButton.new()
	b.text = "< Menu"
	b.position = Vector2(16, 16)
	b.custom_minimum_size = Vector2(84, 38)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.10, 0.11, 0.14, 0.86)
	normal.border_color = accent
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.15, 0.17, 0.21, 0.92)
	hover.border_color = accent.lightened(0.15)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.19, 0.22, 0.27, 0.95)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_color_override("font_color", Color(0.86, 0.88, 0.91))
	b.add_theme_color_override("font_hover_color", Color(0.95, 0.96, 0.98))
	b.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	b.add_theme_constant_override("outline_size", 1)
	b.pressed.connect(b._go_to_menu)
	parent.add_child(b)
	return b

func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
