# User Stories & Akzeptanzkriterien — SEProject

**Projekt:** SEProject — Ein 3D-Logikrätsel-Abenteuer  
**Zuletzt aktualisiert:** 24. November 2026

Jede User Story folgt dem agilen Format (**Als** `<Rolle>` **möchte ich** `<Funktion>`, **damit** `<Nutzen>`) mit testbaren **Gegeben / Wenn / Dann**-Akzeptanzkriterien sowie Verweisen auf [`docs/requirements.md`](requirements.md).

---

## Epic 1: Navigation, Menü & Basis-HUD

### US-01: Level im Hauptmenü auswählen und starten
- **Story:** Als **Spieler** möchte ich im Start-Hauptmenü alle verfügbaren Level sehen und jedes freigeschaltete Level anklicken können, damit ich direkt in das gewünschte Rätsel einsteigen kann.
- **Zugehörige Anforderungen:** `FR-01.1`, `FR-01.4`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, das Spiel startet, **Wenn** `MainMenu.tscn` geladen ist, **Dann** werden Level 1–6 als aktive Schaltflächen zusammen mit einer `Quit`-Schaltfläche angezeigt.
  - **Gegeben**, ich befinde mich im Hauptmenü, **Wenn** ich auf eine Level-Schaltfläche klicke, **Dann** wird die zugehörige 3D-Levelszene sofort geladen.
  - **Gegeben**, ich befinde mich im Hauptmenü, **Wenn** ich auf `Quit` klicke, **Dann** wird die Anwendung sauber beendet.

### US-02: Aus jedem Level ins Hauptmenü zurückkehren
- **Story:** Als **Spieler** möchte ich in jedem Level eine sichtbare Schaltfläche `< Menu` haben, damit ich jederzeit das Rätsel wechseln oder das Spiel verlassen kann, ohne es neu zu starten.
- **Zugehörige Anforderungen:** `FR-01.2`, `NFR-03`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich befinde mich in einem beliebigen Level (Level 1–6), **Wenn** ich in die obere linke Ecke schaue, **Dann** ist eine Schaltfläche `< Menu` bei `(16, 16)` sichtbar, ohne das Header-Panel zu überlappen.
  - **Gegeben**, ich klicke auf `< Menu`, **Wenn** die Aktion ausgeführt wird, **Dann** kehrt das Spiel zu `MainMenu.tscn` zurück.

### US-03: Nahtloser Fortschritt zwischen den Leveln
- **Story:** Als **Spieler** möchte ich nach dem Lösen eines Rätsels eine Siegesmeldung sehen und automatisch in die nächste Kammer weitergeleitet werden, damit sich das Abenteuer zusammenhängend anfühlt.
- **Zugehörige Anforderungen:** `FR-01.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich löse Level 1, 2, 3, 4 oder 5, **Wenn** die Siegbedingung erfüllt ist, **Dann** erscheint ein Siegesbanner mit Hinweis auf die nächste Kammer und lädt nach 3–4 Sekunden automatisch das nächste Level.

### US-04: Gut lesbares, überlappungsfreies und dezentes HUD
- **Story:** Als **Spieler** möchte ich, dass das HUD jedes Levels dezente, atmosphärische Farben verwendet und weder Statustexte noch 3D-Beschriftungen überlappt, damit ich mich ganz auf das Rätsel konzentrieren kann.
- **Zugehörige Anforderungen:** `NFR-03`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich spiele ein beliebiges Level in Standardauflösung (`1152×648` mit `expand`), **Wenn** das HUD gerendert wird, **Dann** überlappt `SidePanel` niemals `HeaderPanel` oder `StatusLabel`, `BackToMenuButton` überlappt niemals `HeaderPanel`, und Banner verdecken keine 3D-`Label3D`-Tafeln.
  - **Gegeben**, ich wechsle zwischen Leveln, **Wenn** eine Szene geladen wird, **Dann** zeigt jedes Level sein eigenes dezentes, thematisches Farbschema mit klarem Textkontrast.

---

## Epic 2: Level 1 — The Ferryman's Crossing (*Wolf, Ziege & Kohlkopf*)

### US-05: Passagiere mit einem 3D-Klick laden, tauschen und abladen
- **Story:** Als **Spieler** möchte ich direkt auf Wolf, Ziege oder Kohlkopf in 3D klicken können, um sie mit einem Klick auf das Floß zu laden, zu tauschen oder abzuladen, damit sich die Steuerung direkt und intuitiv anfühlt.
- **Zugehörige Anforderungen:** `FR-02.1`, `FR-02.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, das Floß liegt am selben Ufer wie ein Objekt, **Wenn** ich dieses 3D-Objekt einmal anklicke, **Dann** springt es auf das Floß (und ein zuvor geladenes Objekt springt automatisch ans Ufer zurück).
  - **Gegeben**, ein Objekt befindet sich bereits auf dem Floß, **Wenn** ich es einmal anklicke, **Dann** wird es ohne Überfahrt wieder am aktuellen Ufer abgeladen.
  - **Gegeben**, ich fahre mit dem Mauszeiger über ein klickbares 3D-Objekt oder das Floß, **Wenn** der Zeiger die Hitbox betritt, **Dann** wechselt der Cursor zur Zeigehand und das Objekt skaliert leicht hoch.

