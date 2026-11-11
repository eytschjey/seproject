class_name BackToMenuButton
extends Button

## Small HUD button that returns to the main menu. Attach to a level's UI root with attach().

const MENU_SCENE: String = "res://scenes/ui/MainMenu.tscn"

static func attach(parent: Control) -> Button:
	var b := BackToMenuButton.new()
	b.text = "< Menu"
	b.position = Vector2(20, 110)
	b.pressed.connect(b._go_to_menu)
	parent.add_child(b)
	return b

func _go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
