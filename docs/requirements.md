# Anforderungsspezifikation (SRS) — SEProject

**Projekt:** SEProject — Ein 3D-Logikrätsel-Abenteuer  
**Engine:** Godot Engine 4.x (Forward+ Renderer, Jolt 3D Physics, GDScript 2.0)  
**Quellmaterial:** Prof. Dr. Karl Stroetmann, *Theoretical Computer Science: Logic & Puzzles*  
**Zuletzt aktualisiert:** 25. November 2026

---

## 1. Einleitung

### 1.1 Zweck
Dieses Dokument definiert die funktionalen und nicht-funktionalen Anforderungen für **SEProject**, ein interaktives 3D-Logikrätsel-Abenteuerspiel auf Basis von Godot 4. Es dient als verbindliche Referenz für Implementierung, automatisierte Verifikation und zukünftige Erweiterungen.

### 1.2 Projektumfang (Scope)
SEProject übersetzt klassische Rätsel der theoretischen Informatik — Zustandsraumsuche, aussagenlogische Deduktion, Constraint-Satisfaction, Graphtraversierung und Prädikatenlogik erster Stufe — in interaktive 3D-Räume. Die Software umfasst:
- Ein **Hauptmenü** beim Start zur Levelauswahl und Navigation.
- **Fünf spielbare Logikrätsel-Level** (Level 1–5), jeweils unterstützt durch eine reine, Headless-fähige GDScript-Logikschicht, eine interaktive 3D-Ansicht bzw. Steuerung, einen animierten Debug-Auto-Solver sowie automatisierte Headless-Unit- und Integrationstests.
- **Ein 3D-Asset-Pipeline-Showcase-Level** (Level 6: The Cat Sanctuary), das vererbte glTF-2.0-Prefabs (`.glb`), Skelettanimationen und 3D-Picking demonstriert.
- Ein dokumentiertes **Backlog** für First-Person-Steuerung, ein In-Game-Logikjournal, den vollständigen Ersatz von CSG-Greyboxen durch 3D-Modelle sowie eine Bonuskammer (*The Midnight Bridge*).

### 1.3 Stakeholder & Rollen
| Rolle | Beschreibung |
| :--- | :--- |
| **Spieler** | Interagiert mit 3D-Rätseln, untersucht Hinweise/Tafeln, löst Rätsel und navigiert zwischen den Leveln und dem Hauptmenü. |
| **Entwickler / Mitwirkender** | Implementiert Headless-Logikmodelle, 3D-Controller, Shader/Assets und automatisierte Tests gemäß den Architekturrichtlinien. |
| **Prüfer / QA** | Führt Headless-Testsuiten aus, nutzt Debug-Auto-Solver zur Verifikation der Lösbarkeit und validiert die Szenenintegrität. |

### 1.4 Prioritäts- & Statuskonventionen
- **MoSCoW-Prioritäten:** `Muss` (Kernanforderung), `Soll` (wichtig für Vollständigkeit/UX), `Kann` (zukünftige Erweiterung).
- **Status:** `Implementiert` (durch automatisierte Tests verifiziert) oder `Geplant` (im Projekt-Backlog).

---

## 2. Funktionale Anforderungen

### FR-01: Menü- & Navigationssystem

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-01.1** | **Start-Hauptmenü:** Die Anwendung startet in `MainMenu.tscn`, zeigt alle konfigurierten Level an und ermöglicht die Auswahl jedes freigeschalteten Levels. | Muss | Implementiert |
| **FR-01.2** | **Rückkehr zum Menü:** Jedes spielbare Level zeigt eine dauerhafte Schaltfläche `< Menu` (`BackToMenuButton`), über die der Spieler zu `MainMenu.tscn` zurückkehren kann. | Muss | Implementiert |
| **FR-01.3** | **Linearer Auto-Fortschritt:** Das Lösen der Level 1–5 zeigt ein Siegesbanner an und wechselt nach einer kurzen Verzögerung automatisch ins nächste Level (3 s nach Level 1; 4 s nach Level 2–5). | Soll | Implementiert |
| **FR-01.4** | **Anwendung beenden:** Das Hauptmenü bietet eine `Quit`-Schaltfläche, welche die Anwendung sauber beendet. | Muss | Implementiert |

---