### US-06: Fluss überqueren und klares Gefahren-Feedback erhalten
- **Story:** Als **Spieler** möchte ich das Floß durch Anklicken des Floßes oder der Schaltfläche `Row Raft` über den Fluss rudern und gewarnt werden, falls ich unverträgliche Passagiere allein lasse, damit ich die Rätselregeln verstehe.
- **Zugehörige Anforderungen:** `FR-02.2`, `FR-02.3`, `FR-02.4`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, das Floß liegt an einem Ufer, **Wenn** ich auf das Floß oder auf `Row Raft` klicke, **Dann** gleitet das Floß samt eventuellem Passagier flüssig ans gegenüberliegende Ufer.
  - **Gegeben**, ich rudere weg und lasse Wolf+Ziege oder Ziege+Kohlkopf allein zurück, **Wenn** die Überfahrt ausgewertet wird, **Dann** erklärt ein Fehlerbanner, was gefressen wurde, und fordert zum Klicken auf `Reset` auf.
  - **Gegeben**, alle drei Objekte erreichen sicher das Ostufer, **Wenn** das letzte Objekt abgeladen wird, **Dann** gilt das Rätsel als gelöst und wechselt zu Level 2.

### US-07: Level 1 zurücksetzen oder den BFS-Auto-Solver beobachten
- **Story:** Als **Spieler oder Prüfer** möchte ich Level 1 zurücksetzen oder einen automatischen BFS-Solver umschalten können, damit ich nach einem Fehler neu starten oder die optimale 7-Züge-Lösung verifizieren kann.
- **Zugehörige Anforderungen:** `FR-02.4`, `FR-02.5`, `NFR-04`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ein beliebiger Spielzustand (inkl. Fehlerzustand), **Wenn** ich `Reset` drücke, **Dann** kehren alle Objekte und das Floß ans Westufer zurück und alle Steuerungen sind wieder aktiv.
  - **Gegeben**, ich drücke `Auto-Solve (Debug)`, **Wenn** der Solver läuft, **Dann** führt er optimale Lade-, Überfahrt- und Abladeschritte automatisch aus; ein Klick auf `Stop Solver` oder ein 3D-Objekt pausiert ihn sofort.

---

## Epic 3: Level 2 — The Hall of Nine Portals (*Prinzessin & Tiger*)

