# Game Design Document: Level Progression & Riddle Integration
**Project:** 3D Logic Adventure Game (Godot Engine)  
**Source Material:** Prof. Dr. Karl Stroetmann, *Theoretical Computer Science: Logic & Puzzles*

---

## 🎮 Game Overview & Core Concept

The game is a first-person / third-person 3D puzzle adventure in the style of *The Talos Principle*, *The Witness*, and *Myst*. The player traverses an atmospheric realm moving from chamber to chamber. Each area is physically built around a classical logical riddle. 

Instead of answering text questions in static pop-up menus, the player solves the logic riddles through **environmental interaction, spatial navigation, and physical deduction**.

### Core Gameplay Loop
1. **Explore the Chamber:** Inspect the environment, read inscriptions, and discover physical clues.
2. **Experiment & Manipulate:** Push statues, row rafts, step on ancient tiles, or examine crime scene evidence.
3. **Logical Verification:** The underlying logic state machine verifies constraints in real time.
4. **Passage Unlocked:** Solving the riddle activates ancient mechanisms, opening the portal/doorway to the next chamber.

---

## 🗺️ Progression Roadmap

```
[Level 1: The Ferryman's Crossing]  --> Tutorial / Physical State Mechanics
               ↓
[Level 2: The Hall of Nine Portals]  --> Pure Propositional Deduction & High Stakes
               ↓
[Level 3: The Sun Courtyard]        --> Spatial Constraint Satisfaction & Optics
               ↓
[Level 4: The Knight's Chasm]       --> 3D Movement, Pathfinding & Floor Traps
               ↓
[Level 5: Dreadbury Manor]          --> Narrative Climax & Detective Investigation
               ↓
[Bonus Chamber: The Midnight Bridge]--> Time-Critical Resource Management
```

---

# Level 1: The Ferryman's Crossing (Tutorial & Warm-Up)

* **Riddle:** *The Wolf, Goat, and Cabbage Problem* (Chapter 5, Exercise 19)
* **Theme / Setting:** A misty riverbank dock surrounded by ancient willow trees. Across the wide, rushing river lies a massive locked iron gate.
* **Objective:** Transport a tame wolf, a tethered goat, and a prized enchanted cabbage across to the opposite shore using a small wooden raft.

### The Riddle & Rules
1. The raft only holds the player and **one item/animal at a time**.
2. If left together unsupervised on either shore:
   * The **wolf** will eat the **goat**.
   * The **goat** will eat the **cabbage**.
3. The player rows the raft back and forth between the Western dock and the Eastern dock.

### 3D Godot Implementation Mechanics
* **Entities:**
  * `Raft` (`AnimatableBody3D`): Moves between waypoint markers along a spline when the player pulls the rowing lever.
  * `Wolf`, `Goat`, `Cabbage` (`RigidBody3D` or `CharacterBody3D`): Can be picked up (`CarryComponent`) or ordered onto the boat dock pad (`Area3D`).
* **Logic & Fail States:**
  * When the raft leaves a shore, an `Area3D` on that shore checks the remaining occupants:
    * If `Shore.has(Wolf)` and `Shore.has(Goat)` and `!Shore.has(Player)`: Comic fail animation triggers (the wolf lunges at the goat, screen fades, reset to previous crossing).
    * If `Shore.has(Goat)` and `Shore.has(Cabbage)` and `!Shore.has(Player)`: The goat starts munching the cabbage, screen fades, reset.
* **Solution Sequence:**
  1. Take Goat to East (West: Wolf, Cabbage).
  2. Return empty-handed to West.
  3. Take Wolf to East (East: Goat, Wolf).
  4. Bring Goat back to West (West: Goat, Cabbage; East: Wolf).
  5. Take Cabbage to East (East: Wolf, Cabbage).
  6. Return empty-handed to West.
  7. Take Goat to East.
* **Victory Event:** Once all three are safely placed on pressure pedestals on the East shore, the giant water-gate grinds open, revealing the stone tunnel to Level 2.

---

# Level 2: The Hall of Nine Portals (High Stakes Deduction)

