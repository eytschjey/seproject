# HANDOVER.md — Project State & Backlog for Incoming Agent

**Timestamp:** November 25, 2026  
**Repository:** `https://github.com/eytschjey/seproject.git` (Branch: `main`)  
**Context:** 3D logic puzzle-adventure game built with Godot 4, translating classical mathematical logic riddles into 3D environmental gameplay.

---

## 📌 Executive Summary of Completed Work

1. **Riddle Research, Requirements & Game Design:**
   * All 21 logic riddles from Prof. Dr. Karl Stroetmann's textbook extracted and formalized in [`story/logical_riddles.md`](story/logical_riddles.md).
   * Level progression roadmap and mechanics mapped in [`story/level_progression.md`](story/level_progression.md).
   * Functional/non-functional requirements specification and traceability matrix documented in [`docs/requirements.md`](docs/requirements.md); agile user stories and Given/When/Then acceptance criteria documented in [`docs/user_stories.md`](docs/user_stories.md); prioritized product backlog and sprint roadmap documented in [`docs/backlog.md`](docs/backlog.md).
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
   * **Scene Controller:** [`scripts/levels/Level01Controller.gd`](scripts/levels/Level01Controller.gd) connects 3D clicks, auto-solver coroutine, and node positions to logic signals, and applies a subtle **Moss & Slate** HUD color scheme. Reset re-enables controls properly, and carried items follow raft translation on every frame.
   * **Integration Test:** [`tests/TestLevel01Scene.gd`](tests/TestLevel01Scene.gd) (14 checks) validates auto-solver activation, pausing, full solution execution, and one-click 3D screen raycast loading, swapping, and unloading.
