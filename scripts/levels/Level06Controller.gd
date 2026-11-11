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
	BackToMenuButton.attach($UI/RootControl)

	if anim_player and anim_player.has_animation("Take 001"):
		var anim: Animation = anim_player.get_animation("Take 001")
		anim.loop_mode = Animation.LOOP_LINEAR

	_update_buttons()
	status_label.text = "Welcome to Level 6: The Cat. Click the cat or use the controls below to interact."

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