### US-08: Türinschriften durch direktes Anklicken der 3D-Türen lesen
- **Story:** Als **Spieler** möchte ich jede der 9 Türen direkt in der 3D-Halle anklicken können, um ihre eingravierte Tafel zu lesen, damit ich die Aussagen zur Deduktion des Prinzessinnen-Raums sammeln kann.
- **Zugehörige Anforderungen:** `FR-03.1`, `FR-03.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich befinde mich in der Halle der neun Portale, **Wenn** ich auf eine 3D-Tür klicke, **Dann** wird deren Inschrift im `PlaquePanel` angezeigt, Tafel und Rahmen leuchten golden auf und `Open Door N` wird aktiviert.
  - **Gegeben**, ich klicke anschließend eine andere Tür an, **Wenn** die Auswahl wechselt, **Dann** bleibt die zuvor gelesene Tafel dezent bernsteinfarben markiert, damit ich bereits geprüfte Türen erkenne.

### US-09: Wiederspielbarkeit durch zufällige Raumbelegungen
- **Story:** Als **Spieler** möchte ich, dass Prinzessin, Tiger und leere Räume bei jedem Start und Reset neu gemischt und die Inschriften passend umgeschrieben werden, damit ich mir keine feste Türnummer merken kann.
- **Zugehörige Anforderungen:** `FR-03.2`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich starte Level 2 oder drücke `Reset`, **Wenn** die Halle initialisiert wird, **Dann** werden die Rauminhalte permutiert, alle 9 Inschriften dynamisch auf die neuen Raumnummern angepasst und genau ein Raum ist logisch eindeutig als Raum der Prinzessin deduzierbar.

### US-10: Ausgewählte Tür öffnen und Ergebnis erleben
- **Story:** Als **Spieler** möchte ich meine gewählte Tür öffnen und sehen, wie sie sich in 3D aufschwingt und entweder die Prinzessin, einen Tiger oder eine leere Kammer enthüllt, damit meine Deduktion spürbares visuelles Feedback hat.
- **Zugehörige Anforderungen:** `FR-03.4`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich wähle eine Tür und klicke `Open Door N`, **Wenn** sich dahinter ein Tiger befindet, **Dann** schwingt die Tür auf, rotes Licht erhellt die Nische und ein Fehlerbanner fordert zum Klicken auf `Reset` auf.
  - **Gegeben**, ich öffne einen leeren Raum, **Wenn** die Tür aufschwingt, **Dann** erscheint eine leere Kammer und ich kann weitere Türen prüfen und öffnen.
  - **Gegeben**, ich öffne die Tür der Prinzessin, **Wenn** die Tür aufschwingt, **Dann** erstrahlt die Prinzessin golden und das Siegesbanner leitet zu Level 3 weiter.

### US-11: Deduktiven Auto-Solver in Level 2 ausführen
- **Story:** Als **Prüfer** möchte ich eine Schaltfläche `Auto-Solve (Debug)` in Level 2, damit ich verifizieren kann, dass jede zufällige Anordnung lösbar ist und der Solver die richtige Tür öffnet.
- **Zugehörige Anforderungen:** `FR-03.5`, `NFR-04`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich klicke auf `Auto-Solve (Debug)`, **Wenn** der Solver läuft, **Dann** geht er schrittweise die uninspizierten Tafeln durch, deduziert den eindeutigen Raum der Prinzessin und öffnet diese Tür zum Lösen des Levels.

---

## Epic 4: Level 3 — The Sun Courtyard (*Das 8-Damen-Problem*)

### US-12: Damenstatuen auf dem $8 \times 8$-Innenhof platzieren und entfernen
- **Story:** Als **Spieler** möchte ich Damenstatuen über ein $8 \times 8$-Raster umschalten und sie auf dem 3D-Marmorbrett erscheinen sehen, damit ich verschiedene konfliktfreie Aufstellungen ausprobieren kann.
- **Zugehörige Anforderungen:** `FR-04.1`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, es stehen weniger als 8 Damen auf dem Brett, **Wenn** ich eine leere Zelle im $8 \times 8$-Raster anklicke, **Dann** erscheint eine 3D-Damenstatue auf der entsprechenden Marmorkachel und der Zähler erhöht sich (`Queens: N / 8`).
  - **Gegeben**, auf einer Zelle steht bereits eine Dame, **Wenn** ich sie erneut anklicke, **Dann** wird die Statue entfernt und der Zähler verringert sich.

### US-13: Echtzeit-Konfliktstrahlen zwischen bedrohenden Damen sehen
- **Story:** Als **Spieler** möchte ich, dass sich bedrohende Damen karmesinrot färben und Laserstrahlen zwischen ihnen erscheinen, damit ich Zeilen-, Spalten- und Diagonalkonflikte sofort erkenne.
- **Zugehörige Anforderungen:** `FR-04.2`, `FR-04.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, zwei Damen teilen sich eine Zeile, Spalte oder Diagonale, **Wenn** sie platziert werden, **Dann** färben sich beide Statuen karmesinrot, ein roter 3D-Strahl verbindet sie und ihre HUD-Zellen werden rot markiert.
  - **Gegeben**, ich entferne die konfliktauslösende Dame, **Wenn** keine Angriffe mehr bestehen, **Dann** verschwindet der Strahl und sichere Damen leuchten golden.
  - **Gegeben**, 8 Damen stehen ohne Konflikt auf dem Brett, **Wenn** die 8. Dame gesetzt wird, **Dann** färben sich alle Statuen grün und das Siegesbanner leitet zu Level 4 weiter.