### FR-02: Level 1 — The Ferryman's Crossing (*Wolf, Ziege & Kohlkopf*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-02.1** | **Transport- & Kapazitätsregeln:** Die Logik-Engine (`RiverCrossingLogic`) verwaltet die Position der Objekte (`WOLF`, `GOAT`, `CABBAGE`) am Westufer, am Ostufer oder auf dem Floß und erlaubt höchstens ein Objekt gleichzeitig auf dem Floß. | Muss | Implementiert |
| **FR-02.2** | **Gefahrenprüfung:** Werden Wolf und Ziege oder Ziege und Kohlkopf unbeaufsichtigt zusammen an einem Ufer gelassen, wird ein Fehlerzustand (`puzzle_failed`) mit Begründung ausgelöst und weitere Züge werden bis zum Zurücksetzen gesperrt. | Muss | Implementiert |
| **FR-02.3** | **Direkte 3D-Ein-Klick-Interaktion:** Spieler können direkt auf die 3D-Objekte klicken, um Passagiere mit einem Klick zu laden, zu tauschen oder abzuladen, sowie auf das 3D-Floß (oder die HUD-Schaltfläche `Row Raft`), um den Fluss zu überqueren — inklusive Hover-Skalierung und Cursor-Feedback. | Muss | Implementiert |
| **FR-02.4** | **Sieg & Zurücksetzen:** Das sichere Übersetzen aller drei Objekte ans Ostufer löst `puzzle_solved` aus. Ein Klick auf `Reset` setzt alle Objekte und das Floß ans Westufer zurück und hebt Fehlerzustände auf. | Muss | Implementiert |
| **FR-02.5** | **BFS-Auto-Solver:** Die Logik-Engine berechnet mittels Breitensuche (`find_solution()`) eine optimale Lösung; das HUD bietet eine umschaltbare Schaltfläche `Auto-Solve (Debug)`, die die Lösung Schritt für Schritt animiert und durch Benutzereingaben pausiert oder abgebrochen werden kann. | Soll | Implementiert |

---

### FR-03: Level 2 — The Hall of Nine Portals (*Smullyans Prinzessin & Tiger*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-03.1** | **Königliches Logikprotokoll:** `NinePortalsLogic` setzt das Protokoll durch: Die Inschrift einer Tiger-Tür ist falsch, die Inschrift der Prinzessinnen-Tür ist wahr, und die Inschriften leerer Räume sind entweder alle wahr oder alle falsch. | Muss | Implementiert |
| **FR-03.2** | **Zufällige, wiederspielbare Anordnung:** Beim Levelstart und nach jedem Zurücksetzen wird die Raumbelegung randomisiert, wobei alle 9 Türinschriften dynamisch so umgeschrieben werden, dass der Raum der Prinzessin stets eindeutig deduzierbar bleibt (`princess_candidates(roles).size() == 1`). | Muss | Implementiert |
| **FR-03.3** | **Direkte 3D-Türauswahl & Tafelinspektion:** Ein Klick auf eine der 9 Türen direkt in 3D wählt sie aus, hebt Tafel und Rahmen hervor (Gold für aktuell ausgewählt, warmes Bernstein für bereits inspiziert) und zeigt die Inschrift im `PlaquePanel` an. | Muss | Implementiert |
| **FR-03.4** | **Ergebnisse beim Türöffnen:** Das Öffnen der Prinzessinnen-Tür löst das Rätsel; das Öffnen einer Tiger-Tür löst ein Fehlerbanner aus, das ein `Reset` erfordert; das Öffnen eines leeren Raums enthüllt eine leere Nische und erlaubt das Weiterspielen. | Muss | Implementiert |
| **FR-03.5** | **Deduktiver Auto-Solver:** `solve_princess_room()` deduziert den eindeutigen Raum der Prinzessin, und `Auto-Solve (Debug)` inspiziert Tafeln schrittweise, bevor die ermittelte Tür geöffnet wird. | Soll | Implementiert |

---

### FR-04: Level 3 — The Sun Courtyard (*Das 8-Damen-Problem*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-04.1** | **Brettplatzierung:** `QueensLogic` verwaltet ein $8 \times 8$-Brett und erlaubt das Platzieren, Entfernen und Umschalten von bis zu 8 Damen. | Muss | Implementiert |
| **FR-04.2** | **Echtzeit-Konflikterkennung & Optik:** Zwei Damen in derselben Zeile, Spalte oder Diagonale werden als Konflikt markiert; ihre 3D-Statuen färben sich karmesinrot und werden durch leuchtende rote Strahlen verbunden, während sichere Statuen golden leuchten. | Muss | Implementiert |
| **FR-04.3** | **Siegbedingung:** Das Platzieren von 8 Damen ohne Konflikte löst `puzzle_solved` aus, färbt alle Statuen grün und zeigt das Siegesbanner an. | Muss | Implementiert |
| **FR-04.4** | **Vervollständigungs-Auto-Solver:** `QueensLogic` unterstützt das Aufzählen aller 92 Lösungen (`solve_all()`) sowie das Vervollständigen gültiger Teilbelegungen (`find_completion()`), gesteuert über `Auto-Solve (Debug)`. | Soll | Implementiert |

