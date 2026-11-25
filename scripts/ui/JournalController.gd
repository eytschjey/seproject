class_name JournalController
extends Control

## UI Controller for the In-Game Logic Journal (scenes/ui/Journal.tscn).
## Decoupled from data storage: renders entries from a headless JournalState instance.
## Toggled via the `journal` input action (J / Tab) or the non-overlapping HUD button.

const JOURNAL_SCENE_PATH: String = "res://scenes/ui/Journal.tscn"

signal journal_toggled(is_open: bool)

@onready var btn_toggle: Button = %BtnToggleJournal
@onready var overlay: ColorRect = %Overlay
@onready var journal_panel: PanelContainer = %JournalPanel
@onready var title_label: Label = %TitleLabel
@onready var count_label: Label = %CountLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var btn_close: Button = %BtnClose
@onready var tab_row: HBoxContainer = %TabRow
@onready var btn_tab_notes: Button = %BtnTabNotes
@onready var btn_tab_scratchpad: Button = %BtnTabScratchpad
@onready var btn_clear_scratchpad: Button = %BtnClearScratchpad
@onready var notes_view: VBoxContainer = %NotesView
@onready var entries_list: VBoxContainer = %EntriesList
@onready var empty_label: Label = %EmptyLabel
@onready var scratchpad_view: VBoxContainer = %ScratchpadView
@onready var scratchpad_grid: GridContainer = %ScratchpadGrid

var state: RefCounted = null
var active_level_id: String = ""
var active_level_title: String = "Logic Journal"
var accent_color: Color = Color(0.46, 0.50, 0.62, 0.70)
var is_open: bool = false
var active_tab: String = "notes" # "notes" or "scratchpad"
var scratchpad_buttons: Dictionary = {} # "row|col" -> Button

var _style_mark_unknown: StyleBoxFlat
var _style_mark_yes: StyleBoxFlat
var _style_mark_no: StyleBoxFlat
var _style_tab_inactive: StyleBoxFlat
var _style_tab_active: StyleBoxFlat

## Instantiate and attach a Logic Journal overlay to a level's UI root.
static func attach(
	parent: Control,
	journal_state: RefCounted,
	level_id: String,
	level_title: String,
	accent: Color = Color(0.46, 0.50, 0.62, 0.70)
) -> Control:
	var scene: PackedScene = load(JOURNAL_SCENE_PATH)
	var instance: Control = scene.instantiate()
	parent.add_child(instance)
	instance.setup(journal_state, level_id, level_title, accent)
	return instance

func _ready() -> void:
	btn_toggle.pressed.connect(toggle)
	btn_close.pressed.connect(close)
	btn_tab_notes.pressed.connect(func(): set_active_tab("notes"))
	btn_tab_scratchpad.pressed.connect(func(): set_active_tab("scratchpad"))
	btn_clear_scratchpad.pressed.connect(_on_clear_scratchpad_pressed)
	overlay.visible = false
	_apply_theme()
	_refresh_view()

func setup(
	journal_state: RefCounted,
	level_id: String,
	level_title: String,
	accent: Color = Color(0.46, 0.50, 0.62, 0.70)
) -> void:
	if state != null:
		if state.state_changed.is_connected(_on_state_changed):
			state.state_changed.disconnect(_on_state_changed)
		if state.scratchpad_changed.is_connected(_on_scratchpad_changed):
			state.scratchpad_changed.disconnect(_on_scratchpad_changed)
	state = journal_state
	active_level_id = level_id
	active_level_title = level_title
	accent_color = accent
	active_tab = "notes"
	if state != null:
		state.state_changed.connect(_on_state_changed)
		state.scratchpad_changed.connect(_on_scratchpad_changed)
	if is_node_ready():
		_apply_theme()
		_refresh_view()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open and event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()

func open() -> void:
	is_open = true
	overlay.visible = true
	_refresh_view()
	journal_toggled.emit(true)

func close() -> void:
	is_open = false
	overlay.visible = false
	journal_toggled.emit(false)

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func _on_state_changed(level_id: String, _entries: Array) -> void:
	if level_id == active_level_id:
		_refresh_view()

func _on_scratchpad_changed(level_id: String, _row: String, _col: String, _mark: int) -> void:
	if level_id == active_level_id:
		_refresh_scratchpad()

