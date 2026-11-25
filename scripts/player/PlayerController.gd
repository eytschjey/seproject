class_name PlayerController
extends CharacterBody3D

## First-Person 3D Player Controller (PBI-02).
## Supports WASD/Arrow movement, Shift sprint, Space jump, mouse look with Esc capture toggle,
## and centered RayCast3D detection of Interactable3D targets with contextual "[E] ..." prompts.

signal focus_changed(interactable: Node)
signal interacted_with(interactable: Node)
signal mouse_capture_changed(captured: bool)

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.8
@export var mouse_sensitivity: float = 0.0025
@export var min_pitch_degrees: float = -80.0
@export var max_pitch_degrees: float = 80.0
@export var interaction_range: float = 3.5
@export var capture_mouse_on_ready: bool = true

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var interaction_ray: RayCast3D = $CameraPivot/Camera3D/InteractionRay
@onready var prompt_panel: PanelContainer = %PromptPanel
@onready var prompt_label: Label = %PromptLabel
@onready var crosshair: ColorRect = %Crosshair

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var is_mouse_captured: bool = false
var focused_interactable: Node = null
var pitch_radians: float = 0.0

func _ready() -> void:
	interaction_ray.target_position = Vector3(0.0, 0.0, -interaction_range)
	interaction_ray.collide_with_areas = true
	interaction_ray.collide_with_bodies = true
	interaction_ray.enabled = true
	_style_prompt_hud()
	prompt_panel.visible = false
	if capture_mouse_on_ready:
		set_mouse_captured(true)

func _style_prompt_hud() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.10, 0.13, 0.86)
	sb.border_color = Color(0.55, 0.58, 0.68, 0.65)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	prompt_panel.add_theme_stylebox_override("panel", sb)
	prompt_label.add_theme_color_override("font_color", Color(0.94, 0.95, 0.98))
	prompt_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.7))
	prompt_label.add_theme_constant_override("outline_size", 1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		toggle_mouse_capture()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and is_mouse_captured:
		apply_look_delta(event.relative)
		return

	if event.is_action_pressed("interact"):
		if try_interact():
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var sprinting: bool = Input.is_key_pressed(KEY_SHIFT)
	var horiz: Vector3 = compute_horizontal_velocity(input_dir, sprinting)
	velocity.x = horiz.x
	velocity.z = horiz.z

	move_and_slide()
	update_interaction_focus()

## Compute horizontal world-space velocity from 2D input and current facing basis.
func compute_horizontal_velocity(input_dir: Vector2, sprinting: bool = false) -> Vector3:
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var speed: float = sprint_speed if sprinting else walk_speed
	return Vector3(direction.x * speed, 0.0, direction.z * speed)

## Apply yaw (body) and clamped pitch (camera pivot) from a relative mouse delta.
func apply_look_delta(relative: Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	var min_rad: float = deg_to_rad(min_pitch_degrees)
	var max_rad: float = deg_to_rad(max_pitch_degrees)
	pitch_radians = clampf(pitch_radians - relative.y * mouse_sensitivity, min_rad, max_rad)
	camera_pivot.rotation.x = pitch_radians

func set_mouse_captured(captured: bool) -> void:
	is_mouse_captured = captured
	if DisplayServer.get_name() != "headless":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE)
	mouse_capture_changed.emit(is_mouse_captured)

func toggle_mouse_capture() -> void:
	set_mouse_captured(not is_mouse_captured)

## Refresh the currently focused Interactable3D from the centered interaction ray.
func update_interaction_focus() -> void:
	interaction_ray.force_raycast_update()
	var next_target: Node = null
	if interaction_ray.is_colliding():
		var collider: Object = interaction_ray.get_collider()
		next_target = _resolve_interactable(collider)

	if next_target != focused_interactable:
		if is_instance_valid(focused_interactable) and focused_interactable.has_method("set_focused"):
			focused_interactable.set_focused(false, self)
		focused_interactable = next_target
		if is_instance_valid(focused_interactable) and focused_interactable.has_method("set_focused"):
			focused_interactable.set_focused(true, self)
		focus_changed.emit(focused_interactable)

	_update_prompt_ui()

## Attempt to interact with the currently focused Interactable3D.
func try_interact() -> bool:
	if not is_instance_valid(focused_interactable):
		return false
	if focused_interactable.has_method("interact") and focused_interactable.interact(self):
		interacted_with.emit(focused_interactable)
		_update_prompt_ui()
		return true
	return false

func _resolve_interactable(collider: Object) -> Node:
	if collider == null or not (collider is Node):
		return null
	var node: Node = collider as Node
	if _is_enabled_interactable(node):
		return node
	var parent: Node = node.get_parent()
	if parent != null and _is_enabled_interactable(parent):
		return parent
	return null

func _is_enabled_interactable(node: Node) -> bool:
	if not (node.has_method("interact") and node.has_method("get_prompt")):
		return false
	if "interaction_enabled" in node and not node.interaction_enabled:
		return false
	return true

func _update_prompt_ui() -> void:
	if is_instance_valid(focused_interactable) and _is_enabled_interactable(focused_interactable):
		var text: String = focused_interactable.get_prompt()
		prompt_label.text = text
		prompt_panel.visible = not text.is_empty()
		crosshair.color = Color(1.0, 0.92, 0.55, 0.95)
	else:
		prompt_label.text = ""
		prompt_panel.visible = false
		crosshair.color = Color(0.92, 0.94, 0.98, 0.65)
