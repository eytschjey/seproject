# Product Backlog & Priorisierung — SEProject

**Projekt:** SEProject — Ein 3D-Logikrätsel-Abenteuer (Godot 4)  
**Verknüpfte Dokumente:** [`docs/requirements.md`](requirements.md) | [`docs/user_stories.md`](user_stories.md) | [`HANDOVER.md`](../HANDOVER.md)  
**Zuletzt aktualisiert:** 25. November 2026

---

## 1. Priorisierungsmethodik & Schätzskala

Die Einträge im Product Backlog (**Product Backlog Items**, `PBI-*`) werden nach drei Kriterien priorisiert:
1. **Fachlicher Nutzen & Spielbarkeit** (MoSCoW: `Muss`, `Soll`, `Kann`).
2. **Technische Abhängigkeiten** (Grundlagen wie First-Person-Controller oder Journal vor darauf aufbauenden Komfort-Features).
3. **Risiko & Aufwands-Nutzen-Verhältnis** (Fibonacci-Story-Points: `1, 2, 3, 5, 8, 13`).

| Prioritätsstufe | Bedeutung |
| :--- | :--- |
| **P0 (Kritisch / Muss)** | Unverzichtbar für Kernspielbarkeit, Stabilität oder Qualitätssicherung. |
| **P1 (Hoch / Soll)** | Nächster großer Meilenstein mit hohem Mehrwert für das Spielerlebnis. |
| **P2 (Mittel / Soll–Kann)** | Wichtige Erweiterungen für Immersion, Optik und Wiederspielbarkeit. |
| **P3 (Niedrig / Kann)** | Optionale Bonusinhalte und Feinschliff (Polish). |

---

## 2. Priorisiertes Product Backlog (Offene Aufgaben)

Sortiert von höchster zu niedrigster Priorität:

| Rang | PBI-ID | GitHub Issue | Titel | Epic | Verknüpfte US / Req | Priorität | Story Points | Abhängigkeiten | Status |
| :---: | :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **1** | **PBI-01** | `#1` | **In-Game-Logikjournal (UI & automatisches Protokollieren)** | Epic 9 | `US-26`, `FR-08.2` | **P1 (Soll)** | **5** | — | Erledigt |
| **2** | **PBI-02** | `#2` | **First-Person-3D-Spielersteuerung (`Player.tscn`) & `Interactable3D`** | Epic 9 | `US-25`, `FR-08.1` | **P1 (Soll)** | **8** | — | Erledigt |
| **3** | **PBI-03** | `#3` | **3D-Asset-Austausch Level 1 (Wolf, Ziege, Kohlkopf, Floß & Flussufer)** | Epic 7 | `US-22`, `FR-08.4`, `NFR-05` | **P1 (Soll)** | **5** | — | Offen |
| **4** | **PBI-04** | `#4` | **Integration First-Person & Journal in Level 2 (Tafelinspektion in 3D)** | Epic 3 / 9 | `US-25`, `US-26`, `FR-08.1` | **P2 (Soll)** | **5** | `PBI-01`, `PBI-02` | Erledigt |
| **5** | **PBI-05** | `#5` | **3D-Asset-Austausch Level 2 (Türen, Rahmen, Tiger- & Prinzessinnen-Modelle)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **6** | **PBI-06** | `#6` | **3D-Asset-Austausch Level 3 (Damenstatuen-Prefab, Marmor & Sonnenkristall)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **7** | **PBI-07** | `#7` | **3D-Asset-Austausch Level 4 (Springer-Prefab, Runensteine & Lava-Shader)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **8** | **PBI-08** | `#8` | **3D-Asset-Austausch Level 5 (Büsten, Dolch der Wahrheit & Bibliothek)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **9** | **PBI-09** | `#9` | **Deduktions-Scratchpad-Matrix im Logikjournal** | Epic 9 | `US-26`, `FR-08.2` | **P2 (Kann)** | **3** | `PBI-01` | Erledigt |
| **10** | **PBI-10** | `#10` | **Bonuskammer: The Midnight Bridge (*Brücke & Fackel*, Headless-Logik + Tests)** | Epic 9 | `US-27`, `FR-08.3`, `NFR-01` | **P2 (Kann)** | **5** | — | Erledigt |
| **11** | **PBI-11** | `#11` | **Bonuskammer: The Midnight Bridge (3D-Szene, Fackel-Timer & Integrationstest)** | Epic 9 | `US-27`, `FR-08.3`, `NFR-02` | **P2 (Kann)** | **8** | `PBI-10` | Erledigt |
| **12** | **PBI-12** | `#12` | **Audio & Atmosphäre (Soundeffekte für Züge, Türen, Lava, Gewitter & Sieg)** | Polish | `NFR-03` | **P3 (Kann)** | **5** | — | Offen |
| **13** | **PBI-13** | `#13` | **Speicherstand & Fortschrittsfreischaltung im Hauptmenü** | Epic 1 | `US-01`, `FR-01.1` | **P3 (Kann)** | **3** | — | Erledigt |
| **14** | **PBI-14** | `#14` | **CI-Pipeline (GitHub Actions für Headless-Tests & Szenenvalidierung)** | Epic 8 | `US-23`, `US-24`, `NFR-02` | **P3 (Kann)** | **3** | — | Erledigt |

