extends Node3D

## Level 06 Controller: Showcase exhibit for the 3D cat model (cat.glb).
## Features interactive turntable spin, animation playback, 3D click/pet interaction, and menu navigation.

@onready var cat_pivot: Node3D = $CatPivot
@onready var cat_instance: Node3D = $CatPivot/Cat
@onready var anim_player: AnimationPlayer = $CatPivot/Cat/AnimationPlayer
@onready var camera: Camera3D = $Camera3D

@onready var status_label: Label = %StatusLabel
@onready var btn_spin: Button = %BtnSpin
@onready var btn_anim: Button = %BtnAnim
@onready var btn_pet: Button = %BtnPet
@onready var btn_reset: Button = %BtnReset
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

@export var spin_speed: float = 0.8
var is_spinning: bool = true
var is_anim_playing: bool = false
var pet_count: int = 0
var hop_tween: Tween = null

func _ready() -> void:
	btn_spin.pressed.connect(_on_spin_pressed)
	btn_anim.pressed.connect(_on_anim_pressed)
	btn_pet.pressed.connect(pet_cat)
	btn_reset.pressed.connect(_on_reset_pressed)
	BackToMenuButton.attach($UI/RootControl, Color(0.96, 0.58, 0.68))
	_apply_gui_theme()

	if anim_player and anim_player.has_animation("Take 001"):
		var anim: Animation = anim_player.get_animation("Take 001")
		anim.loop_mode = Animation.LOOP_LINEAR

	_update_buttons()
	status_label.text = "Welcome to Level 6: The Cat. Click the cat or use the controls below to interact."

func _make_box_style(bg: Color, border: Color, border_w: int = 2, radius: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb

func _apply_gui_theme() -> void:
	# Level 6 Color Scheme: Sanctuary Warm Coral-Rose & Cream-Peach
	var panel_sb := _make_box_style(Color(0.16, 0.08, 0.12, 0.94), Color(0.96, 0.58, 0.68, 0.95), 2, 8)
	for p in [$UI/RootControl/HeaderPanel, $UI/RootControl/BottomBar, banner]:
		if p != null:
			p.add_theme_stylebox_override("panel", panel_sb)
	status_label.add_theme_color_override("font_color", Color(0.99, 0.94, 0.96))
	status_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	status_label.add_theme_constant_override("outline_size", 2)
	banner_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.9))
	banner_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	banner_label.add_theme_constant_override("outline_size", 3)
	var btn_normal := _make_box_style(Color(0.28, 0.12, 0.18, 0.96), Color(0.96, 0.62, 0.72, 0.95), 2, 6)
	var btn_hover := _make_box_style(Color(0.40, 0.18, 0.26, 1.0), Color(1.0, 0.80, 0.86, 1.0), 2, 6)
	var btn_pressed := _make_box_style(Color(0.52, 0.22, 0.32, 1.0), Color(1.0, 0.92, 0.95, 1.0), 2, 6)
	for btn in [btn_pet, btn_spin, btn_anim, btn_reset]:
		if btn == null:
			continue
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.97))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		btn.add_theme_constant_override("outline_size", 2)

func _process(delta: float) -> void:
	if is_spinning and is_instance_valid(cat_pivot):
		cat_pivot.rotate_y(spin_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from := camera.project_ray_origin(event.position)
		var to := from + camera.project_ray_normal(event.position) * 100.0
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var hit := space_state.intersect_ray(query)
		if not hit.is_empty():
			var collider: Object = hit.collider
			if collider is Area3D and collider.name == "ClickArea":
				pet_cat()

func pet_cat() -> void:
	pet_count += 1
	status_label.text = "You pet the cat! (x%d) *Purrrrrr...*" % pet_count
	
	# Cute bounce animation
	if hop_tween != null and hop_tween.is_valid():
		hop_tween.kill()
	hop_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var base_pos := Vector3(0, 0, 0)
	hop_tween.tween_property(cat_instance, "position:y", 0.35, 0.15)
	hop_tween.chain().set_ease(Tween.EASE_IN).tween_property(cat_instance, "position:y", 0.0, 0.2)

	if pet_count >= 5:
		banner.visible = true
		banner_label.text = "PURR-FECTION ACHIEVED!\nThe cat is thoroughly pleased and purrs in harmonic resonance."

func _on_spin_pressed() -> void:
	is_spinning = not is_spinning
	_update_buttons()

func _on_anim_pressed() -> void:
	if not anim_player or not anim_player.has_animation("Take 001"):
		status_label.text = "No animation tracks found on cat model."
		return
	
	if is_anim_playing:
		anim_player.pause()
		is_anim_playing = false
		status_label.text = "Cat animation paused."
	else:
		anim_player.play("Take 001")
		is_anim_playing = true
		status_label.text = "Playing cat animation ('Take 001')."
	_update_buttons()

func _on_reset_pressed() -> void:
	is_spinning = true
	if anim_player and anim_player.is_playing():
		anim_player.stop()
	is_anim_playing = false
	if is_instance_valid(cat_pivot):
		cat_pivot.rotation = Vector3.ZERO
	if is_instance_valid(cat_instance):
		cat_instance.position = Vector3.ZERO
	pet_count = 0
	banner.visible = false
	status_label.text = "Sanctuary reset. The cat rests peacefully on its pedestal."
	_update_buttons()

func _update_buttons() -> void:
	btn_spin.text = "Pause Spin" if is_spinning else "Resume Spin"
	btn_anim.text = "Pause Animation" if is_anim_playing else "Play Animation"
