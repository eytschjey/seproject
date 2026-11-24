class_name DreadburyLogic
extends RefCounted

## Pure logical model of the Dreadbury Mansion Mystery ("Who Killed Aunt Agatha?").
## Base riddle source: Theoretical Computer Science: Logic & Puzzles, Chapter 6, Section 6.5.2.
##
## Supports 3 mathematically verified first-order logic cases (different outcomes):
##  * Case.AGATHA  (0): Classic case — Aunt Agatha killed herself.
##  * Case.BUTLER  (1): The Butler's Revenge — The Butler killed Aunt Agatha.
##  * Case.CHARLES (2): Charles's Vendetta — Charles killed Aunt Agatha.
##
## Domain of residents: D = { AGATHA (0), BUTLER (1), CHARLES (2) }.
## Predicates:
##  * killed(x, AGATHA)
##  * hates(x, y)
##  * richer(x, AGATHA)

enum Suspect { AGATHA, BUTLER, CHARLES }
enum Case { AGATHA, BUTLER, CHARLES }

const SUSPECT_COUNT: int = 3
const CASE_COUNT: int = 3
const CLUE_COUNT: int = 8

const SUSPECT_NAMES: Array[String] = [
	"Aunt Agatha",
	"The Butler",
	"Charles",
]

const CASE_TITLES: Array[String] = [
	"The Night at Dreadbury Manor",
	"The Night at Dreadbury Manor",
	"The Night at Dreadbury Manor",
]

const VICTORY_TITLES: Array[String] = [
	"The Tragic Secret",
	"The Servant's Grudge",
	"The Heir's Vendetta",
]

## Canonical (Case.AGATHA) clues kept as a constant for backward compatibility.
const CLUES: Array[Dictionary] = [
	{
		"title": "Coroner's Journal",
		"location": "Library Desk",
		"text": "A killer always hates their victim.",
		"formula": "∀x,y: killed(x,y) → hates(x,y)",
	},
	{
		"title": "Charles's Letter",
		"location": "Writing Bureau",
		"text": "Charles hates no one that Aunt Agatha hates.",
		"formula": "∀x: hates(Agatha,x) → ¬hates(Charles,x)",
	},
	{
		"title": "Diary of Agatha",
		"location": "Armchair Side Table",
		"text": "Agatha hates everyone except the butler.",
		"formula": "∀x: x ≠ Butler ↔ hates(Agatha,x)",
	},
	{
		"title": "Financial Ledger",
		"location": "Servants' Quarters",
		"text": "A killer is never richer than their victim.",
		"formula": "∀x,y: killed(x,y) → ¬richer(x,y)",
	},
	{
		"title": "Butler's Rule",
		"location": "Pantry Plaque",
		"text": "The butler hates everyone not richer than Aunt Agatha.",
		"formula": "∀x: ¬richer(x, Agatha) → hates(Butler,x)",
	},
	{
		"title": "Butler's Confession",
		"location": "Foyer Testimony",
		"text": "The butler hates everyone Aunt Agatha hates.",
		"formula": "∀x: hates(Agatha,x) → hates(Butler,x)",
	},
	{
		"title": "Psychological Profile",
		"location": "Study Bookshelf",
		"text": "No one in the mansion hates everyone.",
		"formula": "∀x ∃y: ¬hates(x,y)",
	},
	{
		"title": "Estate Will",
		"location": "Mantelpiece Safe",
		"text": "Agatha, the butler, and Charles are the only residents of Dreadbury Mansion, and Agatha is not the butler.",
		"formula": "D = {Agatha, Butler, Charles} ∧ Agatha ≠ Butler",
	},
]

