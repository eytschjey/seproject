# AGENTS.md — Agent & Contributor Guidelines

Welcome, AI Agent or developer! This repository houses **SEProject**, an atmospheric 3D logic adventure game built in **Godot 4** where theoretical computer science puzzles and deduction riddles are turned into interactive 3D mechanics.

---

## 🛠️ Tech Stack & Engine Configuration

- **Engine:** Godot Engine 4.x (`4.7.2.stable.official` or compatible 4.3+).
- **Renderer:** `Forward Plus` (Vulkan-based, modern lighting, shadows, volumetric fog).
- **Physics Engine:** `Jolt Physics` (`3d/physics_engine="Jolt Physics"`).
- **Display Scaling:** `window/stretch/mode="canvas_items"`, `window/stretch/aspect="expand"`.
- **Primary Language:** GDScript 2.0 (strictly typed).

---

## 🏛️ Core Architecture Principles

### 1. Strict Model-View Separation (Headless-First)
- **Model (`scripts/logic/`):**
  - Pure GDScript classes extending `RefCounted` (or `Node` if tree integration is required).
  - Must have **zero dependencies on 3D nodes, meshes, or visuals**.
  - All game rules, invariant checks, state transitions, win conditions, and fail conditions belong here.
  - State changes must emit signals: `state_changed`, `puzzle_failed(reason)`, `puzzle_solved`.
- **View / Controller (`scenes/levels/` & `scripts/levels/`):**
  - Responsible only for presentation, animations, tweening, and forwarding user inputs.
  - Listens to signals from the headless logic model.
  - Never mutates puzzle rules directly; always calls methods on the logic instance (`load_item()`, `cross_river()`, etc.).

### 2. Rapid 3D Prototyping (Greybox First)
- Do not block development waiting for finished 3D meshes or external art.
- Use Godot's built-in CSG nodes (`CSGBox3D`, `CSGSphere3D`, `CSGCylinder3D`) with standard materials for rapid prototyping.
- Keep coordinate references organized via `Marker3D` nodes rather than hardcoded vectors.

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

---

## 📁 Repository Directory Map

```text
seproject/
├── story/                       # Design documents & mathematical riddle definitions
│   ├── logic.pdf                # Source textbook by Prof. Dr. Karl Stroetmann
│   ├── logical_riddles.md       # Extracted catalog of all 21 riddles with formal logic
│   └── level_progression.md     # Level-by-level GDD and Godot 3D mechanics mapping
├── scenes/
│   └── levels/                  # 3D level scenes (.tscn)
├── scripts/
│   ├── levels/                  # Scene controllers (view/input handling)
│   └── logic/                   # Pure headless logic models
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
