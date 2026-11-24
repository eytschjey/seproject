# Software Requirements Specification (SRS) — SEProject

**Project:** SEProject — A 3D Logic Puzzle Adventure  
**Engine:** Godot Engine 4.x (Forward+ Renderer, Jolt 3D Physics, GDScript 2.0)  
**Source Material:** Prof. Dr. Karl Stroetmann, *Theoretical Computer Science: Logic & Puzzles*  
**Last Updated:** November 24, 2026

---

## 1. Introduction

### 1.1 Purpose
This document defines the functional and non-functional requirements for **SEProject**, an interactive 3D logic puzzle-adventure game built with Godot 4. It serves as the authoritative reference for implementation, automated verification, and future extensions.

### 1.2 Scope
SEProject transforms classical theoretical computer science puzzles—state-space search, propositional deduction, constraint satisfaction, graph traversal, and first-order logic—into interactive 3D chambers. The software includes:
- A startup **Main Menu** for level selection and navigation.
- **Five playable logic puzzle levels** (Levels 1–5), each backed by a pure headless GDScript logic engine, a 3D interactive view/controller, an animated debug auto-solver, and automated headless unit and integration tests.
- **One 3D asset pipeline showcase level** (Level 6: The Cat Sanctuary) demonstrating glTF 2.0 (`.glb`) inherited prefabs, skeletal animation, and 3D picking.
- A documented **backlog** for first-person movement, an in-game logic journal, full 3D asset replacement, and a Bonus Chamber (*The Midnight Bridge*).

### 1.3 Stakeholders & Roles
| Role | Description |
| :--- | :--- |
| **Player** | Interacts with 3D puzzles, inspects clues/plaques, solves riddles, and navigates between levels and the Main Menu. |
| **Developer / Contributor** | Implements headless logic models, 3D controllers, shaders/assets, and automated tests following project architecture standards. |
| **Evaluator / QA** | Runs headless test suites, uses debug auto-solvers to verify puzzle solvability, and validates scene integrity. |

### 1.4 Priority & Status Conventions
- **MoSCoW Priorities:** `Must` (core requirement), `Should` (important for completeness/UX), `Could` (future enhancement).
- **Status:** `Implemented` (verified by automated tests) or `Planned` (in project backlog).

---

## 2. Functional Requirements

### FR-01: Menu & Navigation System

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-01.1** | **Startup Main Menu:** The application shall launch into `MainMenu.tscn`, displaying all configured levels and enabling selection of every unlocked level. | Must | Implemented |
| **FR-01.2** | **Return to Menu:** Every playable level shall display a persistent `< Menu` button (`BackToMenuButton`) that returns the player to `MainMenu.tscn`. | Must | Implemented |
| **FR-01.3** | **Linear Auto-Progression:** Solving Levels 1–5 shall display a victory banner and automatically transition to the next level after a short delay (3 s after Level 1; 4 s after Levels 2–5). | Should | Implemented |
| **FR-01.4** | **Application Exit:** The Main Menu shall provide a `Quit` button that cleanly exits the application. | Must | Implemented |

---

### FR-02: Level 1 — The Ferryman's Crossing (*Wolf, Goat & Cabbage*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-02.1** | **Transport & Capacity Rules:** The logic engine (`RiverCrossingLogic`) shall track items (`WOLF`, `GOAT`, `CABBAGE`) on the West shore, East shore, or raft, allowing at most one item on the raft at a time. | Must | Implemented |
| **FR-02.2** | **Hazard Enforcement:** Leaving the Wolf and Goat together unsupervised, or the Goat and Cabbage together unsupervised, shall trigger a failure state (`puzzle_failed`) with an explanatory reason and disable further moves until reset. | Must | Implemented |
| **FR-02.3** | **Direct 3D One-Click Interaction:** Players shall click directly on 3D items to load, swap, or unload passengers with a single click, and click the 3D raft (or HUD `Row Raft` button) to cross the river, with hover scale and cursor feedback. | Must | Implemented |
| **FR-02.4** | **Victory & Reset:** Moving all three items safely to the East shore shall emit `puzzle_solved`. Pressing `Reset` shall restore all items and the raft to the West shore and clear any failure state. | Must | Implemented |
| **FR-02.5** | **BFS Auto-Solver:** The logic engine shall compute an optimal solution via Breadth-First Search (`find_solution()`), and the HUD shall provide a toggleable `Auto-Solve (Debug)` button that animates the solution step-by-step and can be paused or cancelled by user input. | Should | Implemented |

