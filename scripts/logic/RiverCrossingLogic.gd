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
