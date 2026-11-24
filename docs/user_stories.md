# User Stories & Acceptance Criteria — SEProject

**Project:** SEProject — A 3D Logic Puzzle Adventure  
**Last Updated:** November 24, 2026

Each user story follows the agile format (**As a** `<role>`, **I want** `<capability>`, **so that** `<benefit>`) with testable **Given / When / Then** acceptance criteria and traceability to [`docs/requirements.md`](requirements.md).

---

## Epic 1: Navigation, Menu & Core HUD

### US-01: Select and Launch a Level from the Main Menu
- **Story:** As a **Player**, I want to see all available levels on the startup Main Menu and click any unlocked level, so that I can jump directly into the puzzle I want to play.
- **Related Requirements:** `FR-01.1`, `FR-01.4`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** the game launches, **When** `MainMenu.tscn` loads, **Then** Levels 1–6 are listed as enabled buttons alongside a `Quit` button.
  - **Given** I am on the Main Menu, **When** I click a level button, **Then** the corresponding 3D level scene loads immediately.
  - **Given** I am on the Main Menu, **When** I click `Quit`, **Then** the application exits cleanly.

### US-02: Return to the Main Menu from Any Level
- **Story:** As a **Player**, I want a visible `< Menu` button in every level, so that I can switch puzzles or exit at any time without restarting the game.
- **Related Requirements:** `FR-01.2`, `NFR-03`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I am inside any level (Levels 1–6), **When** I look at the top-left corner, **Then** a `< Menu` button is visible at `(16, 16)` without overlapping the header panel.
  - **Given** I click `< Menu`, **When** the action completes, **Then** the game returns to `MainMenu.tscn`.

### US-03: Seamless Progression Between Levels
- **Story:** As a **Player**, I want the game to celebrate my victory and automatically advance me to the next chamber after solving a puzzle, so that the adventure feels continuous.
- **Related Requirements:** `FR-01.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I solve Level 1, 2, 3, 4, or 5, **When** the victory condition is met, **Then** a victory banner appears announcing the next chamber and automatically loads the next level after 3–4 seconds.

### US-04: Readable, Non-Overlapping, Subtle HUD
- **Story:** As a **Player**, I want each level's HUD to have subtle, atmospheric colors that stay legible without overlapping status labels or 3D scene labels, so that I can focus on solving the riddle.
- **Related Requirements:** `NFR-03`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I play any level at standard aspect ratio (`1152×648` with `expand`), **When** the HUD renders, **Then** `SidePanel` never overlaps `HeaderPanel` or `StatusLabel`, `BackToMenuButton` never overlaps `HeaderPanel`, and notification banners do not obscure 3D `Label3D` plaques.
  - **Given** I move between levels, **When** each scene loads, **Then** each level displays its own subtle, muted thematic color scheme with clear text contrast.

---

## Epic 2: Level 1 — The Ferryman's Crossing (*Wolf, Goat & Cabbage*)

### US-05: Load, Swap, and Unload Passengers with One 3D Click
- **Story:** As a **Player**, I want to click directly on the 3D Wolf, Goat, or Cabbage to load, swap, or unload them onto the raft, so that interacting with the puzzle feels tactile and intuitive.
- **Related Requirements:** `FR-02.1`, `FR-02.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** the raft is on the same shore as an item, **When** I click that 3D item once, **Then** it hops onto the raft (and if another item is already on the raft, the previous item automatically hops back onto the shore).
  - **Given** an item is currently on the raft, **When** I click that 3D item once, **Then** it unloads back onto the current shore without rowing the raft.
  - **Given** I hover over a clickable 3D item or the raft, **When** the pointer enters its hitbox, **Then** the cursor changes to a pointing hand and the object subtly scales up.

### US-06: Row the Raft and Receive Clear Hazard Feedback
- **Story:** As a **Player**, I want to row the raft across the river by clicking the raft or the `Row Raft` button and be warned if I leave conflicting animals/items unsupervised, so that I understand the puzzle constraints.
- **Related Requirements:** `FR-02.2`, `FR-02.3`, `FR-02.4`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** the raft is on a shore, **When** I click the raft or press `Row Raft`, **Then** the raft smoothly tweens to the opposite shore carrying any loaded passenger.
  - **Given** I row away leaving Wolf+Goat or Goat+Cabbage alone on a shore, **When** the crossing is evaluated, **Then** a failure banner explains what was eaten and prompts me to press `Reset`.
  - **Given** all three items reach the East shore safely, **When** the final item is unloaded, **Then** the puzzle is marked solved and transitions to Level 2.

