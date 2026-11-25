class_name MidnightBridgeLogic
extends RefCounted

## Pure logical state machine and Dijkstra shortest-time solver for The Midnight Bridge
## (The Bridge and Torch Problem).
## Source: Theoretical Computer Science: Logic & Puzzles, Chapter 5, Exercise 25.
##
## Travelers:
##  * Ariela (0): 1 minute
##  * Brian  (1): 2 minutes
##  * Charly (2): 5 minutes
##  * Dumpy  (3): 8 minutes
##
## Rules:
##  * Bridge holds 1 or 2 travelers at a time.
##  * Every crossing requires the torch, which travels with the crossing group.
##  * Crossing time equals the speed of the slower traveler in the group.
##  * All 4 travelers must reach the East side within MAX_MINUTES (15 minutes).

enum Side { WEST, EAST }
enum Traveler { ARIELA, BRIAN, CHARLY, DUMPY }

const TRAVELER_COUNT: int = 4
const MAX_MINUTES: int = 15
const TRAVELER_NAMES: Array[String] = ["Ariela", "Brian", "Charly", "Dumpy"]
const CROSSING_TIMES: Array[int] = [1, 2, 5, 8]

signal state_changed(torch_side: int, west_travelers: Array, east_travelers: Array, elapsed_minutes: int)
signal move_executed(description: String)
signal move_rejected(reason: String)
signal puzzle_failed(reason: String)
signal puzzle_solved()

var torch_side: int = Side.WEST
var west_travelers: Array[int] = []
var east_travelers: Array[int] = []
var elapsed_minutes: int = 0
var history: Array[Dictionary] = []
var is_solved: bool = false
var is_failed: bool = false

func _init() -> void:
	reset()

## Reset all travelers and the torch to the West side with 0 minutes elapsed.
func reset() -> void:
	torch_side = Side.WEST
	west_travelers = [Traveler.ARIELA, Traveler.BRIAN, Traveler.CHARLY, Traveler.DUMPY]
	east_travelers = []
	elapsed_minutes = 0
	history = []
	is_solved = false
	is_failed = false
	state_changed.emit(torch_side, west_travelers.duplicate(), east_travelers.duplicate(), elapsed_minutes)

func remaining_minutes() -> int:
	return maxi(0, MAX_MINUTES - elapsed_minutes)

func travelers_on_side(side: int) -> Array[int]:
	return west_travelers.duplicate() if side == Side.WEST else east_travelers.duplicate()

## Validate whether the given array of 1..2 travelers can legally cross from `torch_side`.
func can_cross(travelers: Array) -> bool:
	return _validate_crossing(travelers) == ""

func _validate_crossing(travelers: Array) -> String:
	if is_solved:
		return "The puzzle is already solved."
	if is_failed:
		return "The torch has burned out! Undo or Reset to try again."
	if travelers.is_empty():
		return "Select 1 or 2 travelers to cross the bridge."
	if travelers.size() > 2:
		return "The rope bridge holds at most 2 travelers at a time."

	var seen: Dictionary = {}
	var current_side: Array[int] = west_travelers if torch_side == Side.WEST else east_travelers
	for raw in travelers:
		var t: int = int(raw)
		if t < 0 or t >= TRAVELER_COUNT:
			return "Invalid traveler."
		if seen.has(t):
			return "Duplicate traveler in crossing group."
		seen[t] = true
		if t not in current_side:
			return "%s is not on the %s side with the torch." % [traveler_name(t), side_name(torch_side)]
	return ""

## Cross the bridge with 1 or 2 travelers from the side currently holding the torch.
func cross(travelers: Array) -> bool:
	var err: String = _validate_crossing(travelers)
	if not err.is_empty():
		move_rejected.emit(err)
		return false

	# Save snapshot for undo
	history.append({
		"torch_side": torch_side,
		"west_travelers": west_travelers.duplicate(),
		"east_travelers": east_travelers.duplicate(),
		"elapsed_minutes": elapsed_minutes,
	})

	var from_side: int = torch_side
	var to_side: int = Side.EAST if from_side == Side.WEST else Side.WEST
	var src: Array[int] = west_travelers if from_side == Side.WEST else east_travelers
	var dst: Array[int] = east_travelers if from_side == Side.WEST else west_travelers

	var group: Array[int] = []
	for raw in travelers:
		var t: int = int(raw)
		src.erase(t)
		dst.append(t)
		group.append(t)
	src.sort()
	dst.sort()
	group.sort()

	var cost: int = group_cost(group)
	elapsed_minutes += cost
	torch_side = to_side

	var names: Array[String] = []
	for t in group:
		names.append("%s (%dm)" % [traveler_name(t), crossing_time(t)])
	move_executed.emit("%s crossed %s → %s (+%d min, total %d/%d min)." % [
		" & ".join(names),
		side_name(from_side),
		side_name(to_side),
		cost,
		elapsed_minutes,
		MAX_MINUTES,
	])
	state_changed.emit(torch_side, west_travelers.duplicate(), east_travelers.duplicate(), elapsed_minutes)

	if elapsed_minutes > MAX_MINUTES:
		is_failed = true
		puzzle_failed.emit("The torch burned out! (%d / %d min used)" % [elapsed_minutes, MAX_MINUTES])
	elif east_travelers.size() == TRAVELER_COUNT and torch_side == Side.EAST:
		is_solved = true
		puzzle_solved.emit()
	return true