func set_active_tab(tab_name: String) -> void:
	var has_pad: bool = state != null and state.has_scratchpad(active_level_id)
	if tab_name == "scratchpad" and not has_pad:
		tab_name = "notes"
	active_tab = tab_name
	_update_tab_visibility()

func _on_clear_scratchpad_pressed() -> void:
	if state != null:
		state.clear_scratchpad(active_level_id)

func _refresh_view() -> void:
	if not is_node_ready():
		return
	var entries: Array = state.get_entries(active_level_id) if state != null else []
	title_label.text = "Logic Journal — %s" % active_level_title
	var count: int = entries.size()
	count_label.text = "%d %s" % [count, "entry" if count == 1 else "entries"]
	btn_toggle.text = "Journal (%d)" % count
	btn_toggle.tooltip_text = "Open Logic Journal [J / Tab] (%d logged)" % count

	for child in entries_list.get_children():
		entries_list.remove_child(child)
		child.queue_free()

	empty_label.visible = entries.is_empty()
	for entry in entries:
		entries_list.add_child(_build_entry_card(entry))

	_refresh_scratchpad()
	_update_tab_visibility()

func _update_tab_visibility() -> void:
	if not is_node_ready():
		return
	var has_pad: bool = state != null and state.has_scratchpad(active_level_id)
	tab_row.visible = has_pad
	if not has_pad:
		active_tab = "notes"
	var show_pad: bool = has_pad and active_tab == "scratchpad"
	notes_view.visible = not show_pad
	scratchpad_view.visible = show_pad
	btn_clear_scratchpad.visible = show_pad
	if _style_tab_active != null and _style_tab_inactive != null:
		btn_tab_notes.add_theme_stylebox_override("normal", _style_tab_inactive if show_pad else _style_tab_active)
		btn_tab_scratchpad.add_theme_stylebox_override("normal", _style_tab_active if show_pad else _style_tab_inactive)

func _refresh_scratchpad() -> void:
	if not is_node_ready():
		return
	for child in scratchpad_grid.get_children():
		scratchpad_grid.remove_child(child)
		child.queue_free()
	scratchpad_buttons.clear()

	if state == null or not state.has_scratchpad(active_level_id):
		return

	var rows: Array[String] = state.get_scratchpad_rows(active_level_id)
	var cols: Array[String] = state.get_scratchpad_cols(active_level_id)
	scratchpad_grid.columns = cols.size() + 1

	# Top-left corner spacer
	var corner := Label.new()
	corner.text = ""
	corner.custom_minimum_size = Vector2(115, 28)
	scratchpad_grid.add_child(corner)

	# Column headers
	for col in cols:
		var lbl := Label.new()
		lbl.text = col
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(0.90, 0.88, 0.82))
		scratchpad_grid.add_child(lbl)

	# Rows
	for row in rows:
		var row_lbl := Label.new()
		row_lbl.text = row
		row_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_lbl.custom_minimum_size = Vector2(115, 32)
		row_lbl.add_theme_font_size_override("font_size", 13)
		row_lbl.add_theme_color_override("font_color", Color(0.88, 0.89, 0.92))
		scratchpad_grid.add_child(row_lbl)

		for col in cols:
			var mark: int = state.get_mark(active_level_id, row, col)
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(88, 32)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.text = state.mark_symbol(mark)
			btn.tooltip_text = "%s — %s" % [row, col]
			_style_scratchpad_cell(btn, mark)
			btn.pressed.connect(_on_scratchpad_cell_pressed.bind(row, col))
			scratchpad_grid.add_child(btn)
			scratchpad_buttons["%s|%s" % [row, col]] = btn

func _on_scratchpad_cell_pressed(row: String, col: String) -> void:
	if state != null:
		state.cycle_mark(active_level_id, row, col)

func _style_scratchpad_cell(btn: Button, mark: int) -> void:
	var sb: StyleBoxFlat = _style_mark_unknown
	var fg: Color = Color(0.86, 0.88, 0.92)
	if mark == 1: # YES
		sb = _style_mark_yes
		fg = Color(0.74, 0.96, 0.80)
	elif mark == 2: # NO
		sb = _style_mark_no
		fg = Color(0.96, 0.72, 0.72)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg.lightened(0.1))
	btn.add_theme_font_size_override("font_size", 15)

