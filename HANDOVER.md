# HANDOVER.md — Project State & Backlog for Incoming Agent

**Timestamp:** November 11, 2026  
**Repository:** `https://github.com/eytschjey/seproject.git` (Branch: `main`)  
**Context:** 3D logic puzzle-adventure game built with Godot 4, translating classical mathematical logic riddles into 3D environmental gameplay.

---

## 📌 Executive Summary of Completed Work

1. **Riddle Research & Game Design:**
   * All 21 logic riddles from Prof. Dr. Karl Stroetmann's textbook extracted and formalized in [`story/logical_riddles.md`](story/logical_riddles.md).
   * Level progression roadmap and mechanics mapped in [`story/level_progression.md`](story/level_progression.md).
2. **Godot Configuration:**
   * Renderer: `Forward Plus` (Vulkan).
   * 3D Physics: `Jolt Physics` enabled.
   * Input mappings configured for WASD, Arrows, Space (Jump), E (Interact), R (Reset), J/Tab (Journal).
   * Main startup scene set to `res://scenes/ui/MainMenu.tscn`.
3. **Level 1 (The Ferryman's Crossing - Wolf, Goat & Cabbage):**
   * **Headless Logic:** [`scripts/logic/RiverCrossingLogic.gd`](scripts/logic/RiverCrossingLogic.gd) enforces river crossing rules, hazard checks (wolf/goat and goat/cabbage), victory detection, and optimal BFS pathfinding solver (`find_solution()`).
   * **Automated Unit Tests:** [`tests/TestRiverCrossing.gd`](tests/TestRiverCrossing.gd) runs 46 automated assertions headlessly via Godot CLI.
   * **Playable 3D Greybox Scene:** [`scenes/levels/Level01_Tutorial.tscn`](scenes/levels/Level01_Tutorial.tscn) with animated raft tweens, smooth item hops, lighting, and direct 3D object interaction. Camera positioned at `y = 13, z = 14, pitch = -50°` for complete edge-to-edge visibility of all items.
   * **Direct 3D Click Interaction & Auto-Solver:** Replaced separate HUD load/unload buttons with one-click 3D picking on the Wolf, Goat, and Cabbage (and Raft) via `_unhandled_input` raycasting (prioritizing item hitboxes over the raft hitbox when unloading, and supporting one-click passenger swapping). Includes an animated `Auto-Solve (Debug)` button with pause/resume support, hover feedback (scale tweens, pointing hand cursor), and a streamlined Action Bar (`Row Raft` + `Reset` + `Auto-Solve`).
   * **Scene Controller:** [`scripts/levels/Level01Controller.gd`](scripts/levels/Level01Controller.gd) connects 3D clicks, auto-solver coroutine, and node positions to logic signals. Reset re-enables controls properly, and carried items follow raft translation on every frame.
   * **Integration Test:** [`tests/TestLevel01Scene.gd`](tests/TestLevel01Scene.gd) (14 checks) validates auto-solver activation, pausing, full solution execution, and one-click 3D screen raycast loading, swapping, and unloading.
4. **Level 2 (The Hall of Nine Portals - Smullyan's Princess & Tiger):**
   * **Headless Logic:** [`scripts/logic/NinePortalsLogic.gd`](scripts/logic/NinePortalsLogic.gd) randomizes the room layout on start and after every reset, dynamically remaps all door inscriptions to match the permuted rooms, evaluates cross-references, checks protocol consistency, enumerates all consistent layouts, deduces the unique Princess room (`solve_princess_room()`), and runs the open-door game flow.
   * **Unit Tests:** [`tests/TestNinePortals.gd`](tests/TestNinePortals.gd) (30 assertions) proves the Princess's room is uniquely deducible for both canonical and randomized layouts.
   * **Scene & Auto-Solver:** [`scenes/levels/Level02_NinePortals.tscn`](scenes/levels/Level02_NinePortals.tscn) with controller [`scripts/levels/Level02Controller.gd`](scripts/levels/Level02Controller.gd): select a door (shows its plaque), then "Open", plus an animated `Auto-Solve (Debug)` button (`%BtnSolve`) that inspects plaques step-by-step and opens the deduced Princess door. Integration test: [`tests/TestLevel02Scene.gd`](tests/TestLevel02Scene.gd) (19 checks).

5. **Level 3 (The Sun Courtyard - 8 Queens):**
   * **Headless Logic:** [`scripts/logic/QueensLogic.gd`](scripts/logic/QueensLogic.gd) - place/remove/toggle queens (max 8, conflicts allowed but reported), conflict pairs, win check, full 92-solution solver (`solve_all()`), and prefix-aware completion solver (`find_completion()`).
   * **Unit Tests:** [`tests/TestQueens.gd`](tests/TestQueens.gd) (29 assertions) verifying attack rules, conflict reporting, full solver, and completion solver.
   * **Scene:** [`scenes/levels/Level03_SunCourtyard.tscn`](scenes/levels/Level03_SunCourtyard.tscn) + [`scripts/levels/Level03Controller.gd`](scripts/levels/Level03Controller.gd): 3D marble board built from a `BoardOrigin` marker, an 8x8 HUD button grid toggles queens, statues are gold when safe / red when attacked, crimson beams link attacking pairs.
   * **Framing & Auto-Solver:** Camera adjusted (`y = 14.0, z = 9.5, pitch = -55°`) to frame the entire board without clipping near tiles. Includes an animated `Auto-Solve (Debug)` button with pause/stop functionality. Test: [`tests/TestLevel03Scene.gd`](tests/TestLevel03Scene.gd) (15 checks).
   * Level 2 victory auto-advances to Level 3 after 4 s. Level 3 victory auto-advances to Level 4 after 4 s.
   * Follow-ups: pushable statues on a grid (needs the player controller), sun-crystal / drawbridge victory animation, beams along all 8 directions.

6. **Level 4 (The Knight's Chasm - Knight's Tour):**
   * **Headless Logic:** [`scripts/logic/KnightsTourLogic.gd`](scripts/logic/KnightsTourLogic.gd) - enforces valid knight jump offsets, board boundaries, unvisited constraint, tracks visited count (64), dead end detection, undo stack, Warnsdorff-heuristic backtracking solver, and bounded path completion (`find_tour_from_path()`).
   * **Unit Tests:** [`tests/TestKnightsTour.gd`](tests/TestKnightsTour.gd) (26 assertions) verifying moves, rejection signals, dead end detection, undo recovery, and complete 64-tile tour.
   * **Scene:** [`scenes/levels/Level04_KnightsChasm.tscn`](scenes/levels/Level04_KnightsChasm.tscn) + [`scripts/levels/Level04Controller.gd`](scripts/levels/Level04Controller.gd): 3D underground cavern over glowing lava, floating stone rune tiles sinking upon departure, golden knight leaping between runes with smooth tweens, valid move highlighting (blue), and live visit counter HUD with undo/reset.
   * **Framing & Auto-Solver:** Camera adjusted (`y = 14.0, z = 9.5, pitch = -55°`) to ensure all 64 runes are framed cleanly. Includes an animated `Auto-Solve (Debug)` button with pause/resume support. Test: [`tests/TestLevel04Scene.gd`](tests/TestLevel04Scene.gd) (14 checks).
   * Level 4 victory auto-advances to Level 5 after 4 s.

7. **Level 5 (The Night at Dreadbury Manor - Who Killed Aunt Agatha?):**
   * **Headless Logic:** [`scripts/logic/DreadburyLogic.gd`](scripts/logic/DreadburyLogic.gd) - models the 3 residents (`AGATHA`, `BUTLER`, `CHARLES`), 8 manor clues, first-order predicates (`killed`, `hates`, `richer_than_agatha`), exhaustive first-order model checker (`enumerate_consistent_models()`, `killer_candidates() == [Suspect.AGATHA]`), clue discovery tracking, suspect selection, accusation evaluation, and logical contradiction explanations (`contradiction_for()`).
   * **Unit Tests:** [`tests/TestDreadbury.gd`](tests/TestDreadbury.gd) (39 assertions) verifying first-order axiom consistency, unique killer deduction, clue inspection, false accusation failure, and victory flow.
   * **Scene:** [`scenes/levels/Level05_DreadburyManor.tscn`](scenes/levels/Level05_DreadburyManor.tscn) + [`scripts/levels/Level05Controller.gd`](scripts/levels/Level05Controller.gd): 3D Victorian manor library with stained-glass windows, fireplace glow, Aunt Agatha in the armchair, Charles and the Butler, 8 clue pedestals, the Accusation Altar with 3 suspect busts, an animated **Dagger of Truth**, and a hidden suicide note revealed with morning sunlight upon solving. Includes an animated `Auto-Solve (Debug)` button with pause/resume support. Test: [`tests/TestLevel05Scene.gd`](tests/TestLevel05Scene.gd) (15 checks).

8. **Main Menu & Level Progression Architecture:**
   * Startup scene set to [`scenes/ui/MainMenu.tscn`](scenes/ui/MainMenu.tscn), managed by [`MainMenuController.gd`](scripts/ui/MainMenuController.gd).
   * Levels 1–5 are unlocked and selectable.
   * All level scenes feature a consistent `< Menu` return button attached via [`BackToMenuButton.gd`](scripts/core/BackToMenuButton.gd).
   * Linear play progression: Level 1 auto-advances to Level 2 (3s delay), Level 2 to Level 3 (4s delay), Level 3 to Level 4 (4s delay), and Level 4 to Level 5 (4s delay).

---

## 🚀 Immediate Next Tasks (Prioritized Backlog)

### ~~Task 1: Level 2 — The Hall of Nine Portals~~ ✅ DONE
* Implemented as a button-driven level with randomized room permutations on start and reset, dynamically updating all door inscriptions so the Princess's door is always uniquely deducible (`NinePortalsLogic.princess_candidates(logic.roles) == [logic.princess_room()]`).
* Opening a tiger door shows "You failed! Press Reset to try again." (no auto-reset).
* Level 1 victory now auto-advances to Level 2 after 3 s (`NEXT_LEVEL_DELAY` in `Level01Controller.gd`); covered by `tests/TestLevel01Transition.gd`.
* Follow-ups: replace buttons with first-person plaque inspection (Task 2) and log plaques into the Journal (Task 3); real tiger/princess art and particles.

### ✅ Main Menu (done)
* [`scenes/ui/MainMenu.tscn`](scenes/ui/MainMenu.tscn) + [`scripts/ui/MainMenuController.gd`](scripts/ui/MainMenuController.gd): level select. To add a level, append an entry to `LEVELS` (empty `scene` = "coming soon"). Levels have a "< Menu" button via [`BackToMenuButton`](scripts/core/BackToMenuButton.gd). Test: `tests/TestMainMenu.gd`.

### Task 2: 3D First-Person Player Controller (Medium Priority)
* **Goal:** Transition from clicking HUD buttons to physically walking through the chambers in 3D.
* **Sub-tasks:**
  1. Create `scenes/player/Player.tscn`:
     - `CharacterBody3D` with collision capsule, camera pivot, and `Camera3D`.
     - `RayCast3D` projecting from the center of the screen to detect interactable objects.
  2. Create `scripts/player/PlayerController.gd`:
     - Mouse look (captured cursor, toggleable with Esc).
     - WASD movement, sprint, and jump using Godot's configured input actions.
  3. Create an `Interactable3D` component (`scripts/core/Interactable3D.gd`):
     - When the player looks at an interactable object, display a prompt (e.g. `"[E] Inspect Plaque"` or `"[E] Pull Lever"`).
     - Pressing `interact` emits an `interacted(player)` signal.

### Task 3: In-Game Logic Journal UI (Medium Priority)
* **Goal:** A clean notebook UI (`scenes/ui/Journal.tscn`) toggled by pressing `[J]` or `[Tab]`.
* **Sub-tasks:**
  - Automatically logs discovered door inscriptions and NPC dialogue clues.
  - Optional: A grid/matrix scratchpad so players can manually cross off deductions without pen and paper.

### ~~Task 4: Level 5 — Dreadbury Manor (Narrative Murder Mystery)~~ ✅ DONE
* Implemented in [`scripts/logic/DreadburyLogic.gd`](scripts/logic/DreadburyLogic.gd), [`scripts/levels/Level05Controller.gd`](scripts/levels/Level05Controller.gd), and [`scenes/levels/Level05_DreadburyManor.tscn`](scenes/levels/Level05_DreadburyManor.tscn), connected from Level 4 and enabled in `MainMenuController.gd`.

### Task 4 (New): 3D Model Replacement & Visual Asset Pipeline (Greybox to Final Art)
* **Goal:** Incrementally replace rapid-prototype CSG geometry across Levels 1–5 with textured 3D models while preserving headless test suites, 3D mouse picking, and model-view decoupling.
* **Pipeline & Format Standards:**
  * **File Format:** glTF 2.0 Binary (`.glb`) exclusively. Bundles PBR textures, materials, and meshes without requiring external software (e.g. Blender) during headless test runs or CI.
  * **Directory Organization:**
    * `assets/models/environment/` (terrain, riverbanks, stone walls, lava chasm cliffs, manor library)
    * `assets/models/props/` (wooden raft, cabbage, doors, brass plaques, dagger, chests, tiles)
    * `assets/models/characters/` (wolf, goat, queen statue, knight piece, suspect busts)
    * `assets/textures/` & `assets/materials/`
    * `scenes/props/` (inherited `.tscn` prefabs with configured `Area3D`, `CollisionShape3D`, and material overrides)
  * **Inherited Scenes over Raw `.glb`:** Never drop raw `.glb` files directly into master level scenes. Always create an inherited scene (`scenes/props/<PropName>.tscn`) from the imported `.glb`. This preserves collision shapes, script references, and material overrides when re-exporting updated models from 3D DCC tools.
  * **Godot Import Suffixes:** Suffix meshes with `-col` for auto-generated convex colliders or `-colonly` for invisible boundary colliders.
* **Level-by-Level Asset Breakdown & Controller Hookup Rules:**
  1. **Level 1 (Ferryman's Crossing):**
     * Replace CSG nodes (`$Items/Wolf`, `$Items/Goat`, `$Items/Cabbage`) with 3D model prefabs or `MeshInstance3D` nodes.
     * *Constraint:* Preserve the exact node names (`Wolf`, `Goat`, `Cabbage`) and keep the child `ClickArea` (`Area3D`) + `CollisionShape3D` intact so [`Level01Controller.gd`](scripts/levels/Level01Controller.gd) raycasting continues to function with zero code changes.
     * Replace `$Environment/Raft` with a wooden raft mesh; retain the `$Environment/Raft/ItemSlot` (`Marker3D`) and `ClickArea`.
     * Add river water shader and textured riverbank terrain.
  2. **Level 2 (Hall of Nine Portals):**
     * Replace door frame CSG and door panel CSG with ornate doorframe and wooden door meshes.
     * *Constraint:* Retain the `Hinge` (`Node3D`) parent pivot node so [`Level02Controller.gd`](scripts/levels/Level02Controller.gd)'s `-105.0°` rotation tween opens the door around its hinge axis naturally.
     * Add 3D Tiger and Princess models/sprites behind opened doors.
  3. **Level 3 (Sun Courtyard):**
     * Create `scenes/props/QueenStatue.tscn` prefab.
     * In [`Level03Controller.gd`](scripts/levels/Level03Controller.gd), update `_spawn_queen(cell)` to instantiate `QueenScene.instantiate()` instead of procedurally building CSG cylinders and spheres.
     * Expose surface material override on the queen mesh to preserve the gold (`COLOR_SAFE`) vs crimson (`COLOR_CONFLICT`) visual feedback.
     * Replace procedural tiles with textured marble tile meshes.
  4. **Level 4 (Knight's Chasm):**
     * Create `scenes/props/KnightPiece.tscn` prefab.
     * In [`Level04Controller.gd`](scripts/levels/Level04Controller.gd), update `_build_knight()` to instantiate the prefab under `$Board/Knight`.
     * Replace CSG rune blocks with carved stone rune slabs with glowing emission runes.
     * Replace CSG lava floor with an animated scrolling lava shader.
  5. **Level 5 (Dreadbury Manor):**
     * Replace procedural suspect busts with character busts or portraits.
     * Replace CSG dagger with an ornate 3D dagger model for the "Dagger of Truth" animation.
     * Add Victorian furniture: armchair for Aunt Agatha, mahogany bookshelves, fireplace fire particle effect.
* **Validation Requirement:** Always run `godot --headless --validate --quit scenes/levels/<Level>.tscn` and run all test suites (`godot --headless -s res://tests/<TestSuite>.gd`) after replacing any visual assets.

### Task 5: Bonus Chamber — The Midnight Bridge (Bridge & Torch Problem) (Future)
* See [`story/level_progression.md`](story/level_progression.md) and [`story/logical_riddles.md`](story/logical_riddles.md#19-the-bridge-and-torch-problem).

---

## 🔧 Essential Commands for Testing & Validation

All tests can be executed directly in the terminal via Godot CLI:

```bash
cd "/Users/jan/Desktop/Software Engineering/seproject"

# 1. Level 1: River Crossing
godot --headless -s res://tests/TestRiverCrossing.gd
godot --headless -s res://tests/TestLevel01Scene.gd
godot --headless -s res://tests/TestLevel01Transition.gd

# 2. Level 2: Hall of Nine Portals
godot --headless -s res://tests/TestNinePortals.gd
godot --headless -s res://tests/TestLevel02Scene.gd

# 3. Level 3: Sun Courtyard (8-Queens)
godot --headless -s res://tests/TestQueens.gd
godot --headless -s res://tests/TestLevel03Scene.gd

# 4. Level 4: Knight's Chasm (Knight's Tour)
godot --headless -s res://tests/TestKnightsTour.gd
godot --headless -s res://tests/TestLevel04Scene.gd

# 5. Level 5: Dreadbury Manor (Who Killed Aunt Agatha?)
godot --headless -s res://tests/TestDreadbury.gd
godot --headless -s res://tests/TestLevel05Scene.gd

# 6. Global Navigation & UI
godot --headless -s res://tests/TestMainMenu.gd

# 7. Validate scene syntax without opening GUI
godot --headless --validate --quit scenes/ui/MainMenu.tscn
godot --headless --validate --quit scenes/levels/Level01_Tutorial.tscn
godot --headless --validate --quit scenes/levels/Level02_NinePortals.tscn
godot --headless --validate --quit scenes/levels/Level03_SunCourtyard.tscn
godot --headless --validate --quit scenes/levels/Level04_KnightsChasm.tscn
godot --headless --validate --quit scenes/levels/Level05_DreadburyManor.tscn

# 8. Launch Godot game directly to test interactively
godot
```

---

## 💡 Important Tips & Gotchas
* **Model-View Separation:** Never put puzzle rules directly inside a 3D scene script. Always write the logic in `scripts/logic/` first with a matching test in `tests/`.
* **Testing without Display:** When running commands on macOS via automated environments, always pass `--headless` to prevent window-manager blocking.
* **Working Directory:** All project work lives under `/Users/jan/Desktop/Software Engineering/seproject`.