## Revert the last crossing (also recovers from a torch-burnout failure).
func undo() -> bool:
	if history.is_empty() or is_solved:
		return false
	var prev: Dictionary = history.pop_back()
	torch_side = int(prev["torch_side"])
	west_travelers = []
	for t in prev["west_travelers"]:
		west_travelers.append(int(t))
	east_travelers = []
	for t in prev["east_travelers"]:
		east_travelers.append(int(t))
	elapsed_minutes = int(prev["elapsed_minutes"])
	is_failed = false
	move_executed.emit("Undid last crossing (elapsed: %d/%d min)." % [elapsed_minutes, MAX_MINUTES])
	state_changed.emit(torch_side, west_travelers.duplicate(), east_travelers.duplicate(), elapsed_minutes)
	return true

## Find the minimum-time sequence of crossings from the current state to reach all-East
## within MAX_MINUTES using Dijkstra's algorithm.
## Each step is: {"travelers": Array[int], "from": int, "to": int, "cost": int}.
## Returns [] if already solved, failed, or no valid completion exists within MAX_MINUTES.
func find_optimal_solution() -> Array[Dictionary]:
	if is_solved or is_failed or elapsed_minutes > MAX_MINUTES:
		return []

	var start_mask: int = 0
	for t in west_travelers:
		start_mask |= (1 << t)
	var start_key: String = "%d_%d" % [torch_side, start_mask]

	var dist: Dictionary = {start_key: elapsed_minutes}
	var parent: Dictionary = {}
	var settled: Dictionary = {}
	var frontier: Array = [[elapsed_minutes, torch_side, start_mask]]

	var goal_key: String = "%d_0" % Side.EAST
	var found_goal: bool = false

	while not frontier.is_empty():
		# Pick lowest-cost state in frontier (state space has at most 2 * 16 = 32 nodes)
		var best_idx: int = 0
		for i in range(1, frontier.size()):
			if int(frontier[i][0]) < int(frontier[best_idx][0]):
				best_idx = i
		var curr: Array = frontier[best_idx]
		frontier.remove_at(best_idx)

		var curr_cost: int = int(curr[0])
		var side: int = int(curr[1])
		var w_mask: int = int(curr[2])
		var c_key: String = "%d_%d" % [side, w_mask]

		if settled.has(c_key):
			continue
		settled[c_key] = true

		if curr_cost > MAX_MINUTES:
			break
		if c_key == goal_key:
			found_goal = true
			break

		var available: Array[int] = []
		for t in TRAVELER_COUNT:
			var on_west: bool = (w_mask & (1 << t)) != 0
			if (side == Side.WEST and on_west) or (side == Side.EAST and not on_west):
				available.append(t)

		var next_side: int = Side.EAST if side == Side.WEST else Side.WEST
		var groups: Array = []
		for i in available.size():
			groups.append([available[i]])
			for j in range(i + 1, available.size()):
				groups.append([available[i], available[j]])

		for g in groups:
			var step_cost: int = group_cost(g)
			var next_cost: int = curr_cost + step_cost
			if next_cost > MAX_MINUTES:
				continue
			var next_mask: int = w_mask
			for t in g:
				if side == Side.WEST:
					next_mask &= ~(1 << int(t))
				else:
					next_mask |= (1 << int(t))
			var n_key: String = "%d_%d" % [next_side, next_mask]
			if not dist.has(n_key) or next_cost < int(dist[n_key]):
				dist[n_key] = next_cost
				var typed_group: Array[int] = []
				for t in g:
					typed_group.append(int(t))
				parent[n_key] = {
					"prev": c_key,
					"step": {
						"travelers": typed_group,
						"from": side,
						"to": next_side,
						"cost": step_cost,
					},
				}
				frontier.append([next_cost, next_side, next_mask])

	if not found_goal:
		return []

	var path: Array[Dictionary] = []
	var k: String = goal_key
	while k != start_key:
		var info: Dictionary = parent[k]
		path.push_front(info["step"])
		k = str(info["prev"])
	return path

static func traveler_name(t: int) -> String:
	if t < 0 or t >= TRAVELER_COUNT:
		return "Unknown"
	return TRAVELER_NAMES[t]

static func crossing_time(t: int) -> int:
	if t < 0 or t >= TRAVELER_COUNT:
		return 0
	return CROSSING_TIMES[t]

static func side_name(side: int) -> String:
	return "West" if side == Side.WEST else "East"

static func group_cost(travelers: Array) -> int:
	var slowest: int = 0
	for raw in travelers:
		slowest = maxi(slowest, crossing_time(int(raw)))
	return slowest
