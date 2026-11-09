extends "comfort_panel.gd"
## Collapsible, draggable panel base.
##
## Only the header bar is interactive (see _has_point), so clicks on the body fall through
## to the game. A press on the header arms _pressing; _process then polls the real mouse
## button, so the drag always ends on release even if the cursor has left the panel.
## A press released without crossing DRAG_THRESHOLD toggles collapse instead.

## Emitted once per drag, when the press first crosses DRAG_THRESHOLD (a real move, not a click).
signal moved

const HEAD_H := 16.0
const BTN := 12.0
const ANIM_SEC := 0.14
const DRAG_THRESHOLD := 3.0
const TITLE_FONT_SIZE := 8  # Shared header text size for every collapsible panel

const HEADER_BG := Style.HEADER_BG      # Slightly lighter navy for the header bar
const INK_COLOR := Style.VALUE_COLOR    # "-" / "+" glyph colour

var minimized := false
var reveal := 1.0  # 1 = expanded, 0 = minimized (animated)

var _panel_style: StyleBoxFlat
var _header_style: StyleBoxFlat
var _button_style: StyleBoxFlat

var _pressing := false
var _dragged := false
var _press_pos := Vector2.ZERO
var _drag_offset := Vector2.ZERO
var _tween: Tween

## When true, dragging and resizing keep the panel inside the viewport.
var clamp_to_viewport := false
## When true, the header is drawn even with no entries and while collapsed.
var draw_when_empty := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Keep dragging and the collapse tween alive while the game pauses the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	clip_contents = true
	visible = false
	_setup_styles()
	_text_font = _build_panel_font()


func _setup_styles() -> void:
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = BG_COLOR
	_panel_style.border_color = BORDER_COLOR
	_panel_style.set_border_width_all(1)
	_panel_style.set_corner_radius_all(3)
	_panel_style.set_content_margin_all(3)

	_header_style = StyleBoxFlat.new()
	_header_style.bg_color = HEADER_BG
	_header_style.border_color = BORDER_COLOR
	_header_style.set_border_width_all(1)
	_header_style.set_corner_radius_all(3)
	_header_style.set_content_margin_all(3)

	_button_style = StyleBoxFlat.new()
	_button_style.bg_color = BORDER_COLOR
	_button_style.set_corner_radius_all(2)
	_button_style.set_content_margin_all(2)


func header_text() -> String:
	return ""


func full_height() -> float:
	return HEAD_H


func _apply_size() -> void:
	pass


## Size the panel will have when fully expanded. Lets set_minimized() make room for the
## expansion once, up front, instead of the position shifting on every animation frame.
func _target_size() -> Vector2:
	return size


## Draw the rows only; the base already drew the body background before calling this.
func _draw_body(_width: float) -> void:
	pass


func set_minimized(on: bool, animate := true) -> void:
	if on == minimized and (_tween == null or not _tween.is_running()):
		return
	minimized = on
	if _tween != null:
		_tween.kill()
	if not on:
		# Make room for the expanded size once; the top-left then stays fixed during the tween.
		_clamp_to_viewport(_target_size())
	var target := 0.0 if on else 1.0
	if not animate or not is_inside_tree():
		reveal = target
		_apply_size()
		queue_redraw()
	else:
		# The game slows / stops Engine.time_scale (KO slow motion, pause), so animate in
		# real time. Position is not touched while animating: the top stays fixed and the
		# panel expands downward (any needed shift was applied above, once).
		_tween = create_tween().set_ignore_time_scale(true)
		_tween.tween_method(func(v: float):
			reveal = v
			_apply_size()
			queue_redraw(), reveal, target, ANIM_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func toggle() -> void:
	set_minimized(not minimized)


## Width of the header bar and its button. Defaults to the panel width; subclasses can keep
## the header compact (e.g. only as wide as the collapsed tab) while the body stays wider.
func header_width() -> float:
	return size.x


func button_rect() -> Rect2:
	return Rect2(Vector2(header_width() - 8 - BTN - 3, 2.0), Vector2(BTN, BTN))


func _draw() -> void:
	if _panel_style == null or _text_font == null:
		return
	if reveal <= 0.01 and not draw_when_empty:
		return

	var ci := get_canvas_item()
	var w := size.x

	if reveal > 0.01:
		_panel_style.draw(ci, Rect2(Vector2(0, 4), Vector2(w, maxf(size.y - 4, 8))))
		_draw_body(w)

	# Header bar (may be narrower than the body; see header_width())
	var hw := header_width()
	_header_style.draw(ci, Rect2(Vector2(7, 0), Vector2(hw - 14, HEAD_H)))
	_draw_title(Rect2(Vector2(12, 0), Vector2(button_rect().position.x - 16, HEAD_H)))

	var b := button_rect()
	_button_style.draw(ci, b)
	var c := b.get_center().floor()
	draw_rect(Rect2(c.x - 3, c.y, 6, 1), INK_COLOR)
	if minimized:
		draw_rect(Rect2(c.x - 1, c.y - 3, 1, 7), INK_COLOR)


func _draw_title(r: Rect2) -> void:
	var t := _fit_text(_text_font, header_text(), TITLE_FONT_SIZE, r.size.x)
	var baseline := r.position.y + HEAD_H * 0.5 + 3.0
	_draw_text_shadow(Vector2(r.position.x, baseline), t, VALUE_COLOR, TITLE_FONT_SIZE)


## Only the visible header bar takes mouse input; the body is click-through.
func _has_point(point: Vector2) -> bool:
	return point.x >= 0.0 and point.x <= header_width() and point.y >= 0.0 and point.y <= HEAD_H + 1.0


## Arms a press on the header. Everything after the press (threshold, dragging, release,
## toggle) is handled by _process, which does not depend on where the cursor is.
func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressing = true
			_dragged = false
			# Global space, so the panel can be placed directly under the cursor every frame.
			_press_pos = get_global_mouse_position()
			_drag_offset = _press_pos - global_position
		accept_event()


func _process(_delta: float) -> void:
	if not _pressing:
		return
	var mouse := get_global_mouse_position()
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Released (over the panel or not): a press that never became a drag is a click.
		_pressing = false
		if not _dragged:
			toggle()
		return
	if not _dragged and mouse.distance_to(_press_pos) >= DRAG_THRESHOLD:
		_dragged = true
		moved.emit()
	if _dragged:
		# Follow the absolute cursor position; accumulated deltas can drift.
		global_position = mouse - _drag_offset
		_clamp_to_viewport()


func _notification(what: int) -> void:
	# A press cannot outlive the panel being hidden (no stray toggle / drag on re-show).
	if what == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		_pressing = false
		_dragged = false


## Keep the panel inside the viewport when the subclass opts in. extent is the size to fit
## (defaults to the current size). Called while dragging, on viewport resize, and once when
## an expansion starts; never per animation frame.
func _clamp_to_viewport(extent := Vector2.ZERO) -> void:
	if not clamp_to_viewport:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var fit: Vector2 = extent if extent != Vector2.ZERO else size
	var bounds := viewport.get_visible_rect().size
	position.x = clampf(position.x, 0.0, maxf(0.0, bounds.x - fit.x))
	position.y = clampf(position.y, 0.0, maxf(0.0, bounds.y - fit.y))