### US-07: Reset or Watch the BFS Auto-Solver in Level 1
- **Story:** As a **Player or Evaluator**, I want to reset Level 1 or toggle an automated BFS solver, so that I can retry after a mistake or verify the optimal 7-crossing solution.
- **Related Requirements:** `FR-02.4`, `FR-02.5`, `NFR-04`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** any board state (including failure), **When** I press `Reset`, **Then** all items and the raft return to the West shore and controls are re-enabled.
  - **Given** I press `Auto-Solve (Debug)`, **When** the solver runs, **Then** it executes optimal load/cross/unload steps automatically, and clicking `Stop Solver` or any 3D object pauses it immediately.

---

## Epic 3: Level 2 — The Hall of Nine Portals (*Princess & Tiger*)

### US-08: Inspect Door Inscriptions by Clicking 3D Doors
- **Story:** As a **Player**, I want to click any of the 9 doors directly in the 3D hall to read its etched plaque, so that I can gather the logical statements needed to deduce the Princess's room.
- **Related Requirements:** `FR-03.1`, `FR-03.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I am in the Hall of Nine Portals, **When** I click a 3D door, **Then** its plaque inscription is displayed in `PlaquePanel`, the selected door's plaque and frame glow gold, and `Open Door N` becomes enabled.
  - **Given** I click a different door, **When** the selection changes, **Then** the previously inspected door's plaque remains subtly highlighted in warm amber so I know I already read it.

### US-09: Replay with Randomized Room Layouts
- **Story:** As a **Player**, I want the Princess, Tigers, and Empty rooms to be randomized on start and reset with matching remapped inscriptions, so that I cannot simply memorize a single fixed door number.
- **Related Requirements:** `FR-03.2`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I start or reset Level 2, **When** the hall initializes, **Then** the room contents are permuted, all 9 inscriptions are dynamically remapped to reference the new room numbers, and exactly one room is logically deducible as the Princess's room.

### US-10: Open a Selected Door and Experience the Outcome
- **Story:** As a **Player**, I want to open my chosen door and see the 3D door swing open to reveal a Princess, a Tiger, or an Empty vault, so that my deduction has dramatic physical feedback.
- **Related Requirements:** `FR-03.4`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I select a door and press `Open Door N`, **When** it contains a Tiger, **Then** the door swings open to reveal the tiger, red light illuminates the alcove, and a failure banner instructs me to press `Reset`.
  - **Given** I open an Empty room, **When** the door swings open, **Then** dust/empty vault props appear and I can continue inspecting and opening remaining doors.
  - **Given** I open the Princess's door, **When** the door swings open, **Then** the Princess glows gold and the victory banner triggers progression to Level 3.

### US-11: Run the Deductive Auto-Solver in Level 2
- **Story:** As an **Evaluator**, I want an `Auto-Solve (Debug)` button in Level 2, so that I can verify that the randomized layout is always solvable and watch the solver open the correct door.
- **Related Requirements:** `FR-03.5`, `NFR-04`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I press `Auto-Solve (Debug)`, **When** the solver runs, **Then** it steps through uninspected plaques, deduces the unique Princess room, and opens that door to solve the level.

---

## Epic 4: Level 3 — The Sun Courtyard (*The 8-Queens Problem*)

### US-12: Place and Remove Queen Statues on the 8x8 Courtyard
- **Story:** As a **Player**, I want to toggle Queen statues on an 8x8 grid and see them drop onto the 3D marble board, so that I can experiment with non-attacking configurations.
- **Related Requirements:** `FR-04.1`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** fewer than 8 queens are placed, **When** I click an empty cell on the 8x8 grid, **Then** a 3D Queen statue spawns on the corresponding marble tile and the counter increments (`Queens: N / 8`).
  - **Given** a cell already holds a queen, **When** I click it again, **Then** the statue is removed and the counter decrements.

### US-13: See Real-Time Conflict Beams Between Attacking Queens
- **Story:** As a **Player**, I want attacking queens to turn crimson and project laser beams between each other, so that I can immediately spot row, column, and diagonal conflicts.
- **Related Requirements:** `FR-04.2`, `FR-04.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** two queens share a row, column, or diagonal, **When** placed, **Then** both statues turn crimson, a glowing crimson 3D beam links them, and their HUD cells highlight in muted terracotta-red.
  - **Given** I remove the conflicting queen, **When** no attacks remain, **Then** the beam disappears and safe queens glow gold.
  - **Given** 8 queens are placed with zero conflicts, **When** the 8th queen lands, **Then** all statues turn green and the victory banner transitions to Level 4.