---

### FR-05: Level 4 — The Knight's Chasm (*Das Springerproblem*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-05.1** | **Springerzug- & Besuchsregeln:** `KnightsTourLogic` startet den Springer auf A1 `(0, 0)` und erlaubt Züge nur auf unbesuchte Felder innerhalb des Bretts gemäß dem L-förmigen Springerzug (`(±1, ±2)` oder `(±2, ±1)`). | Muss | Implementiert |
| **FR-05.2** | **Versinkende 3D-Kacheln & visuelle Führung:** Beim Verlassen einer Kachel versinkt diese in der Lava; gültige nächste Züge werden in 3D sowie im $8 \times 8$-HUD-Raster hervorgehoben; ein Live-Zähler zeigt `Visits: N / 64` an. | Muss | Implementiert |
| **FR-05.3** | **Sackgassen-Erkennung & Rückgängig-Stapel:** Wird vor 64 Besuchen ein Zustand ohne gültige Züge erreicht, wird `puzzle_failed` ausgelöst. Über `Undo Last Jump` kann der Spieler Züge rückgängig machen, versunkene Kacheln wieder anheben und Sackgassen verlassen. | Muss | Implementiert |
| **FR-05.4** | **Siegbedingung:** Das einmalige Besuchen aller 64 Felder löst `puzzle_solved` aus und hebt alle Kacheln zu einer leuchtenden Brücke an. | Muss | Implementiert |
| **FR-05.5** | **Warnsdorff-Auto-Solver:** `KnightsTourLogic` berechnet vollständige 64-Felder-Touren mittels Warnsdorff-Heuristik (`find_tour()` / `find_tour_from_path()`), abrufbar über `Auto-Solve (Debug)`. | Soll | Implementiert |

---

### FR-06: Level 5 — The Night at Dreadbury Manor (*Wer tötete Tante Agatha?*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-06.1** | **Prädikatenlogischer Modellprüfer & multiple Ausgänge:** `DreadburyLogic` formalisiert die 3 Bewohner (`AGATHA`, `BUTLER`, `CHARLES`), 3 randomisierte prädikatenlogische Fälle (`Case.AGATHA`, `Case.BUTLER`, `Case.CHARLES`) mit jeweils 8 dynamischen Hinweisen sowie die Prädikate (`killed`, `hates`, `richer_than_agatha`) und verifiziert erschöpfend, dass in jedem Fall genau ein eindeutiger Täter deduzierbar ist (`killer_candidates(case_id).size() == 1`). | Muss | Implementiert |
| **FR-06.2** | **Hinweisuntersuchung:** Spieler können alle 8 Hinweise des aktuellen Falls untersuchen und Titel, Fundort, Erzähltext sowie formale prädikatenlogische Formel einsehen, während der Fortschritt (`Clues Examined: N / 8`) verfolgt wird. | Muss | Implementiert |
| **FR-06.3** | **Anklagealtar & Dolch der Wahrheit:** Spieler wählen eine Verdächtigen-Büste aus und platzieren den animierten Dolch der Wahrheit, um eine Anklage einzureichen. | Muss | Implementiert |
| **FR-06.4** | **Widerspruchs-Feedback:** Das Anklagen eines unschuldigen Verdächtigen löst `puzzle_failed` aus und zeigt den fallspezifischen formalen logischen Widerspruch (`contradiction_for(suspect, case_id)`), warum dieser Verdächtige nicht der Täter sein kann. Ein `Reset` wechselt zu einem anderen Fall. | Muss | Implementiert |
| **FR-06.5** | **Fallspezifische Siegesenthüllung & Auto-Solver:** Das Anklagen des wahren Täters enthüllt das versteckte 3D-Beweisstück hinter der Büste des Täters, wechselt die Beleuchtung auf eine ausgangsspezifische Morgenbeleuchtung, zeigt die jeweilige Auflösung (`victory_message_for()`) und löst `puzzle_solved` aus. `Auto-Solve (Debug)` untersucht alle Hinweise und löst den aktiven Fall automatisch. | Soll | Implementiert |

---