---

### FR-03: Level 2 — The Hall of Nine Portals (*Smullyan's Princess & Tiger*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-03.1** | **Royal Logic Protocol:** `NinePortalsLogic` shall enforce the protocol: a Tiger door's inscription is false, the Princess door's inscription is true, and all Empty room inscriptions are either all true or all false. | Must | Implemented |
| **FR-03.2** | **Randomized Replayable Layout:** On level start and after every reset, the room layout shall be randomized while dynamically remapping all 9 door inscriptions so that the Princess's room remains uniquely deducible (`princess_candidates(roles).size() == 1`). | Must | Implemented |
| **FR-03.3** | **Direct 3D Door Selection & Plaque Inspection:** Clicking any of the 9 doors directly in 3D shall select it, highlight its plaque and frame (gold for selected, warm amber for previously inspected), and display its inscription in the Plaque Panel. | Must | Implemented |
| **FR-03.4** | **Door Opening Outcomes:** Opening the Princess's door shall solve the puzzle; opening a Tiger door shall trigger a failure banner requiring Reset; opening an Empty room shall reveal an empty alcove and allow continued play. | Must | Implemented |
| **FR-03.5** | **Deductive Auto-Solver:** `solve_princess_room()` shall deduce the unique Princess room, and `Auto-Solve (Debug)` shall inspect plaques step-by-step before opening the deduced door. | Should | Implemented |

---

### FR-04: Level 3 — The Sun Courtyard (*The 8-Queens Problem*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-04.1** | **Board Placement:** `QueensLogic` shall manage an $8 \times 8$ board allowing placement, removal, and toggling of up to 8 queens. | Must | Implemented |
| **FR-04.2** | **Real-Time Conflict Detection & Optics:** Any two queens sharing a row, column, or diagonal shall be flagged as conflicting, turning their 3D statues crimson and rendering glowing crimson beams between attacking pairs; non-attacking statues shall glow gold. | Must | Implemented |
| **FR-04.3** | **Victory Condition:** Placing 8 queens with zero conflicts shall emit `puzzle_solved`, turn all statues green, and display the victory banner. | Must | Implemented |
| **FR-04.4** | **Completion Auto-Solver:** `QueensLogic` shall support enumerating all 92 solutions (`solve_all()`) and completing any valid partial board (`find_completion()`), driven by a toggleable `Auto-Solve (Debug)` button. | Should | Implemented |

---

### FR-05: Level 4 — The Knight's Chasm (*The Knight's Tour*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-05.1** | **Knight Move & Unvisited Constraints:** `KnightsTourLogic` shall start the knight on A1 `(0, 0)` and allow moves only to unvisited in-bounds tiles matching a chess knight's L-shaped offset (`(±1, ±2)` or `(±2, ±1)`). | Must | Implemented |
| **FR-05.2** | **3D Tile Sinking & Visual Guidance:** Leaving a tile shall sink it into the lava; valid next moves shall be highlighted both in 3D and on the 8x8 HUD grid; a live counter shall display `Visits: N / 64`. | Must | Implemented |
| **FR-05.3** | **Dead-End Detection & Undo Stack:** Reaching a state with no legal moves before 64 visits shall emit `puzzle_failed`. The player shall be able to undo jumps (`Undo Last Jump`) to raise previously sunken tiles and recover from dead ends. | Must | Implemented |
| **FR-05.4** | **Victory Condition:** Visiting all 64 tiles exactly once shall emit `puzzle_solved` and raise all tiles into a radiant bridge. | Must | Implemented |
| **FR-05.5** | **Warnsdorff Auto-Solver:** `KnightsTourLogic` shall compute complete 64-tile tours using Warnsdorff's heuristic (`find_tour()` / `find_tour_from_path()`), accessible via `Auto-Solve (Debug)`. | Should | Implemented |