### US-14: Complete or Solve 8-Queens Automatically
- **Story:** As a **Player or Evaluator**, I want an `Auto-Solve (Debug)` button that completes my valid partial placement (or resets and solves from scratch if uncompletable), so that I can test the 8-Queens constraint solver.
- **Related Requirements:** `FR-04.4`, `NFR-04`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I press `Auto-Solve (Debug)`, **When** the solver runs, **Then** it places queens step-by-step until a valid 8-queen solution is reached; pressing `Stop Solver` pauses placement immediately.

---

## Epic 5: Level 4 — The Knight's Chasm (*The Knight's Tour*)

### US-15: Leap Across Floating Rune Tiles Using Legal Knight Moves
- **Story:** As a **Player**, I want valid knight jumps to be clearly highlighted while visited tiles crumble into the lava behind me, so that I can navigate the 64-tile chasm accurately.
- **Related Requirements:** `FR-05.1`, `FR-05.2`, `FR-05.4`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** the knight is on a tile, **When** I view the 3D board and HUD grid, **Then** only legal unvisited knight-move cells are enabled and highlighted in steel-blue, while the current tile is highlighted in ochre-gold.
  - **Given** I click a valid destination cell, **When** the knight jumps, **Then** the 3D knight arcs to the new tile, the previous tile sinks into the lava, and the counter updates (`Visits: N / 64`).
  - **Given** I reach `64 / 64` visits, **When** the final jump completes, **Then** all 64 tiles rise into a glowing bridge and the level advances to Level 5.

### US-16: Undo Jumps and Recover from Dead Ends
- **Story:** As a **Player**, I want to undo my previous jumps if I trap myself in a dead end, so that I can backtrack without restarting the entire 64-tile tour.
- **Related Requirements:** `FR-05.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I have made at least one jump, **When** I press `Undo Last Jump`, **Then** the knight returns to the previous tile, that tile rises back out of the lava, and the visit counter decrements.
  - **Given** no legal moves remain before 64 visits, **When** the dead end occurs, **Then** a failure banner notifies me to undo a jump or press `Reset`.

### US-17: Watch the Warnsdorff-Heuristic Auto-Solver Complete the Tour
- **Story:** As an **Evaluator**, I want an `Auto-Solve (Debug)` button in Level 4, so that I can verify that the 64-tile Knight's Tour completes cleanly from the current path or from A1.
- **Related Requirements:** `FR-05.5`, `NFR-04`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I press `Auto-Solve (Debug)`, **When** the solver runs, **Then** the knight executes a complete 64-tile tour step-by-step, with full pause/resume support via `Stop Solver`.

---

## Epic 6: Level 5 — The Night at Dreadbury Manor (*Who Killed Aunt Agatha?*)

### US-18: Examine Manor Clues and Formal Logic Formulas
- **Story:** As a **Player**, I want to inspect all 8 documentary clues in the manor and see both their narrative statements and first-order logic formulas, so that I can deduce who killed Aunt Agatha.
- **Related Requirements:** `FR-06.1`, `FR-06.2`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I click any clue button (`1..8`), **When** inspected, **Then** `CluePanel` displays the clue's title, location, text, and formal FOL formula, the button is marked with `✓`, the 3D clue scroll changes color, and `Clues Examined: N / 8` updates.

### US-19: Accuse a Suspect and See Logical Contradictions on Mistakes
- **Story:** As a **Player**, I want to select a suspect bust and place the Dagger of Truth, receiving a clear logical contradiction if I accuse the wrong person, so that I learn why my deduction failed.
- **Related Requirements:** `FR-06.3`, `FR-06.4`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** no suspect is selected, **When** I view the Altar controls, **Then** `Place Dagger of Truth` is disabled.
  - **Given** I select Charles or the Butler and place the dagger, **When** evaluated, **Then** the dagger plunges onto the bust, the bust turns red, and the failure banner explains the exact logical contradiction (`contradiction_for()`).

### US-20: Solve the Mystery and Trigger the Finale
- **Story:** As a **Player**, I want accusing Aunt Agatha to reveal her hidden suicide note and clear the storm, so that the mystery concludes satisfyingly.
- **Related Requirements:** `FR-06.5`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** I select Aunt Agatha and place the Dagger of Truth (manually or via `Auto-Solve (Debug)`), **When** evaluated, **Then** the hidden 3D suicide note becomes visible, lighting shifts from storm blue to morning sunlight, and the victory banner announces the resolution.

---

## Epic 7: Level 6 — The Cat Sanctuary & 3D Asset Pipeline

### US-21: Interact with the 3D Cat Exhibit
- **Story:** As a **Player**, I want to spin, animate, and pet the 3D cat model in Level 6, so that I can enjoy the interactive 3D showcase after finishing the main logic campaign.
- **Related Requirements:** `FR-07.1`, `FR-07.2`, `FR-07.3`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** Level 6 loads, **When** I click `Pause Spin` / `Resume Spin`, **Then** the turntable rotation toggles accordingly.
  - **Given** I click `Play Animation` / `Pause Animation`, **Then** the cat's skeletal animation (`Take 001`) toggles playback.
  - **Given** I click the 3D cat or press `Pet Cat` 5 times, **When** the 5th pet occurs, **Then** the cat hops on each pet and the `PURR-FECTION ACHIEVED` banner appears.

### US-22: Replace Greybox Meshes with Inherited `.glb` Prefabs
- **Story:** As a **Developer**, I want to import `.glb` models as inherited `.tscn` prefabs under `scenes/props/` while keeping exact node names and `ClickArea` / `Marker3D` children, so that visual upgrades never break controllers or automated tests.
- **Related Requirements:** `FR-08.4`, `NFR-05`
- **Status:** Planned (Pipeline established in Level 6; Levels 1–5 pending)
- **Acceptance Criteria:**
  - **Given** a new `.glb` asset is added under `assets/models/` and wrapped in `scenes/props/<Prop>.tscn`, **When** swapped into a level scene, **Then** `godot --headless --validate --quit` and all existing unit/integration tests pass without controller modifications.

---

## Epic 8: Developer & QA Engineering Experience

### US-23: Run Headless Unit Tests for Pure Puzzle Logic
- **Story:** As a **Developer**, I want to run automated headless tests for every puzzle logic class from the command line, so that I can verify mathematical correctness without opening the Godot Editor.
- **Related Requirements:** `NFR-01`, `NFR-02`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** a headless environment without a GPU/display, **When** I run `godot --headless -s res://tests/Test<Logic>.gd`, **Then** all assertions execute and exit with code `0` on success or `1` on failure.