### FR-07: Level 6 — The Cat Sanctuary (*3D-Asset-Showcase*)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-07.1** | **glTF-2.0-Prefab-Präsentation:** Die Szene instanziiert ein vererbtes Prefab (`scenes/props/Cat.tscn`) auf Basis von `assets/models/characters/cat.glb` auf einem drehbaren Sockel mit umschaltbarer Rotation. | Soll | Implementiert |
| **FR-07.2** | **Animationssteuerung:** Der Controller ermöglicht das Umschalten der geloopten Wiedergabe der Skelettanimation (`Take 001`). | Soll | Implementiert |
| **FR-07.3** | **3D-Picking-Interaktion:** Ein Klick auf die 3D-`ClickArea` der Katze oder auf `Pet Cat` löst eine Sprunganimation aus, erhöht den Streichelzähler und zeigt nach 5 Streicheleinheiten das Banner `PURR-FECTION ACHIEVED` an; `Reset` stellt den Ausgangszustand wieder her. | Soll | Implementiert |

---

### FR-08: Geplante Anforderungen (Backlog)

| ID | Anforderung | Priorität | Status |
| :--- | :--- | :--- | :--- |
| **FR-08.1** | **First-Person-3D-Spielersteuerung:** Implementierung eines `CharacterBody3D`-Spielers (`Player.tscn`) mit WASD-Bewegung, Sprint, Mausblick (`Esc`-Toggle), Sprung und zentriertem `RayCast3D` zur Interaktion mit `Interactable3D`-Komponenten über `[E]`. | Soll | Implementiert |
| **FR-08.2** | **In-Game-Logikjournal:** Implementierung eines umschaltbaren Notizbuchs (`[J]` / `[Tab]`), das entdeckte Türinschriften (Level 2) und Hinweise (Level 5) automatisch protokolliert, inkl. interaktiver Deduktions-Scratchpad-Matrix (`✓` / `✗`). | Soll | Implementiert |
| **FR-08.3** | **Bonuskammer — The Midnight Bridge:** Implementierung des *Brücken-und-Fackel-Problems* (4 Reisende mit Geschwindigkeiten 1, 2, 5 und 8 Minuten; max. 2 Personen gleichzeitig auf der Brücke; striktes 15-Minuten-Fackellimit) mit Headless-Logik, 3D-Szene und Tests. | Kann | Implementiert |
| **FR-08.4** | **3D-Asset-Austausch:** Schrittweiser Ersatz der CSG-Greybox-Geometrie in Level 1–5 durch vererbte `.glb`-Prefabs unter Beibehaltung von Knotenpfaden, Kollisions-Pickern und Animations-Pivots. | Kann | Geplant |

---

## 3. Nicht-funktionale Anforderungen

| ID | Kategorie | Anforderung | Verifikationsmethode |
| :--- | :--- | :--- | :--- |
| **NFR-01** | **Architektur** | **Strikte Model-View-Trennung:** Alle Rätselregeln, Invariantenprüfungen und Solver in `scripts/logic/` erben von `RefCounted` (reines GDScript) ohne Abhängigkeiten zu 3D-Nodes, UI-Controls oder dem SceneTree. | Code-Review & Headless-Unit-Tests (`Test*.gd`). |
| **NFR-02** | **Testbarkeit** | **Automatisierte Headless-Verifikation:** Jedes Logikmodell verfügt über eine `SceneTree`-Unit-Testsuite, und jede Level-/Menüszene verfügt über einen Headless-Integrationstest sowie erfolgreiche Validierung per `godot --headless --validate --quit`. | CI- / CLI-Testausführung (`0` Fehler). |
| **NFR-03** | **Benutzerfreundlichkeit & UI** | **Überlappungsfreies & dezentes HUD:** Kein 2D-HUD-Panel (`BackToMenuButton`, `HeaderPanel`, `SidePanel`, `Banner`, `ActionBar`) darf ein anderes HUD-Label oder kritische 3D-`Label3D`-Objekte bei Standardauflösung `1152×648` (`canvas_items` / `expand`) überlappen. Jede Szene nutzt eine eigene dezente, gut lesbare Farbpalette. | Automatisierte Layout-Prüfungen & Integrationstests (`TestLevel04Scene.gd`). |
| **NFR-04** | **Reaktionsfähigkeit** | **Flüssige Interaktion & Abbruchfähigkeit:** Animationen (`Tween`) und Auto-Solver-Coroutinen dürfen den UI-Thread nicht blockieren, und jeder Spielerklick oder Reset muss laufende Auto-Solver-Schleifen über Zustandsflags sicher abbrechen. | Szenen-Integrationstests (`TestLevel01Scene.gd`–`TestLevel05Scene.gd`). |
| **NFR-05** | **Portabilität** | **Plattformübergreifend & eigenständige Assets:** Das Projekt läuft unter Godot 4.3+ (4.7.2 getestet) auf Linux, macOS und Windows mit Forward+ und Jolt Physics. 3D-Assets nutzen eigenständige `.glb`-Dateien ohne Laufzeitabhängigkeit zu Blender oder externen DCC-Tools. | Headless-Import & Validierung auf dem Zielsystem. |
| **NFR-06** | **Wartbarkeit** | **Dokumentations-, Branching- & Issue-Synchronisation:** Alle Code-, Szenen- und Teständerungen halten `README.md`, `HANDOVER.md`, `AGENTS.md` und `docs/` synchron, werden auf dedizierten Git-Branches (nie direkt auf `main`) per Pull Request integriert und mit den entsprechenden GitHub-Issues und Labels in `eytschjey/seproject` verknüpft. | Repository-Prüfung, PR-/Git-Historie & Issue-Tracking. |