---

### FR-06: Level 5 — The Night at Dreadbury Manor (*Who Killed Aunt Agatha?*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-06.1** | **First-Order Logic Model Checker:** `DreadburyLogic` shall formalize the 3 residents (`AGATHA`, `BUTLER`, `CHARLES`), 8 manor clues, and predicates (`killed`, `hates`, `richer_than_agatha`), exhaustively verifying that Aunt Agatha is the unique killer across all consistent models (`killer_candidates() == [Suspect.AGATHA]`). | Must | Implemented |
| **FR-06.2** | **Clue Investigation:** Players shall inspect all 8 clues, viewing each clue's title, location, narrative text, and formal first-order logic formula while tracking progress (`Clues Examined: N / 8`). | Must | Implemented |
| **FR-06.3** | **Accusation Altar & Dagger of Truth:** Players shall select a suspect bust and place the animated Dagger of Truth to submit an accusation. | Must | Implemented |
| **FR-06.4** | **Contradiction Feedback:** Accusing Charles or the Butler shall emit `puzzle_failed` with the formal logical contradiction (`contradiction_for()`) explaining why that suspect cannot be the killer. | Must | Implemented |
| **FR-06.5** | **Victory Reveal & Auto-Solver:** Accusing Aunt Agatha shall reveal the hidden 3D suicide note, transition the lighting from stormy night to morning sunlight, and emit `puzzle_solved`. An `Auto-Solve (Debug)` button shall examine all clues and solve the mystery. | Should | Implemented |

---

### FR-07: Level 6 — The Cat Sanctuary (*3D Asset Showcase*)

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-07.1** | **glTF 2.0 Prefab Showcase:** The scene shall instantiate an inherited prefab (`scenes/props/Cat.tscn`) sourced from `assets/models/characters/cat.glb` on a rotating turntable pedestal with a toggleable spin button. | Should | Implemented |
| **FR-07.2** | **Animation Playback:** The controller shall support toggling looped playback of the model's skeletal animation track (`Take 001`). | Should | Implemented |
| **FR-07.3** | **3D Picking Interaction:** Clicking the cat's 3D `ClickArea` or pressing `Pet Cat` shall trigger a hop animation, increment the pet counter, and display the `PURR-FECTION ACHIEVED` banner after 5 pets; `Reset` shall restore initial state. | Should | Implemented |

---

### FR-08: Planned / Backlog Functional Requirements

| ID | Requirement | Priority | Status |
| :--- | :--- | :--- | :--- |
| **FR-08.1** | **First-Person 3D Player Controller:** Implement a `CharacterBody3D` player (`Player.tscn`) with WASD movement, mouse look, jump, and a center-screen `RayCast3D` interacting with `Interactable3D` components via `[E]`. | Should | Planned |
| **FR-08.2** | **In-Game Logic Journal UI:** Implement a toggleable notebook (`[J]` / `[Tab]`) that logs discovered door inscriptions and clues, plus an optional deduction scratchpad matrix. | Should | Planned |
| **FR-08.3** | **Bonus Chamber — The Midnight Bridge:** Implement the *Bridge & Torch Problem* (4 travelers of speeds 1, 2, 5, and 8 minutes; 2-person bridge limit; strict 15-minute torch countdown) with headless logic, 3D scene, and tests. | Could | Planned |
| **FR-08.4** | **3D Asset Replacement:** Incrementally replace CSG greybox geometry across Levels 1–5 with `.glb` inherited prefabs while preserving node paths, collision pickers, and animation pivots. | Could | Planned |

---

## 3. Non-Functional Requirements