func _build_entry_card(entry: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_sb := _make_box_style(Color(0.12, 0.13, 0.17, 0.92), accent_color.darkened(0.15), 1, 6, 12.0, 8.0)
	card.add_theme_stylebox_override("panel", card_sb)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var lbl_title := Label.new()
	lbl_title.text = str(entry.get("title", ""))
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.add_theme_font_size_override("font_size", 15)
	lbl_title.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84))
	header.add_child(lbl_title)

	var subtitle_text: String = str(entry.get("subtitle", ""))
	if not subtitle_text.is_empty():
		var lbl_sub := Label.new()
		lbl_sub.text = subtitle_text
		lbl_sub.add_theme_font_size_override("font_size", 12)
		lbl_sub.add_theme_color_override("font_color", Color(0.70, 0.72, 0.78))
		header.add_child(lbl_sub)

	var lbl_body := Label.new()
	lbl_body.text = "\"%s\"" % str(entry.get("body", ""))
	lbl_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_body.add_theme_font_size_override("font_size", 14)
	lbl_body.add_theme_color_override("font_color", Color(0.86, 0.87, 0.90))
	vbox.add_child(lbl_body)

	var formula_text: String = str(entry.get("formula", ""))
	if not formula_text.is_empty():
		var lbl_formula := Label.new()
		lbl_formula.text = "Logic: %s" % formula_text
		lbl_formula.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_formula.add_theme_font_size_override("font_size", 13)
		lbl_formula.add_theme_color_override("font_color", accent_color.lightened(0.32))
		vbox.add_child(lbl_formula)

	return card

func _make_box_style(
	bg: Color,
	border: Color,
	border_w: int = 1,
	radius: int = 6,
	pad_x: float = 14.0,
	pad_y: float = 8.0
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	return sb

func _apply_theme() -> void:
	var panel_sb := _make_box_style(Color(0.08, 0.09, 0.12, 0.96), accent_color, 1, 10, 20.0, 16.0)
	journal_panel.add_theme_stylebox_override("panel", panel_sb)

	var toggle_normal := _make_box_style(Color(0.10, 0.11, 0.14, 0.86), accent_color, 1, 6, 6.0, 4.0)
	var toggle_hover := _make_box_style(Color(0.15, 0.17, 0.21, 0.92), accent_color.lightened(0.15), 1, 6, 6.0, 4.0)
	var toggle_pressed := _make_box_style(Color(0.19, 0.22, 0.27, 0.95), accent_color.lightened(0.25), 1, 6, 6.0, 4.0)
	_style_tab_inactive = _make_box_style(Color(0.11, 0.12, 0.16, 0.88), accent_color.darkened(0.2), 1, 5, 10.0, 4.0)
	_style_tab_active = _make_box_style(Color(0.20, 0.22, 0.28, 0.96), accent_color.lightened(0.2), 1, 5, 10.0, 4.0)
	_style_mark_unknown = _make_box_style(Color(0.12, 0.13, 0.17, 0.90), Color(0.28, 0.30, 0.38, 0.65), 1, 4, 6.0, 2.0)
	_style_mark_yes = _make_box_style(Color(0.14, 0.28, 0.18, 0.94), Color(0.34, 0.66, 0.44, 0.80), 1, 4, 6.0, 2.0)
	_style_mark_no = _make_box_style(Color(0.30, 0.14, 0.16, 0.94), Color(0.68, 0.34, 0.38, 0.80), 1, 4, 6.0, 2.0)
	for btn in [btn_toggle, btn_close, btn_tab_notes, btn_tab_scratchpad, btn_clear_scratchpad]:
		btn.add_theme_stylebox_override("normal", toggle_normal)
		btn.add_theme_stylebox_override("hover", toggle_hover)
		btn.add_theme_stylebox_override("pressed", toggle_pressed)
		btn.add_theme_color_override("font_color", Color(0.86, 0.88, 0.91))
		btn.add_theme_color_override("font_hover_color", Color(0.95, 0.96, 0.98))
		btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
		btn.add_theme_constant_override("outline_size", 1)