* **Riddle:** *The Trial of the Nine Portals* by Raymond M. Smullyan (Chapter 4, Exercise 13)
* **Theme / Setting:** An imposing royal throne room corridor lined with nine massive, identical carved stone doors (numbered 1 through 9). Statues of roaring tigers and veiled princesses flank the hall.
* **Objective:** Deduce which of the 9 doors hides the Golden Key / Princess without opening a door containing a ravenous tiger.

### The Riddle & Inscriptions

#### The Royal Logic Protocol:
* **Tiger Behind Door:** The inscription on that door is **false**.
* **Princess / Key Behind Door:** The inscription is **true**.
* **Empty Room:** Either **all** empty room inscriptions are **true**, or **all** are **false**.

#### Door Inscriptions:
* **Door 1:** *"The princess is in a room with an odd number and there is no tiger in the rooms with an even number."*
* **Door 2:** *"This room is empty."*
* **Door 3:** *"The inscription on Room No. 5 is true, the inscription on Room No. 7 is false, and there is a tiger in Room No. 3."*
* **Door 4:** *"The inscription on Room No. 1 is false, there is no tiger in Room No. 8, and the inscription on Room No. 9 is true."*
* **Door 5:** *"If the inscription on Room No. 2 or on Room No. 4 is true, then there is no tiger in Room No. 1."*
* **Door 6:** *"The inscription on Room No. 3 is false, the princess is in Room No. 2, and there is no tiger in Room No. 2."*
* **Door 7:** *"The princess is in Room No. 1 and the inscription on Room No. 5 is true."*
* **Door 8:** *"There is no tiger in this room and Room No. 9 is empty."*
* **Door 9:** *"Neither in this room nor in Room No. 1 is there a tiger, and moreover, the inscription on Room No. 6 is true."*

### 3D Godot Implementation Mechanics
* **Interactable Plaques:** Approaching each door focuses the camera on an engraved plaque (`InteractionRaycast` / inspect overlay). The player's journal records each sign.
* **Tension & Feedback:**
  * Doors can be unlocked with an iron key given at the entrance.
  * **Wrong Door (Tiger):** Door opens into pitch blackness; glowing eyes emerge and a trap / tiger attack triggers a checkpoint respawn.
  * **Wrong Door (Empty):** Opens into a barren, dusty stone vault.
  * **Correct Door:** Reveals an illuminated inner sanctum with the Royal Sigil required for Level 3.
* **Analytical Hint:** Look closely at Room 3: *"The inscription on Room No. 3 states there is a tiger in Room No. 3."* If Room 3 held a tiger, its sign would have to be false, contradicting the inscription itself! Thus Room 3 cannot contain a tiger.

---

# Level 3: The Sun Courtyard (Spatial Constraint Satisfaction)

* **Riddle:** *The 8-Queens Problem* (Chapter 4, Section 4.8.1 & Chapter 5, Section 5.4.3)
* **Theme / Setting:** A sunlit open-air Romanesque courtyard featuring a massive $8 \times 8$ marble chessboard on the floor. Sunlight streams through 8 skylights.
* **Objective:** Place 8 golden Queen statues on the checkered floor so that none threatens another.

### The Riddle & Rules
* A Queen can move and attack any distance horizontally, vertically, or diagonally.
* To solve the courtyard, **exactly 8 statues** must be placed such that no two statues share the same row, column, or diagonal line of sight.

### 3D Godot Implementation Mechanics
* **Interactive Statues:**
  * 8 Queen Statues on movable wheeled bases (`AnimatableBody3D`).
  * The player pushes or drags statues into grid cells $(1..8, 1..8)$.
* **Visual Optics & Laser Beams:**
  * When placed in a cell, the statue's crown lights up and fires thin beams of light along its 8 directions (row, column, and diagonals).
  * **Real-time Visual Feedback:**
    * If a beam intersects another statue, both beams flare **glowing crimson red** (conflict state).
    * When placed safely with no intersections, the beam glows **serene azure / gold**.