**Summe offener Aufwand:** `25 Story Points`

---

## 3. Detaillierte Beschreibung der Top-Prioritäten (Next Up)

### ~~PBI-01: In-Game-Logikjournal (`P1`, 5 SP)~~ ✅ Erledigt (`#1`)
- **Umgesetzt:** Headless-Modell `scripts/logic/JournalState.gd`, UI-Overlay `scenes/ui/Journal.tscn` + `scripts/ui/JournalController.gd` (Toggle über `[J]`/`[Tab]`, `Esc` oder HUD-Button), automatisches Protokollieren + Reset-Bereinigung in Level 2 & Level 5, verifiziert durch `tests/TestJournal.gd` (36 Checks).

### ~~PBI-02: First-Person-3D-Spielersteuerung & `Interactable3D` (`P1`, 8 SP)~~ ✅ Erledigt (`#2`)
- **Umgesetzt:** `scenes/player/Player.tscn`, `scripts/player/PlayerController.gd` (WASD, Sprint, Sprung, Mausblick mit `Esc`-Toggle, zentrierter `InteractionRay` & Kontext-HUD) und wiederverwendbare Komponente `scripts/core/Interactable3D.gd` (`[E] ...`, `interacted(player)`), verifiziert durch `tests/TestPlayerController.gd` (21 Checks).

### PBI-03 bis PBI-08: 3D-Asset-Austausch für Level 1–5 (`P1–P2`, je 5 SP)
- **Ziel:** Schrittweiser Ersatz der CSG-Greyboxen durch selbstenthaltene `.glb`-Modelle als vererbte `.tscn`-Prefabs unter `scenes/props/` (analog zu `scenes/props/Cat.tscn`).
- **Verbindliche Randbedingung:** Exakte Knotennamen (`Wolf`, `Goat`, `Cabbage`, `Raft`, `Door1..Door9`, `Hinge`, `ClickArea`, `Marker3D`) bleiben unverändert, sodass Controller und Integrationstests ohne Regression weiterlaufen.

### ~~PBI-10 (`#10`) & PBI-11 (`#11`): Bonuskammer — The Midnight Bridge (`P2`, 5 + 8 SP)~~ ✅ Erledigt
- **Umgesetzt:** `scripts/logic/MidnightBridgeLogic.gd` (Dijkstra-Solver, `tests/TestMidnightBridge.gd`, 45 Assertions) + 3D-Szene `scenes/levels/Level07_MidnightBridge.tscn`, `scripts/levels/Level07Controller.gd` (flackernde Fackel mit schrumpfendem Lichtradius, 15:00-Countdown, 3D-Picking, Undo, Auto-Solver), Hauptmenü-Eintrag & `tests/TestLevel07Scene.gd` (17 Checks).