### US-14: 8-Damen-Rätsel automatisch lösen oder vervollständigen
- **Story:** Als **Spieler oder Prüfer** möchte ich eine Schaltfläche `Auto-Solve (Debug)`, die meine gültige Teilaufstellung vervollständigt (oder bei Bedarf neu startet und löst), damit ich den Constraint-Solver testen kann.
- **Zugehörige Anforderungen:** `FR-04.4`, `NFR-04`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich drücke `Auto-Solve (Debug)`, **Wenn** der Solver läuft, **Dann** platziert er schrittweise Damen bis zu einer gültigen 8-Damen-Lösung; ein Klick auf `Stop Solver` pausiert die Platzierung sofort.

---

## Epic 5: Level 4 — The Knight's Chasm (*Das Springerproblem*)

### US-15: Mit gültigen Springerzügen über schwebende Runenkacheln springen
- **Story:** Als **Spieler** möchte ich gültige Springerzüge klar hervorgehoben sehen, während besuchte Kacheln hinter mir in die Lava sinken, damit ich die 64-Kacheln-Schlucht präzise überqueren kann.
- **Zugehörige Anforderungen:** `FR-05.1`, `FR-05.2`, `FR-05.4`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, der Springer steht auf einer Kachel, **Wenn** ich das 3D-Brett und das HUD-Raster betrachte, **Dann** sind nur legale, unbesuchte Springerzüge aktiviert und stahlblau hervorgehoben, während das aktuelle Feld ocker-golden markiert ist.
  - **Gegeben**, ich klicke eine gültige Zielzelle an, **Wenn** der Springer springt, **Dann** fliegt der 3D-Springer im Bogen auf das neue Feld, das vorherige Feld sinkt in die Lava und der Zähler aktualisiert sich (`Visits: N / 64`).
  - **Gegeben**, ich erreiche `64 / 64` Besuche, **Wenn** der letzte Sprung abgeschlossen ist, **Dann** erheben sich alle 64 Kacheln zu einer leuchtenden Brücke und Level 5 startet.

