# SEProject: A 3D Logic Puzzle Adventure

A first-person / third-person 3D puzzle-adventure game built with **Godot 4**, where classical theoretical computer science logic riddles are brought to life through interactive physical environments.

---

## 🚦 Current Project Status

- [x] **Project Foundation:** Godot 4 configured with Forward+ rendering, Jolt 3D Physics, and standard input map bindings (WASD, Space, Interact, Reset, Journal).
- [x] **Design & Source Extraction:** All 21 logic riddles extracted from course notes ([`story/logical_riddles.md`](story/logical_riddles.md)) and full 5-level progression mapped ([`story/level_progression.md`](story/level_progression.md)).
- [x] **Level 1 Logic Engine:** Headless state machine ([`scripts/logic/RiverCrossingLogic.gd`](scripts/logic/RiverCrossingLogic.gd)) verifying state constraints and transitions (41 automated assertions passing).
- [x] **Level 1 3D Prototype:** Functional 3D greybox scene ([`scenes/levels/Level01_Tutorial.tscn`](scenes/levels/Level01_Tutorial.tscn)) with dynamic lighting, smooth item hops, raft movement tweening, and full interactive UI.
- [x] **Integration Testing:** Headless UI test ([`tests/TestLevel01Scene.gd`](tests/TestLevel01Scene.gd)) simulating complete 7-step solution sequence and visual tracking.
- [x] **Level 2 (Hall of Nine Portals):** Headless logic ([`NinePortalsLogic.gd`](scripts/logic/NinePortalsLogic.gd)), 25 unit assertions ([`TestNinePortals.gd`](tests/TestNinePortals.gd)), button-driven 3D scene ([`Level02_NinePortals.tscn`](scenes/levels/Level02_NinePortals.tscn)) and integration test ([`TestLevel02Scene.gd`](tests/TestLevel02Scene.gd)).
- [x] **Level 3 (Sun Courtyard):** Headless logic ([`QueensLogic.gd`](scripts/logic/QueensLogic.gd), 27 assertions in [`TestQueens.gd`](tests/TestQueens.gd)), 3D board scene ([`Level03_SunCourtyard.tscn`](scenes/levels/Level03_SunCourtyard.tscn)) and [`TestLevel03Scene.gd`](tests/TestLevel03Scene.gd).
- [x] **Level 4 (Knight's Chasm):** Headless logic ([`KnightsTourLogic.gd`](scripts/logic/KnightsTourLogic.gd), 26 assertions in [`TestKnightsTour.gd`](tests/TestKnightsTour.gd)), 3D lava cavern scene ([`Level04_KnightsChasm.tscn`](scenes/levels/Level04_KnightsChasm.tscn)) and [`TestLevel04Scene.gd`](tests/TestLevel04Scene.gd).
- [x] **Main Menu:** Level select screen ([`MainMenu.tscn`](scenes/ui/MainMenu.tscn), now the startup scene) with a "< Menu" button in each level.
- [ ] **Next Up:** First-person character navigation, journal UI, Level 5 (Dreadbury Manor).

---

## 📖 Premise

Rather than solving abstract logic puzzles on paper or through 2D menus, players explore a stylized 3D world where each chamber is built around a distinct mathematical puzzle from Prof. Dr. Karl Stroetmann's *Theoretical Computer Science: Logic & Puzzles*. Players manipulate the environment—pushing statues, navigating collapsing stone tiles, rowing rafts, and gathering detective evidence—to satisfy logical constraints and unlock passage to the next area.

---

## 🗺️ Level Progression & Riddle Mechanics

| Level | Puzzle Source | Setting | Core Gameplay Mechanic | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Level 1: The Ferryman's Crossing** | *Wolf, Goat & Cabbage* (Ch. 5, Ex. 19) | Misty Riverbank & Dock | **Tutorial & Raft Physics:** Transporting items one by one across a river, checking state constraints to prevent items from being eaten. | **Playable Prototype** |
| **Level 2: The Hall of Nine Portals** | *Smullyan’s Princess & Tiger* (Ch. 4, Ex. 13) | Palace Throne Corridor | **Propositional Deduction:** 9 doors with etched inscriptions. Avoid lethal tiger traps by reasoning about truth and deception. | **Playable Prototype** |
| **Level 3: The Sun Courtyard** | *The 8-Queens Problem* (Ch. 4, §4.8.1) | Romanesque Checkered Courtyard | **Spatial Placement & Optics:** Moving 8 queen statues that project light beams. Conflicting beams glow red until a non-attacking configuration is reached. | **Playable Prototype** |
| **Level 4: The Knight's Chasm** | *The Knight's Tour* (Ch. 5, §5.6.2) | Subterranean Lava Cavern | **Platforming & Pathfinding:** Leaping across an $8 \times 8$ grid of floating stone runes using only chess knight ($L$-shaped) moves; visited tiles crumble. | **Playable Prototype** |
| **Level 5: Dreadbury Manor** | *Who Killed Aunt Agatha?* (Ch. 6, §6.5.2) | Stormy Victorian Mansion | **Detective Investigation:** Interrogating suspects (Charles & the Butler), collecting written clues, and proving the truth at an accusation altar. | Planned |
| **Bonus: The Midnight Bridge** | *Bridge & Torch Problem* (Ch. 5, Ex. 25) | Dark Ravine Rope Bridge | **Resource & Time Management:** Guiding 4 characters of differing speeds across a swaying bridge before a 15-minute torch burns out. | Planned |

Full game design specifications and exact riddle texts are located in [`story/level_progression.md`](story/level_progression.md).

---

## 📁 Repository Structure

```text
seproject/
├── story/                         # Game narrative, design docs & logic source material
│   ├── logic.pdf                  # "Theoretical Computer Science: Logic & Puzzles" (K. Stroetmann)
│   ├── logical_riddles.md         # Full catalog of 21 extracted logic puzzles & mathematical formulas
│   └── level_progression.md       # Detailed Game Design Document (GDD) with Godot 3D mechanics
│
├── scenes/
│   ├── ui/
│   │   └── MainMenu.tscn          # Level select (startup scene)
│   └── levels/
│       ├── Level01_Tutorial.tscn  # Playable 3D greybox scene for Level 1 
│       ├── Level02_NinePortals.tscn # Playable 3D greybox scene for Level 2
│       ├── Level03_SunCourtyard.tscn # Playable 3D greybox scene for Level 3
│       └── Level04_KnightsChasm.tscn # Playable 3D greybox scene for Level 4
│
├── scripts/
│   ├── core/
│   │   └── BackToMenuButton.gd    # "< Menu" HUD button
│   ├── ui/
│   │   └── MainMenuController.gd  # Level select logic
│   ├── levels/
│   │   ├── Level01Controller.gd   # 3D visuals & UI controller for Level 1
│   │   ├── Level02Controller.gd   # 3D visuals & UI controller for Level 2
│   │   ├── Level03Controller.gd   # 3D visuals & UI controller for Level 3
│   │   └── Level04Controller.gd   # 3D visuals & UI controller for Level 4
│   └── logic/
│       ├── RiverCrossingLogic.gd  # Headless rules validator for Wolf, Goat & Cabbage
│       ├── NinePortalsLogic.gd    # Headless rules & solver for the Nine Portals
│       ├── QueensLogic.gd         # Headless rules & solver for 8-Queens
│       └── KnightsTourLogic.gd    # Headless rules & solver for Knight's Tour
│
├── tests/
│   ├── TestRiverCrossing.gd       # Unit tests for pure logic rules (41 assertions)
│   ├── TestLevel01Scene.gd        # Integration test for 3D UI & solution playback
│   ├── TestMainMenu.gd            # Menu lists levels, loads them, back button works
│   ├── TestLevel01Transition.gd   # Level 1 win auto-advances to Level 2
│   ├── TestNinePortals.gd         # Unit tests for Nine Portals logic (25 assertions)
│   ├── TestLevel02Scene.gd        # Integration test for Level 2 UI
│   ├── TestQueens.gd              # Unit tests for 8-Queens logic (27 assertions)
│   ├── TestLevel03Scene.gd        # Integration test for Level 3 UI
│   ├── TestKnightsTour.gd         # Unit tests for Knight's Tour logic (26 assertions)
│   └── TestLevel04Scene.gd        # Integration test for Level 4 UI
│
├── project.godot                  # Godot 4.x project configuration & input maps
├── icon.svg                       # Default project icon
├── .editorconfig                  # Formatting configurations
├── .gitignore                     # Git ignore rules (.godot/, etc.)
└── README.md                      # Project documentation & status
```

---

## ⚙️ Technical Specifications

* **Engine:** Godot Engine 4.x (Forward+ Renderer)
* **Physics Engine:** Jolt 3D Physics (`3d/physics_engine="Jolt Physics"`)
* **Aspect Ratio:** Canvas items stretch with expand mode (`canvas_items` / `expand`)
* **Architecture Pattern:** Decoupled Model-View-Controller:
  * **Model:** Pure GDScript classes validating puzzle rules and constraints (e.g. `RiverCrossingLogic.gd`).
  * **View / Controller:** 3D nodes (`CSGBox3D`, `CSGSphere3D`, `Tween`) and UI handling animations, user input, and feedback.

---

## 🧪 Running Tests

You can run automated tests either directly in the Godot Editor or headlessly via terminal:

### Pure Logic Unit Tests:
```bash
godot --headless -s res://tests/TestRiverCrossing.gd
```

### Full Scene & UI Integration Test:
```bash
godot --headless -s res://tests/TestLevel01Scene.gd
```

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/eytschjey/seproject.git
   cd seproject
   ```
2. Open **Godot Engine 4.x** (v4.3+ recommended).
3. Click **Import**, navigate to this directory, and select `project.godot`.
4. Press **Play** ($\blacktriangleright$ or `F5`) to launch the playable Level 1 prototype.