const CASE_CLUES: Array = [
	# Case 0: Case.AGATHA (Classic)
	CLUES,
	# Case 1: Case.BUTLER (The Servant's Grudge)
	[
		{
			"title": "Coroner's Journal",
			"location": "Library Desk",
			"text": "A killer always hates their victim.",
			"formula": "∀x,y: killed(x,y) → hates(x,y)",
		},
		{
			"title": "Charles's Letter",
			"location": "Writing Bureau",
			"text": "Charles hates everyone that Aunt Agatha hates.",
			"formula": "∀x: hates(Agatha,x) → hates(Charles,x)",
		},
		{
			"title": "Diary of Agatha",
			"location": "Armchair Side Table",
			"text": "Agatha hates everyone except herself.",
			"formula": "∀x: x ≠ Agatha ↔ hates(Agatha,x)",
		},
		{
			"title": "Financial Ledger",
			"location": "Servants' Quarters",
			"text": "A killer is never richer than their victim.",
			"formula": "∀x,y: killed(x,y) → ¬richer(x,y)",
		},
		{
			"title": "Butler's Rule",
			"location": "Pantry Plaque",
			"text": "The butler hates everyone not richer than Aunt Agatha.",
			"formula": "∀x: ¬richer(x, Agatha) → hates(Butler,x)",
		},
		{
			"title": "Butler's Confession",
			"location": "Foyer Testimony",
			"text": "The butler hates no one who is richer than Aunt Agatha.",
			"formula": "∀x: richer(x, Agatha) → ¬hates(Butler,x)",
		},
		{
			"title": "Psychological Profile",
			"location": "Study Bookshelf",
			"text": "No one in the mansion hates everyone.",
			"formula": "∀x ∃y: ¬hates(x,y)",
		},
		{
			"title": "Estate Will",
			"location": "Mantelpiece Safe",
			"text": "Agatha, the butler, and Charles are the only residents of Dreadbury Mansion, and all three are distinct.",
			"formula": "D = {Agatha, Butler, Charles}",
		},
	],
	# Case 2: Case.CHARLES (The Heir's Vendetta)
	[
		{
			"title": "Coroner's Journal",
			"location": "Library Desk",
			"text": "A killer always hates their victim.",
			"formula": "∀x,y: killed(x,y) → hates(x,y)",
		},
		{
			"title": "Charles's Letter",
			"location": "Writing Bureau",
			"text": "Charles hates everyone who hates Charles.",
			"formula": "∀x: hates(x, Charles) → hates(Charles,x)",
		},
		{
			"title": "Diary of Agatha",
			"location": "Armchair Side Table",
			"text": "Agatha hates only Charles.",
			"formula": "∀x: x = Charles ↔ hates(Agatha,x)",
		},
		{
			"title": "Financial Ledger",
			"location": "Servants' Quarters",
			"text": "A killer is never richer than their victim.",
			"formula": "∀x,y: killed(x,y) → ¬richer(x,y)",
		},
		{
			"title": "Butler's Rule",
			"location": "Pantry Plaque",
			"text": "The butler hates everyone not richer than Aunt Agatha.",
			"formula": "∀x: ¬richer(x, Agatha) → hates(Butler,x)",
		},
		{
			"title": "Butler's Confession",
			"location": "Foyer Testimony",
			"text": "The butler hates everyone Aunt Agatha hates.",
			"formula": "∀x: hates(Agatha,x) → hates(Butler,x)",
		},
		{
			"title": "Psychological Profile",
			"location": "Study Bookshelf",
			"text": "No one in the mansion hates everyone.",
			"formula": "∀x ∃y: ¬hates(x,y)",
		},
		{
			"title": "Estate Will",
			"location": "Mantelpiece Safe",
			"text": "Agatha, the butler, and Charles are the only residents of Dreadbury Mansion, and all three are distinct.",
			"formula": "D = {Agatha, Butler, Charles}",
		},
	],
]

signal state_changed(discovered_clues: Array, selected_clue: int, selected_suspect: int)
signal clue_inspected(clue_index: int, clue: Dictionary)
signal accusation_made(suspect: int, is_correct: bool, explanation: String)
signal move_executed(description: String)
signal puzzle_failed(reason: String)
signal puzzle_solved()

var active_case: int = -1
var discovered_clues: Array[bool] = []
var selected_clue: int = -1
var selected_suspect: int = -1
var accused_suspect: int = -1
var is_solved: bool = false
var is_failed: bool = false

## Optional `initial_case` (0..2) locks a deterministic case; -1 picks a random outcome.
func _init(initial_case: int = -1) -> void:
	reset(initial_case)