* **Constraint Solver Verification:**
  * A GDScript node tracks the active array of positions:
    ```gdscript
    func is_valid_placement(queens: Array[Vector2i]) -> bool:
        for i in range(queens.size()):
            for j in range(i + 1, queens.size()):
                var q1 = queens[i]
                var q2 = queens[j]
                if q1.x == q2.x or q1.y == q2.y:
                    return false
                if abs(q1.x - q2.x) == abs(q1.y - q2.y):
                    return false
        return true
    ```
* **Victory Event:** When all 8 queens are placed on the board with `queens.size() == 8 and is_valid_placement(queens)`, the beams converge on an ancient sun crystal, lowering a drawbridge to the catacombs.

---

# Level 4: The Knight's Chasm (Platforming & Pathfinding)

* **Riddle:** *The Knight's Tour* (Chapter 5, Section 5.6.2)
* **Theme / Setting:** A vast underground cavern suspended over molten lava or an endless glowing crystal abyss.
* **Objective:** Cross the chasm by stepping on every single one of the 64 floating stone platforms exactly once using only chess knight jumps.

### The Riddle & Rules
* The floor consists of an $8 \times 8$ grid of floating square runes (numbered from $[0,0]$ to $[7,7]$).
* The player starts on tile $(0, 0)$.
* The only legal moves are **knight moves**:
  * 2 steps in one cardinal axis, then 1 step perpendicular (e.g. $+2, +1$ or $-1, +2$).
* Every single one of the 64 tiles must be visited.
* Stepping on a tile activates it; once you jump off, it sinks into the chasm.

### 3D Godot Implementation Mechanics
* **Tile Matrix (`GridMap` or collection of `Area3D` tiles):**
  * Current tile glow color: Gold.
  * Valid next tiles: Blue highlight ring projecting an arc of particles showing the leap path.
  * Visited tiles: Sinks downwards or crumbles into dust with smoke particles.
* **Player Movement:**
  * Player can either jump freely with collision detection, or press direction keys to leap in knight trajectories.
  * If the player jumps to an illegal tile, the rune shatters, dropping the player into a respawn cloud that restores the previous move.
* **Tactile Counter:**
  * A stone ring counter displays `Visits: N / 64`.
  * If the player enters a dead end (no remaining unvisited knight moves), a stone reset bell rings and tiles re-emerge from the depths.
* **Victory Event:** Upon touching the 64th tile, the full grid locks into a solid radiant bridge leading to the gates of Dreadbury Manor.

---

# Level 5: The Night at Dreadbury Manor (Narrative Mystery Climax)

* **Riddle:** *Who Killed Aunt Agatha?* (Chapter 6, Section 6.5.2)
* **Theme / Setting:** A stormy Victorian manor. Lightning flashes outside stained-glass windows. Aunt Agatha lies dead in the library armchair.
* **Objective:** Interrogate the remaining residents, gather documentary evidence, and identify the killer to break the mansion's curse.

### The Story & Clues
> *Someone who lives in Dreadbury Mansion killed Aunt Agatha. Agatha, the butler, and Charles live in Dreadbury Mansion, and are the only people who live therein.*

* **Clues to Discover in the Manor:**
  1. **Coroner's Journal:** *"A killer always hates their victim."*
  2. **Charles's Letter:** *"Charles hates no one that Aunt Agatha hates."*
  3. **Diary of Agatha:** *"Agatha hates everyone except the butler."*
  4. **Financial Ledger:** *"A killer is never richer than their victim."*
  5. **Butler's Rule:** *"The butler hates everyone not richer than Aunt Agatha."*
  6. **Butler's Confession:** *"The butler hates everyone Aunt Agatha hates."*
  7. **Psychological Profile:** *"No one in the mansion hates everyone."*
  8. **Estate Will:** *"Agatha, the butler, and Charles are the only residents of Dreadbury Mansion, and Agatha is not the butler."*

### 3D Godot Implementation Mechanics
* **Environmental Storytelling / Investigation:**
  * Player inspects items in 3D:
    * The **victim** in the armchair (holding a poison goblet).
    * The **Butler's quarters** (ledger showing his debts and poor income).
    * **Charles's desk** (letters revealing his feelings toward Agatha and the Butler).
  * NPCs **Charles** and the **Butler** stand in the foyer and can be questioned. Each dialogue unlocks deductive premises in the player's notebook.