4. **Level 2 (The Hall of Nine Portals - Smullyan's Princess & Tiger):**
   * **Headless Logic:** [`scripts/logic/NinePortalsLogic.gd`](scripts/logic/NinePortalsLogic.gd) randomizes the room layout on start and after every reset, dynamically remaps all door inscriptions to match the permuted rooms, evaluates cross-references, checks protocol consistency, enumerates all consistent layouts, deduces the unique Princess room (`solve_princess_room()`), and runs the open-door game flow.
   * **Unit Tests:** [`tests/TestNinePortals.gd`](tests/TestNinePortals.gd) (30 assertions) proves the Princess's room is uniquely deducible for both canonical and randomized layouts.
   * **Direct 3D Door Click, First-Person Mode & Auto-Solver:** [`scenes/levels/Level02_NinePortals.tscn`](scenes/levels/Level02_NinePortals.tscn) with controller [`scripts/levels/Level02Controller.gd`](scripts/levels/Level02Controller.gd): click any of the 9 doors directly in 3D via `_unhandled_input` raycasting OR toggle **First-Person Mode (`[V]` / `First-Person [V]`)** to walk the hall with `Player.tscn` and inspect doors via `Interactable3D` (`[E] Inspect Door N`), automatically logging inscriptions to the Logic Journal (with automatic mouse-capture release/restore when toggling the Journal). Includes an animated `Auto-Solve (Debug)` button (`%BtnSolve`) and subtle **Warm Stone & Antique Brass** HUD color scheme. Integration test: [`tests/TestLevel02Scene.gd`](tests/TestLevel02Scene.gd) (31 checks).

5. **Level 3 (The Sun Courtyard - 8 Queens):**
   * **Headless Logic:** [`scripts/logic/QueensLogic.gd`](scripts/logic/QueensLogic.gd) - place/remove/toggle queens (max 8, conflicts allowed but reported), conflict pairs, win check, full 92-solution solver (`solve_all()`), and prefix-aware completion solver (`find_completion()`).
   * **Unit Tests:** [`tests/TestQueens.gd`](tests/TestQueens.gd) (29 assertions) verifying attack rules, conflict reporting, full solver, and completion solver.
   * **Scene:** [`scenes/levels/Level03_SunCourtyard.tscn`](scenes/levels/Level03_SunCourtyard.tscn) + [`scripts/levels/Level03Controller.gd`](scripts/levels/Level03Controller.gd): 3D marble board built from a `BoardOrigin` marker, an 8x8 HUD button grid toggles queens, statues are gold when safe / red when attacked, crimson beams link attacking pairs, and HUD panels/buttons use a non-overlapping, subtle **Sandstone & Warm Umber** color scheme.
   * **Framing & Auto-Solver:** Camera adjusted (`y = 14.0, z = 9.5, pitch = -55°`) to frame the entire board without clipping near tiles. Includes an animated `Auto-Solve (Debug)` button with pause/stop functionality. Test: [`tests/TestLevel03Scene.gd`](tests/TestLevel03Scene.gd) (15 checks).
   * Level 2 victory auto-advances to Level 3 after 4 s. Level 3 victory auto-advances to Level 4 after 4 s.
   * Follow-ups: pushable statues on a grid (needs the player controller), sun-crystal / drawbridge victory animation, beams along all 8 directions.

6. **Level 4 (The Knight's Chasm - Knight's Tour):**
   * **Headless Logic:** [`scripts/logic/KnightsTourLogic.gd`](scripts/logic/KnightsTourLogic.gd) - enforces valid knight jump offsets, board boundaries, unvisited constraint, tracks visited count (64), dead end detection, undo stack, Warnsdorff-heuristic backtracking solver, and bounded path completion (`find_tour_from_path()`).
   * **Unit Tests:** [`tests/TestKnightsTour.gd`](tests/TestKnightsTour.gd) (26 assertions) verifying moves, rejection signals, dead end detection, undo recovery, and complete 64-tile tour.
   * **Scene:** [`scenes/levels/Level04_KnightsChasm.tscn`](scenes/levels/Level04_KnightsChasm.tscn) + [`scripts/levels/Level04Controller.gd`](scripts/levels/Level04Controller.gd): 3D underground cavern over glowing lava, floating stone rune tiles sinking upon departure, golden knight leaping between runes with smooth tweens, valid move highlighting (blue), and non-overlapping, subtle **Charcoal-Slate & Muted Steel-Blue/Ochre** HUD panels, labels, and 8x8 cell buttons (warm ochre current cell, muted steel-blue valid moves, slate-teal visited step numbers) for clear yet understated visibility against the black and orange lava background.
   * **Framing & Auto-Solver:** Camera adjusted (`y = 14.0, z = 9.5, pitch = -55°`) to ensure all 64 runes are framed cleanly. Includes an animated `Auto-Solve (Debug)` button with pause/resume support. Test: [`tests/TestLevel04Scene.gd`](tests/TestLevel04Scene.gd) (18 checks).
   * Level 4 victory auto-advances to Level 5 after 4 s.

7. **Level 5 (The Night at Dreadbury Manor - Who Killed Aunt Agatha?):**
   * **Headless Logic:** [`scripts/logic/DreadburyLogic.gd`](scripts/logic/DreadburyLogic.gd) - models the 3 residents (`AGATHA`, `BUTLER`, `CHARLES`), 3 distinct randomized first-order logic cases (`Case.AGATHA`, `Case.BUTLER`, `Case.CHARLES`) rotating on start and reset, 8 dynamic manor clues per case, first-order predicates (`killed`, `hates`, `richer_than_agatha`), exhaustive first-order model checker (`enumerate_consistent_models(case_id)`, `killer_candidates(case_id)`, `solve_killer()`), clue discovery tracking, suspect selection, accusation evaluation, case-specific logical contradiction explanations (`contradiction_for()`), and outcome-specific victory messages (`victory_message_for()`).
   * **Unit Tests:** [`tests/TestDreadbury.gd`](tests/TestDreadbury.gd) (62 assertions) verifying first-order axiom consistency, unique killer deduction across all 3 outcomes, randomized reset rotation, clue inspection, false accusation failure, and victory flow.
   * **Scene:** [`scenes/levels/Level05_DreadburyManor.tscn`](scenes/levels/Level05_DreadburyManor.tscn) + [`scripts/levels/Level05Controller.gd`](scripts/levels/Level05Controller.gd): 3D Victorian manor library with stained-glass windows, fireplace glow, Aunt Agatha in the armchair, Charles and the Butler, 8 clue pedestals, the Accusation Altar with 3 suspect busts, an animated **Dagger of Truth**, spoiler-free neutral status prompts (never leaking which outcome is active prior to solving), and hidden evidence revealed behind the true killer's bust with outcome-tinted morning lighting upon solving. Uses a non-overlapping, subtle **Dusk-Plum & Muted Pewter** HUD color scheme and includes an animated `Auto-Solve (Debug)` button with pause/resume support. Test: [`tests/TestLevel05Scene.gd`](tests/TestLevel05Scene.gd) (22 checks).

8. **Main Menu & Level Progression Architecture:**
   * Startup scene set to [`scenes/ui/MainMenu.tscn`](scenes/ui/MainMenu.tscn), managed by [`MainMenuController.gd`](scripts/ui/MainMenuController.gd) with a subtle **Slate-Indigo** menu card and muted per-level accent-colored buttons.
   * Levels 1–6 are unlocked and selectable.
   * All level scenes feature a non-overlapping `< Menu` return button at `(16, 16)` (left of `HeaderPanel` at `offset_left = 112.0`) attached via [`BackToMenuButton.gd`](scripts/core/BackToMenuButton.gd) with level-matched muted accent borders.
   * Linear play progression: Level 1 auto-advances to Level 2 (3s delay), Level 2 to Level 3 (4s delay), Level 3 to Level 4 (4s delay), Level 4 to Level 5 (4s delay), and Level 5 to Level 6 (4s delay).

9. **Level 6 (The Cat Sanctuary — 3D Model Exhibit):**
   * **Asset Location & Pipeline:** Moved model from workspace root into the standard asset pipeline at [`assets/models/characters/cat.glb`](assets/models/characters/cat.glb) along with its PBR texture [`cat_0.png`](assets/models/characters/cat_0.png).
   * **Inherited Prefab:** Created [`scenes/props/Cat.tscn`](scenes/props/Cat.tscn) with attached `Area3D` (`ClickArea`) and `CollisionShape3D` (`BoxShape3D`) for 3D physics raycast picking.
   * **3D Scene & Controller:** Created [`scenes/levels/Level06_Cat.tscn`](scenes/levels/Level06_Cat.tscn) and [`scripts/levels/Level06Controller.gd`](scripts/levels/Level06Controller.gd) featuring turntable orbit spin (`cat_pivot.rotate_y`), animation playback toggle for `"Take 001"`, `< Menu` button, subtle **Warm Taupe & Dusty Rose** HUD color scheme, and interactive mouse petting with hop tweens and "PURR-FECTION ACHIEVED" banner.
   * **Automated Integration Test:** [`tests/TestLevel06Scene.gd`](tests/TestLevel06Scene.gd) (17 checks passing) verifying scene hierarchy, spin toggles, animation playback, pet count increments, banner visibility, and reset.
   * **Menu & Progression:** Added to [`MainMenuController.gd`](scripts/ui/MainMenuController.gd) and linked as `NEXT_LEVEL_SCENE` in [`Level05Controller.gd`](scripts/levels/Level05Controller.gd).

10. **GitHub Issues, Labels & Git Branching Workflow:**
   * **Issue & Backlog Sync:** All 14 open backlog items (`PBI-01`–`PBI-14` in [`docs/backlog.md`](docs/backlog.md)) are tracked as GitHub Issues `#1`–`#14` in `eytschjey/seproject` with standardized priority (`P1`–`P3`) and domain/type labels (`gameplay`, `ui`, `3d-assets`, `bonus`, `ci`, `enhancement`, `bug`, `documentation`).
   * **Branching & PR Policy:** [`AGENTS.md`](AGENTS.md) enforces branch-based development (`feat/`, `fix/`, `assets/`, `docs/`, `chore/`), forbids developing directly on `main`, and requires Pull Requests with headless verification before merging.

11. **In-Game Logic Journal & Deduction Matrix (`PBI-01` / `#1` & `PBI-09` / `#9`):**
   * **Headless Model:** [`scripts/logic/JournalState.gd`](scripts/logic/JournalState.gd) stores per-level entries with deduplication, explicit ordering, reset clearing, signals (`entry_added`, `entry_updated`, `journal_cleared`, `state_changed`, `scratchpad_changed`), and a per-level deduction scratchpad matrix (`UNKNOWN` / `YES` `✓` / `NO` `✗`).
   * **UI Overlay:** [`scenes/ui/Journal.tscn`](scenes/ui/Journal.tscn) + [`scripts/ui/JournalController.gd`](scripts/ui/JournalController.gd) toggles via `[J]`/`[Tab]`, `Esc`, or the non-overlapping `Journal (N)` button at `(16, 62)` below `< Menu`, with tabs for **Clues & Notes** and **Deduction Matrix** (plus `Clear Matrix`).
   * **Level Integration:** Wired into [`Level02Controller.gd`](scripts/levels/Level02Controller.gd) (auto-logs discovered door inscriptions + 9×4 Door/Role deduction matrix) and [`Level05Controller.gd`](scripts/levels/Level05Controller.gd) (auto-logs discovered clues/FOL formulas + 3×4 Suspect deduction matrix), clearing stale entries and marks on reset.
   * **Automated Test:** [`tests/TestJournal.gd`](tests/TestJournal.gd) (53 checks passing) verifying headless model, scratchpad matrix, UI tabs/toggling, and Level 2/5 integration.

12. **First-Person 3D Player Controller & `Interactable3D` (`PBI-02` / `#2`):**
   * **Reusable Interaction Component:** [`scripts/core/Interactable3D.gd`](scripts/core/Interactable3D.gd) (`Area3D`) with configurable `prompt_text`, `action_hint`, `interaction_enabled`, and signals (`interacted(player)`, `focused(player)`, `unfocused(player)`).
   * **Player Scene & Controller:** [`scenes/player/Player.tscn`](scenes/player/Player.tscn) + [`scripts/player/PlayerController.gd`](scripts/player/PlayerController.gd) (`CharacterBody3D`, capsule collider, `CameraPivot`, `Camera3D`, centered `InteractionRay`, WASD/Shift/Space movement, clamped mouse look with `Esc` capture toggle, crosshair & contextual `[E] ...` prompt HUD).
   * **Automated Test:** [`tests/TestPlayerController.gd`](tests/TestPlayerController.gd) (21 checks passing) verifying `Interactable3D` signals, 3D raycast detection/range/prompting, mouse look clamping, `Esc` capture toggle, and walk/sprint velocities.

13. **Bonus Chamber — The Midnight Bridge (`PBI-10` / `#10` & `PBI-11` / `#11`):**
   * **Headless Model & Solver:** [`scripts/logic/MidnightBridgeLogic.gd`](scripts/logic/MidnightBridgeLogic.gd) enforces Bridge & Torch rules (Ariela 1m, Brian 2m, Charly 5m, Dumpy 8m; 1–2 travelers per crossing with the torch; strict 15-minute torch limit), supports `undo()` recovery from burnout, and includes a Dijkstra shortest-time solver (`find_optimal_solution()`).
   * **3D Scene & Controller:** [`scenes/levels/Level07_MidnightBridge.tscn`](scenes/levels/Level07_MidnightBridge.tscn) + [`scripts/levels/Level07Controller.gd`](scripts/levels/Level07Controller.gd) with staggered 2×2 cliff positions for unobstructed 3D mouse picking, animated bridge crossings, a dynamically flickering `OmniLight3D` torch that shrinks with remaining time and extinguishes on burnout, `Undo`/`Reset`/`Auto-Solve (Debug)`, Midnight Navy & Ember-Amber HUD theme, and Main Menu entry.
   * **Automated Tests:** [`tests/TestMidnightBridge.gd`](tests/TestMidnightBridge.gd) (45 unit assertions) & [`tests/TestLevel07Scene.gd`](tests/TestLevel07Scene.gd) (17 integration checks).

14. **Persistent Save State & Main Menu Progress (`PBI-13` / `#13`):**
   * **Headless Persistence Model:** [`scripts/logic/ProgressStore.gd`](scripts/logic/ProgressStore.gd) persists completed level IDs (`level01`–`level07`) via Godot `ConfigFile` (`user://save.cfg`) with signals (`level_completed`, `progress_changed`) and a `record_completion()` helper wired into all 7 level controllers.
   * **Main Menu UI:** [`scenes/ui/MainMenu.tscn`](scenes/ui/MainMenu.tscn) + [`scripts/ui/MainMenuController.gd`](scripts/ui/MainMenuController.gd) displays `Progress: N / 7 Completed`, highlights completed levels with a `✓ ` badge, and provides a `Reset Progress` button.
   * **Automated Test:** [`tests/TestProgressStore.gd`](tests/TestProgressStore.gd) (19 checks passing).

15. **GitHub Actions CI Pipeline (`PBI-14` / `#14`):**
   * **Workflow & Runner:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml) downloads/caches Godot `4.7.2-stable`, runs `--headless --import --quit`, and executes [`scripts/ci/run_tests.sh`](scripts/ci/run_tests.sh) on every push to `main` and every Pull Request targeting `main`.
   * **Coverage:** Runs all 18 headless unit & integration test suites and validates all 11 `.tscn` scenes in one command (`GODOT_BIN=/path/to/godot ./scripts/ci/run_tests.sh`).

