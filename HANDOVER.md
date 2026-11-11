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
   * Main startup scene set to `res://scenes/levels/Level01_Tutorial.tscn`.
3. **Level 1 (The Ferryman's Crossing - Wolf, Goat & Cabbage):**
   * **Headless Logic:** [`scripts/logic/RiverCrossingLogic.gd`](scripts/logic/RiverCrossingLogic.gd) enforces river crossing rules, hazard checks (wolf/goat and goat/cabbage), and victory detection.
   * **Automated Unit Tests:** [`tests/TestRiverCrossing.gd`](tests/TestRiverCrossing.gd) runs 41 automated assertions headlessly via Godot CLI.
   * **Playable 3D Greybox Scene:** [`scenes/levels/Level01_Tutorial.tscn`](scenes/levels/Level01_Tutorial.tscn) with animated raft tweens, smooth item hops, lighting, and an interactive HUD.
   * **Scene Controller:** [`scripts/levels/Level01Controller.gd`](scripts/levels/Level01Controller.gd) connects UI and 3D node positions to logic signals. Bug fixes applied: Reset now re-enables controls properly, and carried items follow raft translation on every frame.
   * **Integration Test:** [`tests/TestLevel01Scene.gd`](tests/TestLevel01Scene.gd) simulates real button presses through the full 7-step solution and validates that items reach the East shore.

---

## 🚀 Immediate Next Tasks (Prioritized Backlog)

### Task 1: Level 2 — The Hall of Nine Portals (High Priority)
* **Source:** Raymond Smullyan's Princess and Tiger puzzle ([`story/logical_riddles.md`](story/logical_riddles.md#6-the-trial-of-the-nine-portals) & [`story/level_progression.md`](story/level_progression.md#level-2-the-hall-of-nine-portals-high-stakes-deduction)).
* **Sub-tasks:**
  1. Create headless logic class `scripts/logic/NinePortalsLogic.gd`:
     - Model 9 doors, each containing either `PRINCESS`, `TIGER`, or `EMPTY`.
     - Evaluate the 9 inscriptions against the truth protocol (Tiger = False, Princess = True, Empty = all True or all False).
     - Provide validation methods to check if an assignment of room contents is mathematically consistent.
  2. Create test script `tests/TestNinePortals.gd`:
     - Prove via unit tests which room uniquely holds the Princess.
  3. Create 3D scene `scenes/levels/Level02_NinePortals.tscn`:
     - Build a corridor with 9 identical doors and engraved plaques.
     - Allow the player to inspect each plaque and choose a door to open.
     - Include opening animations: Tiger jump scare/trap, empty room dust cloud, or radiant Princess portal.

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

### Task 4: Level 3 — The Sun Courtyard (8-Queens) (Future)
* **Source:** 8-Queens puzzle with physical movable statues projecting light/laser beams across an $8 \times 8$ marble courtyard. Conflicting beams turn red until a valid non-attacking configuration is reached.

---

## 🔧 Essential Commands for Testing & Validation

All tests can be executed directly in the terminal via Godot CLI:

```bash
cd "/Users/jan/Desktop/Software Engineering/seproject"

# 1. Run Level 1 logic unit tests (41 assertions)
godot --headless -s res://tests/TestRiverCrossing.gd

# 2. Run Level 1 UI integration test (full solution sequence)
godot --headless -s res://tests/TestLevel01Scene.gd

# 3. Validate scene syntax without opening GUI
godot --headless --validate --quit scenes/levels/Level01_Tutorial.tscn

# 4. Launch Godot game directly to test interactively
godot
```

---

## 💡 Important Tips & Gotchas
* **Model-View Separation:** Never put puzzle rules directly inside a 3D scene script. Always write the logic in `scripts/logic/` first with a matching test in `tests/`.
* **Testing without Display:** When running commands on macOS via automated environments, always pass `--headless` to prevent window-manager blocking.
* **Working Directory:** All project work lives under `/Users/jan/Desktop/Software Engineering/seproject`.
