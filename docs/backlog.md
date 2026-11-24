# Product Backlog & Priorisierung — SEProject

**Projekt:** SEProject — Ein 3D-Logikrätsel-Abenteuer (Godot 4)  
**Verknüpfte Dokumente:** [`docs/requirements.md`](requirements.md) | [`docs/user_stories.md`](user_stories.md) | [`HANDOVER.md`](../HANDOVER.md)  
**Zuletzt aktualisiert:** 24. November 2026

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

| Rang | PBI-ID | Titel | Epic | Verknüpfte US / Req | Priorität | Story Points | Abhängigkeiten | Status |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **1** | **PBI-01** | **In-Game-Logikjournal (UI & automatisches Protokollieren)** | Epic 9 | `US-26`, `FR-08.2` | **P1 (Soll)** | **5** | — | Offen |
| **2** | **PBI-02** | **First-Person-3D-Spielersteuerung (`Player.tscn`) & `Interactable3D`** | Epic 9 | `US-25`, `FR-08.1` | **P1 (Soll)** | **8** | — | Offen |
| **3** | **PBI-03** | **3D-Asset-Austausch Level 1 (Wolf, Ziege, Kohlkopf, Floß & Flussufer)** | Epic 7 | `US-22`, `FR-08.4`, `NFR-05` | **P1 (Soll)** | **5** | — | Offen |
| **4** | **PBI-04** | **Integration First-Person & Journal in Level 2 (Tafelinspektion in 3D)** | Epic 3 / 9 | `US-25`, `US-26`, `FR-08.1` | **P2 (Soll)** | **5** | `PBI-01`, `PBI-02` | Offen |
| **5** | **PBI-05** | **3D-Asset-Austausch Level 2 (Türen, Rahmen, Tiger- & Prinzessinnen-Modelle)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **6** | **PBI-06** | **3D-Asset-Austausch Level 3 (Damenstatuen-Prefab, Marmor & Sonnenkristall)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **7** | **PBI-07** | **3D-Asset-Austausch Level 4 (Springer-Prefab, Runensteine & Lava-Shader)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **8** | **PBI-08** | **3D-Asset-Austausch Level 5 (Büsten, Dolch der Wahrheit & Bibliothek)** | Epic 7 | `US-22`, `FR-08.4` | **P2 (Soll)** | **5** | — | Offen |
| **9** | **PBI-09** | **Deduktions-Scratchpad-Matrix im Logikjournal** | Epic 9 | `US-26`, `FR-08.2` | **P2 (Kann)** | **3** | `PBI-01` | Offen |
| **10** | **PBI-10** | **Bonuskammer: The Midnight Bridge (*Brücke & Fackel*, Headless-Logik + Tests)** | Epic 9 | `US-27`, `FR-08.3`, `NFR-01` | **P2 (Kann)** | **5** | — | Offen |
| **11** | **PBI-11** | **Bonuskammer: The Midnight Bridge (3D-Szene, Fackel-Timer & Integrationstest)** | Epic 9 | `US-27`, `FR-08.3`, `NFR-02` | **P2 (Kann)** | **8** | `PBI-10` | Offen |
| **12** | **PBI-12** | **Audio & Atmosphäre (Soundeffekte für Züge, Türen, Lava, Gewitter & Sieg)** | Polish | `NFR-03` | **P3 (Kann)** | **5** | — | Offen |
| **13** | **PBI-13** | **Speicherstand & Fortschrittsfreischaltung im Hauptmenü** | Epic 1 | `US-01`, `FR-01.1` | **P3 (Kann)** | **3** | — | Offen |
| **14** | **PBI-14** | **CI-Pipeline (GitHub Actions für Headless-Tests & Szenenvalidierung)** | Epic 8 | `US-23`, `US-24`, `NFR-02` | **P3 (Kann)** | **3** | — | Offen |

**Summe offener Aufwand:** `65 Story Points`

---

## 3. Detaillierte Beschreibung der Top-Prioritäten (Next Up)