---

## 🚀 Immediate Next Tasks (Prioritized Backlog)

### ~~Task 1: Level 2 — The Hall of Nine Portals~~ ✅ DONE
* Implemented with direct 3D door click selection, randomized room permutations on start and reset, and dynamically updated door inscriptions so the Princess's door is always uniquely deducible (`NinePortalsLogic.princess_candidates(logic.roles) == [logic.princess_room()]`).
* Opening a tiger door shows "You failed! Press Reset to try again." (no auto-reset).
* Level 1 victory now auto-advances to Level 2 after 3 s (`NEXT_LEVEL_DELAY` in `Level01Controller.gd`); covered by `tests/TestLevel01Transition.gd`.
* Follow-ups: first-person walking navigation (Task 2) and logging plaques into the Journal (Task 3); real tiger/princess art and particles.

### ✅ Main Menu (done)
* [`scenes/ui/MainMenu.tscn`](scenes/ui/MainMenu.tscn) + [`scripts/ui/MainMenuController.gd`](scripts/ui/MainMenuController.gd): level select. To add a level, append an entry to `LEVELS` (empty `scene` = "coming soon"). Levels have a "< Menu" button via [`BackToMenuButton`](scripts/core/BackToMenuButton.gd). Test: `tests/TestMainMenu.gd`.

