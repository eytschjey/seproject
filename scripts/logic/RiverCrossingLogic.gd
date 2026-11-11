class_name RiverCrossingLogic
extends RefCounted

## Pure logical state machine for the Wolf, Goat, and Cabbage river crossing puzzle.
## Source: Theoretical Computer Science: Logic & Puzzles, Chapter 5, Exercise 19.

enum Side { WEST, EAST }
enum Item { WOLF, GOAT, CABBAGE }

signal state_changed(boat_side: int, west_items: Array, east_items: Array, item_on_boat)
signal move_executed(description: String)
signal puzzle_failed(reason: String)
signal puzzle_solved()

var boat_side: int = Side.WEST
var item_on_boat = null # null or Item (int)

var west_items: Array[int] = [Item.WOLF, Item.GOAT, Item.CABBAGE]
var east_items: Array[int] = []

var is_solved: bool = false
var is_failed: bool = false

func _init() -> void:
	reset()

## Reset the puzzle to the initial starting state.
func reset() -> void:
	boat_side = Side.WEST
	item_on_boat = null
	west_items = [Item.WOLF, Item.GOAT, Item.CABBAGE]
	east_items = []
	is_solved = false
	is_failed = false
	state_changed.emit(boat_side, west_items.duplicate(), east_items.duplicate(), item_on_boat)

## Load an item from the current shore onto the boat.
func load_item(item: int) -> bool:
	if is_failed or is_solved:
		return false
	if item_on_boat != null:
		return false # The boat can only hold one item in addition to the ferryman.
	
	var current_shore = _get_shore(boat_side)
	if item in current_shore:
		current_shore.erase(item)
		item_on_boat = item
		move_executed.emit("Loaded %s onto the raft." % item_name(item))
		state_changed.emit(boat_side, west_items.duplicate(), east_items.duplicate(), item_on_boat)
		return true
	return false

## Unload the currently carried item onto the current shore.
func unload_item() -> bool:
	if is_failed or is_solved:
		return false
	if item_on_boat == null:
		return false
	
	var current_shore = _get_shore(boat_side)
	var unloaded = item_on_boat
	current_shore.append(unloaded)
	item_on_boat = null
	move_executed.emit("Unloaded %s onto the %s shore." % [item_name(unloaded), side_name(boat_side)])
	state_changed.emit(boat_side, west_items.duplicate(), east_items.duplicate(), item_on_boat)
	
	_check_victory()
	return true

## Row the boat across the river to the opposite shore.
## Validates that the abandoned shore does not violate predatory constraints.
func cross_river() -> bool:
	if is_failed or is_solved:
		return false
	
	# The shore we are LEAVING is left unsupervised by the ferryman
	var shore_left = _get_shore(boat_side)
	var violation = _check_shore_hazard(shore_left)
	if violation != "":
		is_failed = true
		puzzle_failed.emit(violation)
		return false
	
	# Switch shore
	boat_side = Side.EAST if boat_side == Side.WEST else Side.WEST
	var carried_desc = item_name(item_on_boat) if item_on_boat != null else "alone"
	move_executed.emit("Ferryman crossed to %s shore with %s." % [side_name(boat_side), carried_desc])
	state_changed.emit(boat_side, west_items.duplicate(), east_items.duplicate(), item_on_boat)
	
	_check_victory()
	return true

## Check if an unattended shore violates constraints (wolf eats goat, or goat eats cabbage).
func _check_shore_hazard(shore: Array[int]) -> String:
	var has_wolf = Item.WOLF in shore
	var has_goat = Item.GOAT in shore
	var has_cabbage = Item.CABBAGE in shore
	
	if has_wolf and has_goat:
		return "Constraint violated: The wolf ate the goat!"
	if has_goat and has_cabbage:
		return "Constraint violated: The goat ate the cabbage!"
	return ""

## Check if the puzzle goal state has been reached.
func _check_victory() -> void:
	if east_items.size() == 3 and item_on_boat == null and boat_side == Side.EAST:
		is_solved = true
		puzzle_solved.emit()

func _get_shore(side: int) -> Array[int]:
	return west_items if side == Side.WEST else east_items

## Helper functions for readable names
static func item_name(item) -> String:
	match item:
		Item.WOLF: return "Wolf"
		Item.GOAT: return "Goat"
		Item.CABBAGE: return "Cabbage"
		_: return "None"