---

## 4. Anforderungs-Rückverfolgbarkeitsmatrix (Traceability Matrix)

| Anforderungsgruppe | Primäre Implementierungsdateien | Automatisierte Verifikation | Status |
| :--- | :--- | :--- | :--- |
| **FR-01** (Menü & Nav) | `scenes/ui/MainMenu.tscn`, `scripts/ui/MainMenuController.gd`, `scripts/core/BackToMenuButton.gd` | `tests/TestMainMenu.gd`, `tests/TestLevel01Transition.gd` | Implementiert |
| **FR-02** (Level 1) | `scripts/logic/RiverCrossingLogic.gd`, `scenes/levels/Level01_Tutorial.tscn`, `scripts/levels/Level01Controller.gd` | `tests/TestRiverCrossing.gd` (46), `tests/TestLevel01Scene.gd` (14) | Implementiert |
| **FR-03** (Level 2) | `scripts/logic/NinePortalsLogic.gd`, `scenes/levels/Level02_NinePortals.tscn`, `scripts/levels/Level02Controller.gd` | `tests/TestNinePortals.gd` (30), `tests/TestLevel02Scene.gd` (31) | Implementiert |
| **FR-04** (Level 3) | `scripts/logic/QueensLogic.gd`, `scenes/levels/Level03_SunCourtyard.tscn`, `scripts/levels/Level03Controller.gd` | `tests/TestQueens.gd` (29), `tests/TestLevel03Scene.gd` (15) | Implementiert |
| **FR-05** (Level 4) | `scripts/logic/KnightsTourLogic.gd`, `scenes/levels/Level04_KnightsChasm.tscn`, `scripts/levels/Level04Controller.gd` | `tests/TestKnightsTour.gd` (26), `tests/TestLevel04Scene.gd` (18) | Implementiert |
| **FR-06** (Level 5) | `scripts/logic/DreadburyLogic.gd`, `scenes/levels/Level05_DreadburyManor.tscn`, `scripts/levels/Level05Controller.gd` | `tests/TestDreadbury.gd` (62), `tests/TestLevel05Scene.gd` (22) | Implementiert |
| **FR-07** (Level 6) | `scenes/props/Cat.tscn`, `scenes/levels/Level06_Cat.tscn`, `scripts/levels/Level06Controller.gd` | `tests/TestLevel06Scene.gd` (17) | Implementiert |
| **FR-08.1** (Player) | `scenes/player/Player.tscn`, `scripts/player/PlayerController.gd`, `scripts/core/Interactable3D.gd` | `tests/TestPlayerController.gd` (21) | Implementiert |
| **FR-08.2** (Journal) | `scripts/logic/JournalState.gd`, `scenes/ui/Journal.tscn`, `scripts/ui/JournalController.gd` | `tests/TestJournal.gd` (53) | Implementiert |
| **FR-08.3** (Midnight Bridge) | `scripts/logic/MidnightBridgeLogic.gd`, `scenes/levels/Level07_MidnightBridge.tscn`, `scripts/levels/Level07Controller.gd` | `tests/TestMidnightBridge.gd` (45), `tests/TestLevel07Scene.gd` (17) | Implementiert |
| **FR-08** (Übriges Backlog) | `story/level_progression.md`, `HANDOVER.md`, `docs/backlog.md` | Geplant | Geplant |