| ID | Category | Requirement | Verification Method |
| :--- | :--- | :--- | :--- |
| **NFR-01** | **Architecture** | **Strict Model-View Separation:** All puzzle rules, invariant checks, and solvers in `scripts/logic/` shall extend `RefCounted` (pure GDScript) with zero dependencies on 3D nodes, UI controls, or scene trees. | Code review & headless logic unit tests (`Test*.gd`). |
| **NFR-02** | **Testability** | **Automated Headless Verification:** Every logic model shall have a `SceneTree` unit test suite, and every level/menu scene shall have an automated headless integration test and pass `godot --headless --validate --quit`. | CI / CLI test execution (`0` failures). |
| **NFR-03** | **Usability & UI** | **Non-Overlapping & Subtle HUD:** No 2D HUD panel (`BackToMenuButton`, `HeaderPanel`, `SidePanel`, `Banner`, `ActionBar`) shall overlap another HUD label or critical 3D `Label3D` at standard `1152×648` (`canvas_items` / `expand`) resolution. Each scene shall use a distinct, muted, high-readability color palette. | Automated layout checks & integration tests (`TestLevel04Scene.gd`). |
| **NFR-04** | **Responsiveness** | **Smooth Interaction & Cancellation:** Animations (`Tween`) and auto-solver coroutines shall not freeze the UI thread, and any player click or reset shall immediately cancel active auto-solver loops safely via state guards. | Scene integration tests (`TestLevel01Scene.gd`–`TestLevel05Scene.gd`). |
| **NFR-05** | **Portability** | **Cross-Platform & Self-Contained Assets:** The project shall run on Godot 4.3+ (4.7.2 tested) on Linux, macOS, and Windows using Forward+ and Jolt Physics. 3D assets shall use self-contained `.glb` files with no runtime dependency on Blender or external DCC tools. | Headless import & validation on target OS. |
| **NFR-06** | **Maintainability** | **Documentation & Git Sync:** All code, scene, and test changes shall keep `README.md`, `HANDOVER.md`, `AGENTS.md`, and `docs/` synchronized and strictly follow the `git pull` -> verify -> `git commit` + `git push` workflow. | Repository inspection & git history. |

---

## 4. Requirements Traceability Matrix

| Requirement Group | Primary Implementation Files | Automated Verification | Status |
| :--- | :--- | :--- | :--- |
| **FR-01** (Menu & Nav) | `scenes/ui/MainMenu.tscn`, `scripts/ui/MainMenuController.gd`, `scripts/core/BackToMenuButton.gd` | `tests/TestMainMenu.gd`, `tests/TestLevel01Transition.gd` | Implemented |
| **FR-02** (Level 1) | `scripts/logic/RiverCrossingLogic.gd`, `scenes/levels/Level01_Tutorial.tscn`, `scripts/levels/Level01Controller.gd` | `tests/TestRiverCrossing.gd` (46), `tests/TestLevel01Scene.gd` (14) | Implemented |
| **FR-03** (Level 2) | `scripts/logic/NinePortalsLogic.gd`, `scenes/levels/Level02_NinePortals.tscn`, `scripts/levels/Level02Controller.gd` | `tests/TestNinePortals.gd` (30), `tests/TestLevel02Scene.gd` (21) | Implemented |
| **FR-04** (Level 3) | `scripts/logic/QueensLogic.gd`, `scenes/levels/Level03_SunCourtyard.tscn`, `scripts/levels/Level03Controller.gd` | `tests/TestQueens.gd` (29), `tests/TestLevel03Scene.gd` (15) | Implemented |
| **FR-05** (Level 4) | `scripts/logic/KnightsTourLogic.gd`, `scenes/levels/Level04_KnightsChasm.tscn`, `scripts/levels/Level04Controller.gd` | `tests/TestKnightsTour.gd` (26), `tests/TestLevel04Scene.gd` (18) | Implemented |
| **FR-06** (Level 5) | `scripts/logic/DreadburyLogic.gd`, `scenes/levels/Level05_DreadburyManor.tscn`, `scripts/levels/Level05Controller.gd` | `tests/TestDreadbury.gd` (39), `tests/TestLevel05Scene.gd` (15) | Implemented |
| **FR-07** (Level 6) | `scenes/props/Cat.tscn`, `scenes/levels/Level06_Cat.tscn`, `scripts/levels/Level06Controller.gd` | `tests/TestLevel06Scene.gd` (17) | Implemented |
| **FR-08** (Backlog) | `story/level_progression.md`, `HANDOVER.md` | Planned | Planned |
