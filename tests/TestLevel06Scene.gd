extends SceneTree

# Automated headless integration test for Level06_Cat scene.

var checks_failed: int = 0

func check(condition: bool, msg: String) -> void:
	if condition:
		print("  ✔ ", msg)
	else:
		print("  ❌ FAIL: ", msg)
		checks_failed += 1

func _init() -> void:
	print("\n==================================================")
	print("🧪 Running Level 06 (Cat Showcase) Scene Tests")
	print("==================================================\n")

	var scene_res := load("res://scenes/levels/Level06_Cat.tscn") as PackedScene
	if not scene_res:
		print("FATAL: Failed to load Level06_Cat.tscn")
		quit(1)
		return

	var s: Node = scene_res.instantiate()
	root.add_child(s)
	current_scene = s
	await process_frame

	print("[Test 1: Scene Hierarchy & Cat Model Loading]")
	check(is_instance_valid(s.cat_instance), "Cat model instance is valid")
	check(is_instance_valid(s.anim_player), "AnimationPlayer is found on cat model")
	check(s.anim_player.has_animation("Take 001"), "Animation 'Take 001' is present")
	check(s.cat_instance.has_node("ClickArea"), "ClickArea (Area3D) is attached to cat prefab")

	var back_btn: Button = null
	for child in s.get_node("UI/RootControl").get_children():
		if child is BackToMenuButton:
			back_btn = child
	check(back_btn != null, "BackToMenuButton is attached to UI")

	print("[Test 2: Turntable Spin Toggle]")
	check(s.is_spinning == true, "Spin starts enabled by default")
	s.btn_spin.pressed.emit()
	check(s.is_spinning == false, "Spin is paused after toggle")
	check(s.btn_spin.text == "Resume Spin", "Button label reflects paused state")
	s.btn_spin.pressed.emit()
	check(s.is_spinning == true, "Spin resumes after second toggle")

	print("[Test 3: Animation Playback Toggle]")
	check(s.is_anim_playing == false, "Animation starts paused")
	s.btn_anim.pressed.emit()
	check(s.is_anim_playing == true, "Animation begins playing")
	check(s.anim_player.is_playing(), "AnimationPlayer is actively playing")
	s.btn_anim.pressed.emit()
	check(s.is_anim_playing == false, "Animation pauses on toggle")

	print("[Test 4: Pet Interaction & Purr-fection Banner]")
	check(s.pet_count == 0, "Initial pet count is 0")
	check(not s.banner.visible, "Banner starts hidden")
	s.btn_pet.pressed.emit()
	check(s.pet_count == 1, "Pet button increments pet count to 1")
	check(s.status_label.text.contains("Purrrrrr"), "Status shows purr message")

	# Pet up to 5 times
	for i in range(4):
		s.btn_pet.pressed.emit()
	check(s.pet_count == 5, "Pet count reaches 5")
	check(s.banner.visible, "Purr-fection banner becomes visible at 5 pets")
	check(s.banner_label.text.contains("PURR-FECTION"), "Banner displays PURR-FECTION text")

	print("[Test 5: Reset Functionality]")
	s.btn_reset.pressed.emit()
	check(s.pet_count == 0, "Reset clears pet count back to 0")
	check(not s.banner.visible, "Banner is hidden after reset")
	check(s.is_spinning == true, "Spin is re-enabled on reset")
	check(s.cat_pivot.rotation == Vector3.ZERO, "Cat turntable rotation reset to zero")

	print("\n==================================================")
	if checks_failed == 0:
		print("🎉 ALL 17 CHECKS PASSED SUCCESSFULLY!")
	else:
		print("❌ %d CHECKS FAILED!" % checks_failed)
	print("==================================================\n")

	s.queue_free()
	quit(1 if checks_failed > 0 else 0)