## Reset investigation state. If `next_case` is -1, picks a different random outcome from the current one.
func reset(next_case: int = -1) -> void:
	if next_case >= 0 and next_case < CASE_COUNT:
		active_case = next_case
	else:
		var choices: Array[int] = []
		for c in CASE_COUNT:
			if c != active_case:
				choices.append(c)
		active_case = choices[randi() % choices.size()]
	discovered_clues = []
	for i in CLUE_COUNT:
		discovered_clues.append(false)
	selected_clue = -1
	selected_suspect = -1
	accused_suspect = -1
	is_solved = false
	is_failed = false
	state_changed.emit(discovered_clues.duplicate(), selected_clue, selected_suspect)

func get_clue(index: int) -> Dictionary:
	return clue_info(index, active_case)

func get_case_title() -> String:
	return CASE_TITLES[active_case]

## Deduce the unique killer for the currently active case via first-order model checking.
func solve_killer() -> int:
	var candidates := killer_candidates(active_case)
	return candidates[0] if not candidates.is_empty() else -1

func get_explanation(suspect: int) -> String:
	return contradiction_for(suspect, active_case)

func get_victory_message() -> String:
	return victory_message_for(active_case)

func is_clue_discovered(index: int) -> bool:
	if index < 0 or index >= CLUE_COUNT:
		return false
	return discovered_clues[index]

func discovered_count() -> int:
	var count := 0
	for d in discovered_clues:
		if d:
			count += 1
	return count

func all_clues_discovered() -> bool:
	return discovered_count() == CLUE_COUNT

## Inspect a clue (0..CLUE_COUNT-1). Marks it as discovered and selects it.
func inspect_clue(index: int) -> bool:
	if is_solved or is_failed:
		return false
	if index < 0 or index >= CLUE_COUNT:
		return false
	discovered_clues[index] = true
	selected_clue = index
	var clue: Dictionary = get_clue(index)
	clue_inspected.emit(index, clue)
	move_executed.emit("Inspected %s (%d/%d clues examined)." % [clue["title"], discovered_count(), CLUE_COUNT])
	state_changed.emit(discovered_clues.duplicate(), selected_clue, selected_suspect)
	return true

## Select a suspect bust (0..SUSPECT_COUNT-1) at the Accusation Altar.
func select_suspect(suspect: int) -> bool:
	if is_solved or is_failed:
		return false
	if suspect < 0 or suspect >= SUSPECT_COUNT:
		return false
	selected_suspect = suspect
	move_executed.emit("Selected %s's bust at the Accusation Altar." % suspect_name(suspect))
	state_changed.emit(discovered_clues.duplicate(), selected_clue, selected_suspect)
	return true

## Place the Dagger of Truth on the given suspect's bust (0..SUSPECT_COUNT-1).
func accuse(suspect: int) -> bool:
	if is_solved or is_failed:
		return false
	if suspect < 0 or suspect >= SUSPECT_COUNT:
		return false
	selected_suspect = suspect
	accused_suspect = suspect
	var explanation := get_explanation(suspect)
	var true_killer := solve_killer()
	if suspect == true_killer:
		is_solved = true
		accusation_made.emit(suspect, true, explanation)
		move_executed.emit("Placed the Dagger of Truth on %s's bust — the truth is revealed!" % suspect_name(suspect))
		state_changed.emit(discovered_clues.duplicate(), selected_clue, selected_suspect)
		puzzle_solved.emit()
	else:
		is_failed = true
		accusation_made.emit(suspect, false, explanation)
		move_executed.emit("Accused %s — logical contradiction!" % suspect_name(suspect))
		state_changed.emit(discovered_clues.duplicate(), selected_clue, selected_suspect)
		puzzle_failed.emit(explanation)
	return true

## Place the Dagger of Truth on the currently selected suspect's bust.
func accuse_selected() -> bool:
	if selected_suspect < 0:
		return false
	return accuse(selected_suspect)

static func suspect_name(suspect: int) -> String:
	if suspect < 0 or suspect >= SUSPECT_COUNT:
		return "Unknown"
	return SUSPECT_NAMES[suspect]

static func clue_info(index: int, case_id: int = Case.AGATHA) -> Dictionary:
	var cid: int = clampi(case_id, 0, CASE_COUNT - 1)
	return CASE_CLUES[cid][index]

