# AGENTS.md — Agent & Contributor Guidelines

Welcome, AI Agent or developer! This repository houses **SEProject**, an atmospheric 3D logic adventure game built in **Godot 4** where theoretical computer science puzzles and deduction riddles are turned into interactive 3D mechanics.

---

## 🛠️ Tech Stack & Engine Configuration

- **Engine:** Godot Engine 4.x (`4.7.2.stable.official` or compatible 4.3+).
- **Renderer:** `Forward Plus` (Vulkan-based, modern lighting, shadows, volumetric fog).
- **Physics Engine:** `Jolt Physics` (`3d/physics_engine="Jolt Physics"`).
- **Display Scaling:** `window/stretch/mode="canvas_items"`, `window/stretch/aspect="expand"`.
- **Primary Language:** GDScript 2.0 (strictly typed).
- **Default Main Scene:** `res://scenes/ui/MainMenu.tscn`.

---

## 🏛️ Core Architecture Principles

### 1. Strict Model-View Separation (Headless-First)
- **Model (`scripts/logic/`):**
  - Pure GDScript classes extending `RefCounted` (or `Node` if tree integration is required).
  - Must have **zero dependencies on 3D nodes, meshes, or visuals**.
  - All game rules, invariant checks, state transitions, win conditions, fail conditions, and mathematical solvers (e.g. backtracking solvers, constraint evaluators) belong here.
  - State changes must emit signals: `state_changed`, `puzzle_failed(reason)`, `puzzle_solved`.
- **View / Controller (`scenes/levels/` & `scripts/levels/`):**
  - Responsible only for presentation, animations, tweening, and forwarding user inputs.
  - Listens to signals from the headless logic model.
  - Never mutates puzzle rules directly; always calls methods on the logic instance (`load_item()`, `place_queen()`, `move_to()`, etc.).
  - Debug tools (such as automated solvers) animate the view step-by-step by feeding solver steps through public logic methods.

### 2. Rapid 3D Prototyping (Greybox First)
- Do not block development waiting for finished 3D meshes or external art.
- Use Godot's built-in CSG nodes (`CSGBox3D`, `CSGSphere3D`, `CSGCylinder3D`) with standard materials for rapid prototyping.
- Keep coordinate references organized via `Marker3D` nodes rather than hardcoded vectors.
- **Camera Framing & Non-Overlapping HUD Layout:** When a level uses an expanded aspect ratio (`window/stretch/aspect="expand"`) with a right-hand HUD `SidePanel`:
  - Pull the camera back, elevate it, and angle downward (e.g. `y ~ 14`, `z ~ 9.5`, `pitch ~ -55°`, `fov ~ 46°`) so the near edge of the board is not clipped by the bottom of the window and the right edge does not collide with the side panel.
  - Keep `BackToMenuButton` at `(16, 16)`, start `HeaderPanel` at `offset_left = 112.0`, and cap `HeaderPanel` at `offset_right = -408.0` whenever a right-hand `SidePanel` (`offset_left = -392.0`) is present so `SidePanel` never overlaps `HeaderPanel` or `StatusLabel`. Each level and the Main Menu has its own distinct thematic `StyleBoxFlat` color scheme.

### 3. Automated Headless Verification
- Every logic puzzle **must have a corresponding automated test script** in `tests/`.
- Tests extend `SceneTree` so they can be run in CI or from the command line without opening windows.
- Run tests with:
  ```bash
  godot --headless -s res://tests/<TestScript>.gd
  ```
- Before pushing or concluding tasks, always validate scenes with:
  ```bash
  godot --headless --validate --quit scenes/levels/<SceneName>.tscn
  ```

### 4. Documentation & Git Synchronization
- **Always update the markdown files (`README.md`, `HANDOVER.md`, `AGENTS.md`, and `story/level_progression.md` when applicable) whenever making code, scene, or test changes** so documentation stays in lockstep with the codebase.
- **Git Workflow:** Always run `git pull` before making any changes, and `git commit` + `git push` after completing and verifying changes.

### 5. 3D Asset Pipeline & Greybox Replacement Standards
- **Standard Format:** Use **glTF 2.0 Binary (`.glb`)** exclusively under `assets/models/`. Self-contained `.glb` files package PBR textures, meshes, and materials without requiring external DCC software (e.g. Blender) during headless test runs or CI builds.
- **Prefabs via Inherited Scenes (`scenes/props/`):** Never drag raw `.glb` files directly into master level scenes. Always create an **Inherited Scene** (`scenes/props/<PropName>.tscn`) from the imported `.glb`. This allows configuring `Area3D` collision shapes, scripts, and material overrides that remain intact when re-exporting updated 3D meshes.
- **Node Hierarchy & Identifier Stability:** When replacing CSG shapes with meshes, preserve exact node names (e.g. `$Items/Wolf`, `$Environment/Raft`, `$Doors/Door1`, `$Board/Knight`) and retain all child `Marker3D` attachment slots, `Hinge` rotation pivots, and `Area3D` click pickers. Controllers and tests rely on these exact node paths.
- **Dynamic Spawners:** For pieces spawned at runtime (e.g. queen statues in Level 3, knight piece in Level 4, suspect busts in Level 5), preload the prefab (`const PropScene = preload(...)`) and instantiate it, applying material overrides for state changes (such as safe vs conflict coloring).
- **Import Suffixes:** Leverage Godot's import hints on mesh objects in Blender: `-col` (generates convex collision shape) and `-colonly` (generates invisible collision geometry).
- **Headless Validation:** Always validate modified scenes (`godot --headless --validate --quit scenes/levels/<SceneName>.tscn`) to guarantee no missing texture or resource dependencies exist.