### PBI-01: In-Game-Logikjournal (`P1`, 5 SP)
- **Ziel:** Spieler können jederzeit mit `[J]` oder `[Tab]` ein übersichtliches Journal (`scenes/ui/Journal.tscn`) öffnen, das bereits gelesene Türinschriften aus Level 2 und Hinweise aus Level 5 automatisch sammelt.
- **Teilaufgaben:**
  1. Datenmodell `scripts/logic/JournalState.gd` (Headless) für Einträge pro Level.
  2. UI-Szene `scenes/ui/Journal.tscn` mit dezenter Farbgebung und Tastatur-Toggle (`journal`-Input-Action).
  3. Anbindung an `Level02Controller.gd` und `Level05Controller.gd`.
  4. Automatisierter Test `tests/TestJournal.gd`.

### PBI-02: First-Person-3D-Spielersteuerung & `Interactable3D` (`P1`, 8 SP)
- **Ziel:** Schrittweiser Übergang von fester Kamera zu freier 3D-Bewegung in den Kammern.
- **Teilaufgaben:**
  1. `scenes/player/Player.tscn` (`CharacterBody3D`, Kollisionskapsel, Kamera-Pivot, zentrierter `RayCast3D`).
  2. `scripts/player/PlayerController.gd` (WASD, Sprung, Mausblick mit `Esc`-Toggle).
  3. Wiederverwendbare Komponente `scripts/core/Interactable3D.gd` mit Kontext-Hinweis (`[E] ...`) und Signal `interacted(player)`.
  4. Automatisierter Test für Raycast-Erkennung und Signalauslösung.

### PBI-03 bis PBI-08: 3D-Asset-Austausch für Level 1–5 (`P1–P2`, je 5 SP)
- **Ziel:** Schrittweiser Ersatz der CSG-Greyboxen durch selbstenthaltene `.glb`-Modelle als vererbte `.tscn`-Prefabs unter `scenes/props/` (analog zu `scenes/props/Cat.tscn`).
- **Verbindliche Randbedingung:** Exakte Knotennamen (`Wolf`, `Goat`, `Cabbage`, `Raft`, `Door1..Door9`, `Hinge`, `ClickArea`, `Marker3D`) bleiben unverändert, sodass Controller und Integrationstests ohne Regression weiterlaufen.

### PBI-10 & PBI-11: Bonuskammer — The Midnight Bridge (`P2`, 5 + 8 SP)
- **Ziel:** Umsetzung des *Bridge & Torch*-Rätsels (1, 2, 5, 8 Minuten; max. 2 Personen; strenges 15-Minuten-Limit) nach strikter Model-View-Trennung:
  - Zuerst `scripts/logic/MidnightBridgeLogic.gd` + BFS/Dijkstra-Solver + `tests/TestMidnightBridge.gd`.
  - Danach `scenes/levels/Level07_MidnightBridge.tscn`, `Level07Controller.gd` (flackernde Fackel, 15:00-Countdown) + `tests/TestLevel07Scene.gd`.

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
| **DONE-07** | Level 5 (*Dreadbury Manor*) mit FOL-Modellprüfer, 3 randomisierten Ausgängen (Agatha/Butler/Charles), 8 dynamischen Hinweisen & Auto-Solver | `TestDreadbury.gd` (62), `TestLevel05Scene.gd` (20) |
| **DONE-08** | Level 6 (*The Cat Sanctuary*) als `.glb`-Prefab-Showcase mit Animation & Picking | `TestLevel06Scene.gd` (17) |
| **DONE-09** | Überlappungsfreies HUD-Layout, dezente Farbschemata pro Szene & SRS/User-Stories | Alle 6 Szenen validiert, `docs/requirements.md`, `docs/user_stories.md` |

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
5. **Dokumentation & Git synchron:** `README.md`, `HANDOVER.md`, `AGENTS.md` und `docs/` sind aktualisiert; Änderungen wurden gepullt, committet und gepusht.