### ~~Task 2: 3D First-Person Player Controller (Medium Priority)~~ ✅ DONE (`PBI-02` / `#2` & `PBI-04` / `#4`)
* Implemented in [`scenes/player/Player.tscn`](scenes/player/Player.tscn), [`scripts/player/PlayerController.gd`](scripts/player/PlayerController.gd), and [`scripts/core/Interactable3D.gd`](scripts/core/Interactable3D.gd), verified by [`tests/TestPlayerController.gd`](tests/TestPlayerController.gd) (21 checks), and integrated into Level 2 (`Level02_NinePortals.tscn`, `[V]` toggle + `[E]` `Interactable3D` door plaques + Journal mouse-capture sync, verified by [`tests/TestLevel02Scene.gd`](tests/TestLevel02Scene.gd), 31 checks).

### ~~Task 3: In-Game Logic Journal UI (Medium Priority)~~ ✅ DONE (`PBI-01` / `#1` & `PBI-09` / `#9`)
* Implemented in [`scripts/logic/JournalState.gd`](scripts/logic/JournalState.gd), [`scenes/ui/Journal.tscn`](scenes/ui/Journal.tscn), and [`scripts/ui/JournalController.gd`](scripts/ui/JournalController.gd) (including the interactive Deduction Matrix scratchpad for Level 2 and Level 5), verified by [`tests/TestJournal.gd`](tests/TestJournal.gd) (53 checks).

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