static func victory_message_for(case_id: int) -> String:
	match case_id:
		Case.AGATHA:
			return (
				"MYSTERY SOLVED! (%s)\n" % VICTORY_TITLES[Case.AGATHA]
				+ "Aunt Agatha killed herself! Placing the Dagger of Truth on Agatha's bust\n"
				+ "reveals her hidden suicide note. The storm clears and the manor doors swing open!"
			)
		Case.BUTLER:
			return (
				"MYSTERY SOLVED! (%s)\n" % VICTORY_TITLES[Case.BUTLER]
				+ "The Butler poisoned Aunt Agatha! Placing the Dagger of Truth on the Butler's bust\n"
				+ "reveals his hidden confession & poison ledger. Dawn breaks as the curse lifts!"
			)
		Case.CHARLES:
			return (
				"MYSTERY SOLVED! (%s)\n" % VICTORY_TITLES[Case.CHARLES]
				+ "Charles murdered Aunt Agatha! Placing the Dagger of Truth on Charles's bust\n"
				+ "reveals his forged will and vendetta letter. Morning sunlight floods Dreadbury Manor!"
			)
	return "MYSTERY SOLVED!"

## Logical explanation of why a suspect can or cannot be the killer in the given case.
static func contradiction_for(suspect: int, case_id: int = Case.AGATHA) -> String:
	match case_id:
		Case.AGATHA:
			match suspect:
				Suspect.CHARLES:
					return "Contradiction! If Charles killed Agatha, he must hate her. But Agatha hates everyone except the butler (including herself), and Charles hates no one that Agatha hates — so Charles cannot hate Agatha!"
				Suspect.BUTLER:
					return "Contradiction! The butler is not richer than Agatha if he is the killer, so by the Butler's Rule he hates himself. Since he also hates everyone Agatha hates (Agatha and Charles), the butler would hate everyone — violating 'No one hates everyone'!"
				Suspect.AGATHA:
					return "Proven by elimination! Neither Charles nor the Butler can be the killer without contradiction. Aunt Agatha hated herself, was not richer than herself, and took her own life."
		Case.BUTLER:
			match suspect:
				Suspect.AGATHA:
					return "Contradiction! A killer always hates their victim, yet Agatha's Diary states she hates everyone except herself — so Aunt Agatha cannot hate herself!"
				Suspect.CHARLES:
					return "Contradiction! Agatha hates the Butler and Charles, and Charles hates everyone Agatha hates. If Charles also hated Agatha (as her killer), Charles would hate everyone — violating 'No one hates everyone'!"
				Suspect.BUTLER:
					return "Proven by elimination! Neither Agatha nor Charles can hate Agatha without contradiction. The Butler is not richer than Agatha, hates Agatha and himself (but not the wealthier Charles), and committed the murder."
		Case.CHARLES:
			match suspect:
				Suspect.AGATHA:
					return "Contradiction! A killer always hates their victim, yet Agatha's Diary states she hates only Charles — so Aunt Agatha does not hate herself!"
				Suspect.BUTLER:
					return "Contradiction! The Butler hates Agatha (who isn't richer than herself) and hates Charles (whom Agatha hates). If the Butler were the killer, he would not be richer than Agatha and would also hate himself — hating everyone and violating 'No one hates everyone'!"
				Suspect.CHARLES:
					return "Proven by elimination! Agatha does not hate herself, and the Butler must be richer than Agatha to avoid hating everyone. Because Agatha hates Charles, Charles hates Agatha in return and killed her."
	return "Invalid suspect."

# ---------------------------------------------------------------------------
# Static first-order model checker & solver
# ---------------------------------------------------------------------------

