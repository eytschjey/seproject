class_name QueensLogic
extends RefCounted

## Pure logical model of the 8-Queens puzzle.
## Source: Theoretical Computer Science: Logic & Puzzles, Chapter 4, Section 4.8.1.
##
## Cells are Vector2i(column, row), both 0..BOARD_SIZE-1. The player may place queens freely
## (up to BOARD_SIZE); attacking queens are reported as conflicts. The puzzle is solved when
## BOARD_SIZE queens stand on the board and no two attack each other.

const BOARD_SIZE: int = 8

signal state_changed(queens: Array, conflicts: Array)
signal move_executed(description: String)
signal puzzle_solved()

var queens: Array[Vector2i] = []
var is_solved: bool = false

func _init() -> void:
	reset()

func reset() -> void:
	queens = []
	is_solved = false
	state_changed.emit(queens.duplicate(), [])

func has_queen(cell: Vector2i) -> bool:
	return cell in queens

static func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < BOARD_SIZE and cell.y >= 0 and cell.y < BOARD_SIZE

## Do two distinct queens attack each other (same row, column or diagonal)?
static func attacks(a: Vector2i, b: Vector2i) -> bool:
	if a == b:
		return false
	return a.x == b.x or a.y == b.y or abs(a.x - b.x) == abs(a.y - b.y)

## Place a queen. Fails if out of bounds, occupied, board is full, or puzzle already solved.
func place_queen(cell: Vector2i) -> bool:
	if is_solved or not in_bounds(cell) or has_queen(cell) or queens.size() >= BOARD_SIZE:
		return false
	queens.append(cell)
	move_executed.emit("Placed a queen at %s." % cell_name(cell))
	_after_change()
	return true

func remove_queen(cell: Vector2i) -> bool:
	if is_solved or not has_queen(cell):
		return false
	queens.erase(cell)
	move_executed.emit("Removed the queen at %s." % cell_name(cell))
	_after_change()
	return true

## Remove the queen if present, otherwise place one.
func toggle_queen(cell: Vector2i) -> bool:
	if has_queen(cell):
		return remove_queen(cell)
	return place_queen(cell)

## All pairs of queens that attack each other, as [Vector2i, Vector2i].
func conflict_pairs() -> Array:
	return pairs_in(queens)

## Queens that are attacked by at least one other queen.
func conflicting_queens() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for p in conflict_pairs():
		for c in p:
			if c not in result:
				result.append(c)
	return result

func _after_change() -> void:
	var pairs := conflict_pairs()
	var conflicts := conflicting_queens()
	is_solved = queens.size() == BOARD_SIZE and pairs.is_empty()
	state_changed.emit(queens.duplicate(), conflicts)
	if is_solved:
		puzzle_solved.emit()

static func pairs_in(cells: Array) -> Array:
	var pairs: Array = []
	for i in cells.size():
		for j in range(i + 1, cells.size()):
			if attacks(cells[i], cells[j]):
				pairs.append([cells[i], cells[j]])
	return pairs

## Is this set of cells a valid (non-attacking) placement of BOARD_SIZE queens?
static func is_valid_solution(cells: Array) -> bool:
	return cells.size() == BOARD_SIZE and pairs_in(cells).is_empty()

## Backtracking solver: every solution as an Array of Vector2i (one queen per row).
static func solve_all() -> Array:
	var solutions: Array = []
	_search([], solutions)
	return solutions

static func _search(partial: Array, solutions: Array) -> void:
	var row: int = partial.size()
	if row == BOARD_SIZE:
		solutions.append(partial.duplicate())
		return
	for col in BOARD_SIZE:
		var cell := Vector2i(col, row)
		var safe := true
		for q in partial:
			if attacks(q, cell):
				safe = false
				break
		if safe:
			partial.append(cell)
			_search(partial, solutions)
			partial.pop_back()

## Human-readable cell name, e.g. Vector2i(0, 0) -> "A1".
static func cell_name(cell: Vector2i) -> String:
	return "%s%d" % [char(65 + cell.x), cell.y + 1]