### ~~Task 5: Bonus Chamber — The Midnight Bridge (Bridge & Torch Problem)~~ ✅ DONE (`PBI-10` / `#10` & `PBI-11` / `#11`)
* Implemented headless logic ([`MidnightBridgeLogic.gd`](scripts/logic/MidnightBridgeLogic.gd)), 3D scene ([`Level07_MidnightBridge.tscn`](scenes/levels/Level07_MidnightBridge.tscn)), controller ([`Level07Controller.gd`](scripts/levels/Level07Controller.gd)), Main Menu entry, and 62 automated checks ([`TestMidnightBridge.gd`](tests/TestMidnightBridge.gd) & [`TestLevel07Scene.gd`](tests/TestLevel07Scene.gd)).

---

## 🔧 Essential Commands for Testing & Validation

All tests can be executed in one shot via [`scripts/ci/run_tests.sh`](scripts/ci/run_tests.sh) (`GODOT_BIN=/path/to/godot ./scripts/ci/run_tests.sh`), or individually via Godot CLI:

```bash
cd <path-to-seproject>

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

# 6. Level 6: The Cat (3D Model Showcase) & Bonus Chamber (The Midnight Bridge)
godot --headless -s res://tests/TestLevel06Scene.gd
godot --headless -s res://tests/TestMidnightBridge.gd
godot --headless -s res://tests/TestLevel07Scene.gd

# 7. Global Navigation, UI & Player
godot --headless -s res://tests/TestMainMenu.gd
godot --headless -s res://tests/TestProgressStore.gd
godot --headless -s res://tests/TestJournal.gd
godot --headless -s res://tests/TestPlayerController.gd

# 8. Validate scene syntax without opening GUI
godot --headless --validate --quit scenes/ui/MainMenu.tscn
godot --headless --validate --quit scenes/ui/Journal.tscn
godot --headless --validate --quit scenes/player/Player.tscn
godot --headless --validate --quit scenes/props/Cat.tscn
godot --headless --validate --quit scenes/levels/Level01_Tutorial.tscn
godot --headless --validate --quit scenes/levels/Level02_NinePortals.tscn
godot --headless --validate --quit scenes/levels/Level03_SunCourtyard.tscn
godot --headless --validate --quit scenes/levels/Level04_KnightsChasm.tscn
godot --headless --validate --quit scenes/levels/Level05_DreadburyManor.tscn
godot --headless --validate --quit scenes/levels/Level06_Cat.tscn
godot --headless --validate --quit scenes/levels/Level07_MidnightBridge.tscn

# 9. Launch Godot game directly to test interactively
godot
```

---

## 💡 Important Tips & Gotchas
* **Model-View Separation:** Never put puzzle rules directly inside a 3D scene script. Always write the logic in `scripts/logic/` first with a matching test in `tests/`.
* **Testing without Display:** When running commands in headless/automated environments, always pass `--headless` to prevent window-manager blocking.
* **Branching & Issues:** Never develop directly on `main`. Sync `main`, create a feature/docs/fix branch, reference the corresponding GitHub Issue (`#1`–`#14`), and open a Pull Request (see [`AGENTS.md`](AGENTS.md)).