### US-16: Sprünge rückgängig machen und Sackgassen verlassen
- **Story:** Als **Spieler** möchte ich vorherige Sprünge rückgängig machen können, wenn ich in eine Sackgasse gerate, damit ich zurückgehen kann, ohne die gesamte 64-Felder-Tour neu zu beginnen.
- **Zugehörige Anforderungen:** `FR-05.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich habe mindestens einen Sprung ausgeführt, **Wenn** ich `Undo Last Jump` drücke, **Dann** kehrt der Springer auf die vorherige Kachel zurück, diese steigt wieder aus der Lava auf und der Besuchszähler sinkt um 1.
  - **Gegeben**, es gibt vor 64 Besuchen keine gültigen Züge mehr, **Wenn** die Sackgasse eintritt, **Dann** weist ein Fehlerbanner darauf hin, einen Sprung rückgängig zu machen oder `Reset` zu drücken.

### US-17: Warnsdorff-Auto-Solver für die komplette Tour ausführen
- **Story:** Als **Prüfer** möchte ich eine Schaltfläche `Auto-Solve (Debug)` in Level 4, damit ich überprüfen kann, dass die 64-Felder-Springertour vom aktuellen Pfad oder von A1 aus vollständig abgeschlossen wird.
- **Zugehörige Anforderungen:** `FR-05.5`, `NFR-04`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich drücke `Auto-Solve (Debug)`, **Wenn** der Solver läuft, **Dann** absolviert der Springer schrittweise eine vollständige 64-Felder-Tour mit voller Pause-/Fortsetzen-Funktion über `Stop Solver`.

---

## Epic 6: Level 5 — The Night at Dreadbury Manor (*Wer tötete Tante Agatha?*)

### US-18: Herrenhaus-Hinweise und formale Logikformeln über verschiedene Fälle untersuchen
- **Story:** Als **Spieler** möchte ich alle 8 Hinweise des aktuell generierten Falls untersuchen und sowohl die erzählerischen Aussagen als auch die prädikatenlogischen Formeln sehen, damit ich bei jedem Durchlauf den jeweiligen Täter (Tante Agatha, den Butler oder Charles) neu deduzieren kann.
- **Zugehörige Anforderungen:** `FR-06.1`, `FR-06.2`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich starte Level 5 oder drücke `Reset`, **Wenn** der Fall geladen wird, **Dann** wird einer von 3 logisch eindeutigen Fällen (`The Tragic Secret`, `The Servant's Grudge`, `The Heir's Vendetta`) mit passenden Hinweisen aktiviert (bei `Reset` stets ein anderer Fall als zuvor).
  - **Gegeben**, ich klicke eine Hinweis-Schaltfläche (`1..8`) an, **Wenn** der Hinweis untersucht wird, **Dann** zeigt `CluePanel` Titel, Fundort, Text und formale FOL-Formel des aktiven Falls, die Schaltfläche erhält ein `✓`, die 3D-Schriftrolle wechselt ihre Farbe und `Clues Examined: N / 8` wird aktualisiert.

### US-19: Verdächtigen am Altar anklagen und bei Fehlern den Widerspruch sehen
- **Story:** Als **Spieler** möchte ich eine Verdächtigen-Büste auswählen und den Dolch der Wahrheit platzieren, wobei mir bei einer falschen Anklage der genaue logische Widerspruch des aktuellen Falls erklärt wird, damit ich meinen Denkfehler nachvollziehen kann.
- **Zugehörige Anforderungen:** `FR-06.3`, `FR-06.4`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, es ist noch kein Verdächtiger ausgewählt, **Wenn** ich die Altar-Steuerung betrachte, **Dann** ist `Place Dagger of Truth` deaktiviert.
  - **Gegeben**, ich wähle einen im aktuellen Fall unschuldigen Verdächtigen aus und platziere den Dolch, **Wenn** die Anklage geprüft wird, **Dann** senkt sich der Dolch auf die Büste, die Büste färbt sich rot und das Fehlerbanner erklärt den exakten logischen Widerspruch (`contradiction_for()`).

### US-20: Das Rätsel lösen und das fallspezifische Finale auslösen
- **Story:** Als **Spieler** möchte ich, dass das Anklagen des wahren Täters das passende versteckte Beweisstück hinter dessen Büste enthüllt und das Gewitter auflöst, damit jeder der drei möglichen Ausgänge eine eigene Auflösung bietet.
- **Zugehörige Anforderungen:** `FR-06.5`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, ich wähle den wahren Täter des aktiven Falls aus und platziere den Dolch der Wahrheit (manuell oder per `Auto-Solve (Debug)`), **Wenn** die Anklage ausgewertet wird, **Dann** erscheint das versteckte 3D-Beweisstück hinter der Büste des Täters, das Licht wechselt auf die ausgangsspezifische Morgenbeleuchtung und das Siegesbanner verkündet die passende Auflösung (Abschiedsbrief für Agatha, Giftbuch für den Butler oder gefälschtes Testament für Charles).

---

## Epic 7: Level 6 — The Cat Sanctuary & 3D-Asset-Pipeline

### US-21: Mit dem 3D-Katzen-Exponat interagieren
- **Story:** Als **Spieler** möchte ich das 3D-Katzenmodell in Level 6 drehen, animieren und streicheln können, damit ich nach der Hauptkampagne das interaktive 3D-Showcase genießen kann.
- **Zugehörige Anforderungen:** `FR-07.1`, `FR-07.2`, `FR-07.3`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, Level 6 ist geladen, **Wenn** ich auf `Pause Spin` / `Resume Spin` klicke, **Dann** wird die Drehung des Sockels entsprechend umgeschaltet.
  - **Gegeben**, ich klicke auf `Play Animation` / `Pause Animation`, **Dann** wird die Skelettanimation (`Take 001`) der Katze umgeschaltet.
  - **Gegeben**, ich klicke die 3D-Katze oder `Pet Cat` 5-mal an, **Wenn** das 5. Streicheln erfolgt, **Dann** hüpft die Katze bei jedem Streicheln und das Banner `PURR-FECTION ACHIEVED` erscheint.

### US-22: Greybox-Meshes durch vererbte `.glb`-Prefabs ersetzen
- **Story:** Als **Entwickler** möchte ich `.glb`-Modelle als vererbte `.tscn`-Prefabs unter `scenes/props/` einbinden und dabei exakte Knotennamen sowie `ClickArea`- und `Marker3D`-Kindknoten beibehalten, damit grafische Upgrades weder Controller noch Tests brechen.
- **Zugehörige Anforderungen:** `FR-08.4`, `NFR-05`
- **Status:** Geplant (Pipeline in Level 6 etabliert; Level 1–5 ausstehend)
- **Akzeptanzkriterien:**
  - **Gegeben**, ein neues `.glb`-Asset wird unter `assets/models/` abgelegt und in `scenes/props/<Prop>.tscn` eingebunden, **Wenn** es in eine Levelszene eingesetzt wird, **Dann** bestehen `godot --headless --validate --quit` und alle bestehenden Unit- und Integrationstests ohne Änderungen am Controller.

---

## Epic 8: Entwickler- & QA-Workflow

### US-23: Headless-Unit-Tests für reine Rätsellogik ausführen
- **Story:** Als **Entwickler** möchte ich automatisierte Headless-Tests für jede Rätsellogik-Klasse über die Kommandozeile ausführen können, damit ich die mathematische Korrektheit ohne Öffnen des Godot-Editors prüfen kann.
- **Zugehörige Anforderungen:** `NFR-01`, `NFR-02`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, eine Headless-Umgebung ohne GPU/Display, **Wenn** ich `godot --headless -s res://tests/Test<Logic>.gd` ausführe, **Dann** laufen alle Assertions durch und beenden sich mit Exit-Code `0` bei Erfolg bzw. `1` bei Fehler.