### US-24: Validate 3D Scenes and UI Flows Headlessly
- **Story:** As a **QA / Developer**, I want automated scene integration tests and syntax validation commands for all levels, so that broken node paths, missing resources, or UI regressions are caught before pushing.
- **Related Requirements:** `NFR-02`, `NFR-06`
- **Status:** Implemented
- **Acceptance Criteria:**
  - **Given** any change to a `.tscn` or controller `.gd` file, **When** I run `godot --headless --validate --quit <scene>` and `godot --headless -s res://tests/TestLevel0XScene.gd`, **Then** the scene loads with zero errors and all integration checks pass.

---

## Epic 9: Planned Future Enhancements (Backlog)

### US-25: Explore Chambers in First-Person 3D
- **Story:** As a **Player**, I want to walk through the 3D chambers in first-person using WASD and mouse look and press `[E]` to interact with plaques, levers, and statues, so that the game feels like an immersive 3D adventure.
- **Related Requirements:** `FR-08.1`
- **Status:** Planned
- **Acceptance Criteria:**
  - **Given** `Player.tscn` is active in a level, **When** I move with WASD, look with the mouse, and aim at an `Interactable3D`, **Then** a contextual prompt (e.g. `[E] Inspect Plaque`) appears and pressing `E` triggers the interaction.

### US-26: Track Deductions in an In-Game Logic Journal
- **Story:** As a **Player**, I want to open an in-game Journal with `[J]` or `[Tab]` that automatically logs every plaque and clue I have discovered, so that I can cross-reference logical statements without pen and paper.
- **Related Requirements:** `FR-08.2`
- **Status:** Planned
- **Acceptance Criteria:**
  - **Given** I have inspected door plaques in Level 2 or clues in Level 5, **When** I press `J` or `Tab`, **Then** the Journal overlay opens displaying all discovered entries and an optional deduction scratchpad.

### US-27: Play the Bonus Chamber — The Midnight Bridge
- **Story:** As a **Player**, I want to play an optional Bonus Chamber based on the *Bridge & Torch Problem*, so that I can test my time-constrained resource planning skills against a 15-minute torch limit.
- **Related Requirements:** `FR-08.3`
- **Status:** Planned
- **Acceptance Criteria:**
  - **Given** four travelers with crossing times 1, 2, 5, and 8 minutes, **When** I escort pairs across the bridge with the torch, **Then** the elapsed time increments by the slower traveler's speed, exceeding 15 minutes fails the puzzle, and crossing all four in $\le 15$ minutes solves it.