* **The Accusation Altar:**
  * In the grand entrance hall stands a scale with three portrait busts: **Charles**, **The Butler**, and **Aunt Agatha**.
  * The player must place the "Dagger of Truth" on the correct bust.
* **The Logical Deductive Resolution:**
  * *Could it be Charles?*
    If Charles killed Agatha, Charles hated Agatha. Since Charles hates nobody Agatha hates, Agatha could not have hated herself. But Agatha hates everyone except the butler, so she must have hated herself—**Contradiction!**
  * *Could it be the Butler?*
    The killer cannot be richer than Agatha, so the butler is not richer than Agatha. Thus, the butler hates himself. The butler also hates everyone Agatha hates (which includes herself and Charles). That means the butler hates Agatha, Charles, and himself—he hates everyone! But no one hates everyone—**Contradiction!**
  * *The Truth:* **Aunt Agatha committed suicide (killed herself).**
* **Ending Cinematic:** Placing the dagger on Agatha's bust reveals the final hidden suicide note behind her portrait. The storm clears, morning sunlight breaks through the windows, and the mansion doors swing open to the outer world.

---

# Bonus Secret Room: The Midnight Bridge (Chasm of Shadows)

* **Riddle:** *The Bridge and Torch Problem* (Chapter 5, Exercise 25)
* **Theme / Setting:** A optional challenge cavern where the player discovers an underground underground canyon crossed by a rickety rope bridge.
* **Objective:** Escort four lost travelers across the gorge before their single enchanted torch burns out.

### The Riddle & Rules
* **Travelers:**
  * **Ariela:** Fast runner (takes 1 minute).
  * **Brian:** Steady explorer (takes 2 minutes).
  * **Charly:** Heavy armor guard (takes 5 minutes).
  * **Dumpy:** Elderly scholar (takes 8 minutes).
* **Constraints:**
  1. The bridge only holds **two travelers** at a time.
  2. The crossing must be made with the **torch** in hand.
  3. When two cross together, they walk at the speed of the slower person.
  4. The torch lasts for **strictly 15 minutes**.

### 3D Godot Implementation Mechanics
* **Dynamic Torch Mechanic:**
  * The torch's `OmniLight3D` slowly shrinks in radius and flickers as time elapses.
  * A timer UI on the torch handle counts down from 15:00.
* **Companion Movement:**
  * Player selects which pair crosses, walks with them across the narrow swaying bridge, and returns with the torch.
* **Optimal Solution (Total = 15 minutes):**
  1. Ariela (1) & Brian (2) cross $\rightarrow$ **2 minutes spent** (Time: 2).
  2. Ariela (1) returns with the torch $\rightarrow$ **1 minute spent** (Time: 3).
  3. Charly (5) & Dumpy (8) cross together $\rightarrow$ **8 minutes spent** (Time: 11).
  4. Brian (2) returns with the torch $\rightarrow$ **2 minutes spent** (Time: 13).
  5. Ariela (1) & Brian (2) cross together $\rightarrow$ **2 minutes spent** (Time: 15).
* **Reward:** Unlocks the secret Master Logician cosmetic skin and concept art gallery.

---

## 🛠️ Godot Engine Technical Architecture Recommendations

1. **State Machine (`PuzzleController.gd`):**
   * Keep puzzle logic strictly decoupled from 3D visuals. Use a headless GDScript class that models the mathematical state (e.g. bitmasks for chessboard, arrays for riverbanks).
   * Emit signals like `state_changed`, `invalid_move_attempted(reason)`, and `puzzle_solved`.
2. **First-Person Interaction (`Interactable.gd`):**
   * Use an `Area3D` or collision raycast from the player camera to detect interactable objects (doors, plaques, statues, evidence).
   * Display contextual UI prompts ("*Press [E] to Inspect*", "*Press [E] to Push*").
3. **Journal / Deductive UI (`LogicJournal.gd`):**
   * Automatically log collected clues in an in-game journal.
   * Provide a scratchpad / grid matrix where players can cross off deductions (similar to *Return of the Obra Dinn*).