## Evaluate whether a first-order interpretation satisfies all Dreadbury Mansion axioms for `case_id`.
## - `killer`: int in 0..2 (who killed AGATHA)
## - `hates`: Array of 3 Arrays of 3 bools, where `hates[x][y]` means resident x hates resident y
## - `richer_than_agatha`: Array of 3 bools, where `richer_than_agatha[x]` means resident x is richer than AGATHA
static func is_consistent_model(killer: int, hates: Array, richer_than_agatha: Array, case_id: int = Case.AGATHA) -> bool:
	if killer < 0 or killer >= SUSPECT_COUNT:
		return false
	if case_id < 0 or case_id >= CASE_COUNT:
		return false
	if hates.size() != SUSPECT_COUNT or richer_than_agatha.size() != SUSPECT_COUNT:
		return false
	for row in hates:
		if not (row is Array) or row.size() != SUSPECT_COUNT:
			return false

	# Irreflexivity of "richer than": Agatha cannot be richer than herself.
	if richer_than_agatha[Suspect.AGATHA]:
		return false

	# Clue 1 (Coroner's Journal): A killer always hates their victim.
	if not hates[killer][Suspect.AGATHA]:
		return false

	# Clue 4 (Financial Ledger): A killer is never richer than their victim.
	if richer_than_agatha[killer]:
		return false

	# Clue 5 (Butler's Rule): The butler hates everyone not richer than Aunt Agatha.
	for x in SUSPECT_COUNT:
		if not richer_than_agatha[x] and not hates[Suspect.BUTLER][x]:
			return false

	# Clue 7 (Psychological Profile): No one in the mansion hates everyone.
	for x in SUSPECT_COUNT:
		var hates_all := true
		for y in SUSPECT_COUNT:
			if not hates[x][y]:
				hates_all = false
				break
		if hates_all:
			return false

	# Case-specific Clues 2, 3, and 6:
	match case_id:
		Case.AGATHA:
			# Clue 2: Charles hates no one that Aunt Agatha hates.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] and hates[Suspect.CHARLES][x]:
					return false
			# Clue 3: Agatha hates everyone except the butler.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] != (x != Suspect.BUTLER):
					return false
			# Clue 6: The butler hates everyone Aunt Agatha hates.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] and not hates[Suspect.BUTLER][x]:
					return false

		Case.BUTLER:
			# Clue 2: Charles hates everyone that Aunt Agatha hates.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] and not hates[Suspect.CHARLES][x]:
					return false
			# Clue 3: Agatha hates everyone except herself.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] != (x != Suspect.AGATHA):
					return false
			# Clue 6: The butler hates no one who is richer than Aunt Agatha.
			for x in SUSPECT_COUNT:
				if richer_than_agatha[x] and hates[Suspect.BUTLER][x]:
					return false

		Case.CHARLES:
			# Clue 2: Charles hates everyone who hates Charles.
			for x in SUSPECT_COUNT:
				if hates[x][Suspect.CHARLES] and not hates[Suspect.CHARLES][x]:
					return false
			# Clue 3: Agatha hates only Charles.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] != (x == Suspect.CHARLES):
					return false
			# Clue 6: The butler hates everyone Aunt Agatha hates.
			for x in SUSPECT_COUNT:
				if hates[Suspect.AGATHA][x] and not hates[Suspect.BUTLER][x]:
					return false

	return true

## Enumerate all consistent first-order interpretations across the 3 * 2^9 * 2^3 search space for `case_id`.
static func enumerate_consistent_models(case_id: int = Case.AGATHA) -> Array:
	var models: Array = []
	for killer in SUSPECT_COUNT:
		for r_mask in 8:
			var richer: Array[bool] = [
				(r_mask & 1) != 0,
				(r_mask & 2) != 0,
				(r_mask & 4) != 0,
			]
			if richer[Suspect.AGATHA] or richer[killer]:
				continue
			for h_mask in 512:
				var hates: Array = []
				var bit := 0
				for x in SUSPECT_COUNT:
					var row: Array[bool] = []
					for y in SUSPECT_COUNT:
						row.append(((h_mask >> bit) & 1) != 0)
						bit += 1
					hates.append(row)
				if is_consistent_model(killer, hates, richer, case_id):
					models.append({
						"killer": killer,
						"hates": hates,
						"richer_than_agatha": richer,
					})
	return models

## Return all suspects (0..2) that can be the killer in at least one consistent model for `case_id`.
static func killer_candidates(case_id: int = Case.AGATHA) -> Array[int]:
	var result: Array[int] = []
	for model in enumerate_consistent_models(case_id):
		var k: int = model["killer"]
		if k not in result:
			result.append(k)
	result.sort()
	return result