---

## ⚠️ Known GDScript & Godot Quirks in this Project

1. **Lambda Variable Capture:**
   - GDScript lambdas (`func(): ...`) capture local variables by **copy/value**, not by reference.
   - If a lambda needs to mutate an outer variable (e.g. tracking signal emission in tests), wrap the state in a `Dictionary` (e.g. `var data = { "emitted": false }`), which is passed by reference.
2. **Enum Type Scoping:**
   - In Godot 4, typing variables with an inner enum (e.g. `var boat_side: Side = Side.WEST` inside `class_name RiverCrossingLogic`) can lead to cyclic parse errors. Under the hood, enums in GDScript are integers; type them as `int` or use type inference (`:=`) when appropriate.
3. **Preloading Classes in Scripts:**
   - To avoid cyclic compilation issues in headless mode, use `const Logic = preload("res://scripts/logic/...")` and instantiate with `Logic.new()`.
4. **Item Movement with Moving Platforms:**
   - When an item is carried on an object that translates over time (like a raft), lock the item's global position to the raft's attachment slot in `_process(_delta)` so it doesn't lag or get displaced by concurrent animations.
5. **Asynchronous Solvers & Integration Testing:**
   - When providing step-by-step debug solvers (e.g. in Levels 1, 2, 3, 4, and 5), expose the step interval via an exported variable (`@export var auto_solve_delay: float = 0.22`). In automated integration tests (`TestLevel0XScene.gd`), set `auto_solve_delay = 0.005` (or `0.01`) to test the full automated flow without introducing multi-second delays into test runs. Always guard loops with `is_auto_solving` flags so player input or scene resets safely cancel active solver routines.
6. **3D Object Picking (`_unhandled_input` vs `Area3D.input_event`):**
   - Do not connect both `_unhandled_input` raycasting and `CollisionObject3D.input_event` for the same click action: `_unhandled_input` fires during the main input pass while `Area3D.input_event` fires during the physics picking step (often on the next `Engine.get_process_frames()` tick), causing a single mouse click to trigger twice and immediately undo toggle actions. Use `_unhandled_input` raycasting as the single source of truth for clicks.
7. **glTF Model Internal Scaling & Bounding Boxes:**
   - Models exported from DCC tools or Sketchfab (such as `cat.glb`) often already contain internal centimeter-to-meter scaling factors (e.g. `RootNode.scale = Vector3(0.01, 0.01, 0.01)`). Always inspect the instantiated world AABB (`mesh_instance.global_transform * mesh_instance.get_aabb()`) before applying scene-level scale to avoid drastically undersizing or oversizing the asset.

---

## 📁 Repository Directory Map

```text
seproject/
├── story/                       # Design documents & mathematical riddle definitions
│   ├── logic.pdf                # Source textbook by Prof. Dr. Karl Stroetmann
│   ├── logical_riddles.md       # Extracted catalog of all 21 riddles with formal logic
│   └── level_progression.md     # Level-by-level GDD and Godot 3D mechanics mapping
├── assets/                      # Imported 3D models and textures (assets/models/)
├── scenes/
│   ├── ui/                      # Global UI screens (MainMenu.tscn)
│   ├── props/                   # Prefabs inherited from imported 3D models (Cat.tscn)
│   └── levels/                  # 3D level scenes (Level01..Level06)
├── scripts/
│   ├── core/                    # Shared components (BackToMenuButton.gd)
│   ├── ui/                      # UI controller scripts (MainMenuController.gd)
│   ├── levels/                  # Level scene controllers (presentation & input)
│   └── logic/                   # Pure headless logic models & solvers
├── tests/                       # SceneTree-based automated test scripts
├── project.godot                # Engine settings & input map
├── AGENTS.md                    # This guide
├── HANDOVER.md                  # Current state & backlog for incoming agents
└── README.md                    # Public documentation
```

---

## ⌨️ Standard Input Map Bindings

Defined in `project.godot`:
* `move_forward`: W, Up Arrow
* `move_backward`: S, Down Arrow
* `move_left`: A, Left Arrow
* `move_right`: D, Right Arrow
* `jump`: Space
* `interact`: E
* `reset`: R
* `journal`: J, Tab