---

## 4. Vorgeschlagene Sprint-Roadmap

| Sprint | Fokus | Geplante PBIs | Story Points |
| :--- | :--- | :--- | :---: |
| **Sprint 1–3** *(Abgeschlossen)* | Projekt-Setup, Hauptmenü, Level 1–5 (Headless-Logik, 3D-Greybox, Auto-Solver, Tests), Level 6 (`.glb`-Showcase), überlappungsfreie & dezente GUIs, SRS & User Stories | `DONE-01` bis `DONE-09` | — |
| **Sprint 4** *(Nächster Sprint)* | Spielkomfort & erster Asset-Meilenstein: Logikjournal, Level-1-3D-Assets, Start First-Person-Controller | `PBI-01`, `PBI-03`, `PBI-02` | **18 SP** |
| **Sprint 5** | Immersion & Optik: First-Person in Level 2, 3D-Assets für Level 2–4, Journal-Scratchpad | `PBI-04`, `PBI-05`, `PBI-06`, `PBI-07`, `PBI-09` | **23 SP** |
| **Sprint 6** | Inhaltserweiterung & Abschluss: 3D-Assets Level 5, Bonuskammer *Midnight Bridge*, Audio & CI | `PBI-08`, `PBI-10`, `PBI-11`, `PBI-12`, `PBI-13`, `PBI-14` | **24 SP** |

---

## 5. Abgeschlossene Meilensteine (Done Backlog)