### US-24: 3D-Szenen und UI-Abläufe Headless validieren
- **Story:** Als **QA / Entwickler** möchte ich automatisierte Szenen-Integrationstests und Syntax-Validierungsbefehle für alle Level, damit fehlerhafte Knotenpfade, fehlende Ressourcen oder UI-Regressionen vor dem Push erkannt werden.
- **Zugehörige Anforderungen:** `NFR-02`, `NFR-06`
- **Status:** Implementiert
- **Akzeptanzkriterien:**
  - **Gegeben**, eine Änderung an einer `.tscn`- oder Controller-`.gd`-Datei, **Wenn** ich `godot --headless --validate --quit <scene>` und `godot --headless -s res://tests/TestLevel0XScene.gd` ausführe, **Dann** lädt die Szene fehlerfrei und alle Integrationsprüfungen bestehen.

---

## Epic 9: Geplante Erweiterungen (Backlog)

### US-25: Kammern in der First-Person-3D-Perspektive erkunden
- **Story:** Als **Spieler** möchte ich mich per WASD und Mausblick in der Ego-Perspektive durch die 3D-Kammern bewegen und mit `[E]` mit Tafeln, Hebeln und Statuen interagieren können, damit das Spiel wie ein immersives 3D-Abenteuer wirkt.
- **Zugehörige Anforderungen:** `FR-08.1`
- **Status:** Geplant
- **Akzeptanzkriterien:**
  - **Gegeben**, `Player.tscn` ist in einem Level aktiv, **Wenn** ich mich mit WASD bewege, mit der Maus umschaue und ein `Interactable3D` anvisiere, **Dann** erscheint eine kontextbezogene Eingabeaufforderung (z. B. `[E] Inspect Plaque`) und Drücken von `E` löst die Interaktion aus.

### US-26: Deduktionen im In-Game-Logikjournal festhalten
- **Story:** Als **Spieler** möchte ich mit `[J]` oder `[Tab]` ein In-Game-Journal öffnen können, das alle entdeckten Tafeln und Hinweise automatisch sammelt, damit ich logische Aussagen ohne Stift und Papier abgleichen kann.
- **Zugehörige Anforderungen:** `FR-08.2`
- **Status:** Geplant
- **Akzeptanzkriterien:**
  - **Gegeben**, ich habe Türtafeln in Level 2 oder Hinweise in Level 5 untersucht, **Wenn** ich `J` oder `Tab` drücke, **Dann** öffnet sich das Journal-Overlay mit allen entdeckten Einträgen und einer optionalen Deduktionsmatrix.

### US-27: Die Bonuskammer — The Midnight Bridge spielen
- **Story:** Als **Spieler** möchte ich eine optionale Bonuskammer auf Basis des *Brücken-und-Fackel-Problems* spielen können, damit ich meine zeitkritische Ressourcenplanung gegen ein 15-Minuten-Fackellimit testen kann.
- **Zugehörige Anforderungen:** `FR-08.3`
- **Status:** Geplant
- **Akzeptanzkriterien:**
  - **Gegeben**, vier Reisende mit Überquerungszeiten von 1, 2, 5 und 8 Minuten, **Wenn** ich Paare mit der Fackel über die Brücke führe, **Dann** erhöht sich die verstrichene Zeit um die Geschwindigkeit der langsameren Person, ein Überschreiten von 15 Minuten lässt das Rätsel scheitern, und das Überqueren aller vier in $\le 15$ Minuten löst es.
