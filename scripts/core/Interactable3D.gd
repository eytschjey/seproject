class_name Interactable3D
extends Area3D

## Reusable 3D interaction component (PBI-02).
## Attach to doors, plaques, levers, statues, or props so a first-person PlayerController
## can focus them via RayCast3D, display a contextual prompt ("[E] ..."), and trigger interactions.

signal interacted(player: Node)
signal focused(player: Node)
signal unfocused(player: Node)

@export var prompt_text: String = "Interact"
@export var action_hint: String = "E"
@export var interaction_enabled: bool = true

var is_focused: bool = false

## Returns the formatted contextual HUD prompt, or an empty string if disabled.
func get_prompt() -> String:
	if not interaction_enabled:
		return ""
	return "[%s] %s" % [action_hint, prompt_text]

## Trigger the interaction from `player`. Returns true if the interaction was accepted.
func interact(player: Node) -> bool:
	if not interaction_enabled:
		return false
	interacted.emit(player)
	return true

## Update focus state when the player's interaction ray enters or leaves this object.
func set_focused(focus_state: bool, player: Node = null) -> void:
	if is_focused == focus_state:
		return
	is_focused = focus_state
	if is_focused:
		focused.emit(player)
	else:
		unfocused.emit(player)