| ID | Abgeschlossenes Feature | Verifikation |
| :--- | :--- | :--- |
| **DONE-01** | Godot-4-Setup (Forward+, Jolt Physics, Input Map) & Extraktion aller 21 Rätsel | `project.godot`, `story/logical_riddles.md` |
| **DONE-02** | Hauptmenü (`MainMenu.tscn`), `< Menu`-Button & automatische Level-Übergänge | `tests/TestMainMenu.gd`, `tests/TestLevel01Transition.gd` |
| **DONE-03** | Level 1 (*Wolf, Ziege & Kohlkopf*) mit 1-Klick-3D-Interaktion & BFS-Auto-Solver | `TestRiverCrossing.gd` (46), `TestLevel01Scene.gd` (14) |
| **DONE-04** | Level 2 (*Hall of Nine Portals*) mit Randomisierung, 3D-Türklicks & Auto-Solver | `TestNinePortals.gd` (30), `TestLevel02Scene.gd` (21) |
| **DONE-05** | Level 3 (*8-Queens*) mit Konfliktstrahlen & Vervollständigungs-Auto-Solver | `TestQueens.gd` (29), `TestLevel03Scene.gd` (15) |
| **DONE-06** | Level 4 (*Knight's Tour*) mit versinkenden Kacheln, Undo & Warnsdorff-Auto-Solver | `TestKnightsTour.gd` (26), `TestLevel04Scene.gd` (18) |
| **DONE-07** | Level 5 (*Dreadbury Manor*) mit FOL-Modellprüfer, 3 randomisierten Ausgängen (Agatha/Butler/Charles), spoilerfreier Fallanzeige, 8 dynamischen Hinweisen & Auto-Solver | `TestDreadbury.gd` (62), `TestLevel05Scene.gd` (22) |
| **DONE-08** | Level 6 (*The Cat Sanctuary*) als `.glb`-Prefab-Showcase mit Animation & Picking | `TestLevel06Scene.gd` (17) |
| **DONE-09** | Überlappungsfreies HUD-Layout, dezente Farbschemata pro Szene & SRS/User-Stories | Alle 6 Szenen validiert, `docs/requirements.md`, `docs/user_stories.md` |
| **DONE-10** | GitHub-Issues (`#1`–`#14`), Standard-Labels & Git-Branching-/PR-Workflow | `AGENTS.md`, `gh issue list -R eytschjey/seproject` |
| **DONE-11** | In-Game-Logikjournal (`PBI-01` / `#1`) mit Headless-`JournalState`, `[J]`/`[Tab]`-Overlay & Auto-Logging in Level 2 & 5 | `tests/TestJournal.gd` (36), `scenes/ui/Journal.tscn` validiert |
| **DONE-12** | First-Person-3D-Spielersteuerung (`Player.tscn`, `PlayerController.gd`) & `Interactable3D` (`PBI-02` / `#2`) | `tests/TestPlayerController.gd` (21), `scenes/player/Player.tscn` validiert |
| **DONE-13** | Integration First-Person (`Player.tscn` + `Interactable3D`-Türen) & Journal-Maus-Sync in Level 2 (`PBI-04` / `#4`) | `tests/TestLevel02Scene.gd` (31), `Level02_NinePortals.tscn` validiert |
| **DONE-14** | Deduktions-Scratchpad-Matrix (`✓`/`✗`) im Logikjournal für Level 2 (9×4) & Level 5 (3×4) (`PBI-09` / `#9`) | `tests/TestJournal.gd` (53), `scenes/ui/Journal.tscn` validiert |
| **DONE-15** | Bonuskammer *The Midnight Bridge* — Headless-Logik (`MidnightBridgeLogic.gd`), Undo & Dijkstra-Solver (`PBI-10` / `#10`) | `tests/TestMidnightBridge.gd` (45 Assertions) |
| **DONE-16** | Bonuskammer *The Midnight Bridge* — 3D-Szene (`Level07_MidnightBridge.tscn`), flackernde Fackel, Auto-Solver & Menü-Integration (`PBI-11` / `#11`) | `tests/TestLevel07Scene.gd` (17), `TestMainMenu.gd`, Szene validiert |
| **DONE-17** | Speicherstand (`ProgressStore.gd` via `user://save.cfg`) & Fortschrittsanzeige (`✓`, Counter & Reset) im Hauptmenü (`PBI-13` / `#13`) | `tests/TestProgressStore.gd` (19), `TestMainMenu.gd`, `MainMenu.tscn` validiert |
| **DONE-18** | GitHub Actions CI-Pipeline (`.github/workflows/ci.yml`) & lokaler Test-Runner (`scripts/ci/run_tests.sh`) für alle 18 Testsuiten & 11 Szenen (`PBI-14` / `#14`) | `./scripts/ci/run_tests.sh` (18 Testsuiten + 11 Szenen grün) |

---

## 6. Definition of Ready (DoR) & Definition of Done (DoD)

### Definition of Ready (DoR)
Ein PBI darf erst in einen Sprint aufgenommen werden, wenn:
- zugehörige Anforderungen (`FR-*` / `NFR-*`) und Akzeptanzkriterien (`US-*`) klar definiert sind,
- technische Abhängigkeiten identifiziert und aufgelöst oder im selben Sprint eingeplant sind,
- eine Aufwandsabschätzung in Story Points vorliegt.

### Definition of Done (DoD)
Ein PBI gilt erst als abgeschlossen, wenn:
1. **Model-View-Trennung eingehalten:** Neue Rätsellogik liegt rein Headless in `scripts/logic/` ohne 3D- oder UI-Abhängigkeiten.
2. **Automatisierte Tests grün:** Passende Unit- und/oder Szenen-Integrationstests (`tests/Test*.gd`) bestehen mit `0` Fehlern.
3. **Szenen validiert:** Jede geänderte `.tscn`-Datei besteht `godot --headless --validate --quit <Szene>`.
4. **HUD- & Asset-Standards erfüllt:** Keine 2D/3D-Label-Überlappungen; `.glb`-Assets nur über vererbte Prefabs in `scenes/props/`.
5. **Dokumentation, Git-Branch & Issue synchron:** `README.md`, `HANDOVER.md`, `AGENTS.md` und `docs/` sind aktualisiert; Änderungen wurden auf einem eigenen Branch entwickelt, per Pull Request in `main` integriert und das zugehörige GitHub-Issue nach Verifikation geschlossen.