static func side_name(side: int) -> String:
	return "West" if side == Side.WEST else "East"

## Find the shortest sequence of actions from the current state to the victory state using BFS.
## Returns an array of action dictionaries:
##   {"type": "load", "item": Item}
##   {"type": "unload", "item": Item}
##   {"type": "cross"}
## Returns an empty array if already solved or if no solution exists from the current state.
func find_solution() -> Array[Dictionary]:
	if is_solved or is_failed:
		return []
	
	var start_mask: int = 0
	for it in west_items:
		start_mask |= (1 << it)
	var start_carried: int = item_on_boat if item_on_boat != null else -1
	var start_state := [boat_side, start_mask, start_carried]
	
	var queue: Array = []
	var visited: Dictionary = {}
	var parent: Dictionary = {}
	
	var start_key := "%d_%d_%d" % [start_state[0], start_state[1], start_state[2]]
	queue.append(start_state)
	visited[start_key] = true
	
	var goal_key := ""
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		var side: int = curr[0]
		var w_mask: int = curr[1]
		var carried: int = curr[2]
		var c_key := "%d_%d_%d" % [side, w_mask, carried]
		
		if side == Side.EAST and w_mask == 0 and carried == -1:
			goal_key = c_key
			break
		
		# 1. Unload if carrying
		if carried != -1:
			var next_w: int = w_mask
			if side == Side.WEST:
				next_w |= (1 << carried)
			var n_state := [side, next_w, -1]
			var n_key := "%d_%d_%d" % [side, next_w, -1]
			if not visited.has(n_key):
				visited[n_key] = true
				parent[n_key] = {"prev": c_key, "action": {"type": "unload", "item": carried}}
				queue.append(n_state)
		
		# 2. Load from current shore
		if carried == -1:
			for item in [Item.WOLF, Item.GOAT, Item.CABBAGE]:
				var item_on_current: bool = false
				if side == Side.WEST:
					item_on_current = (w_mask & (1 << item)) != 0
				else:
					item_on_current = (w_mask & (1 << item)) == 0
				
				if item_on_current:
					var next_w: int = w_mask
					if side == Side.WEST:
						next_w &= ~(1 << item)
					var n_state := [side, next_w, item]
					var n_key := "%d_%d_%d" % [side, next_w, item]
					if not visited.has(n_key):
						visited[n_key] = true
						parent[n_key] = {"prev": c_key, "action": {"type": "load", "item": item}}
						queue.append(n_state)
		
		# 3. Cross
		var leaving_w: bool = (side == Side.WEST)
		var leaving_has_wolf: bool = false
		var leaving_has_goat: bool = false
		var leaving_has_cabbage: bool = false
		
		if leaving_w:
			leaving_has_wolf = (w_mask & (1 << Item.WOLF)) != 0
			leaving_has_goat = (w_mask & (1 << Item.GOAT)) != 0
			leaving_has_cabbage = (w_mask & (1 << Item.CABBAGE)) != 0
		else:
			leaving_has_wolf = (w_mask & (1 << Item.WOLF)) == 0 and carried != Item.WOLF
			leaving_has_goat = (w_mask & (1 << Item.GOAT)) == 0 and carried != Item.GOAT
			leaving_has_cabbage = (w_mask & (1 << Item.CABBAGE)) == 0 and carried != Item.CABBAGE
		
		var conflict: bool = (leaving_has_wolf and leaving_has_goat) or (leaving_has_goat and leaving_has_cabbage)
		if not conflict:
			var next_side: int = Side.EAST if side == Side.WEST else Side.WEST
			var n_state := [next_side, w_mask, carried]
			var n_key := "%d_%d_%d" % [next_side, w_mask, carried]
			if not visited.has(n_key):
				visited[n_key] = true
				parent[n_key] = {"prev": c_key, "action": {"type": "cross"}}
				queue.append(n_state)
	
	if goal_key == "":
		return []
	
	var path: Array[Dictionary] = []
	var curr_k := goal_key
	while curr_k != start_key:
		var p_info: Dictionary = parent[curr_k]
		path.push_front(p_info["action"])
		curr_k = p_info["prev"]
	
	return path
