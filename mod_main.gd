extends Node
## BatoStats++ - post-battle combat statistics panel.
##
## Polls the current game state, and when a battle finishes, captures the
## simulation's battle statistics and shows the comparison panel. The panel is
## hidden while a replay runs and when the battle state is left.

const VERSION := "1.003"

const NodeUtils = preload("core/node_utils.gd")
const BattleMonitor = preload("core/battle_monitor.gd")
const BattleCompletionReporter = preload("core/battle_completion_reporter.gd")
const CombatStats = preload("core/combat_stats.gd")
const CombatStatsPanel = preload("hud/combat_stats_panel.gd")
const ModConfig = preload("core/mod_config.gd")
const AutoUpdater = preload("core/auto_updater.gd")

const BATTLE_SCRIPT := "res://game/states/battle_state.gd"
const POLL_INTERVAL_MS := 500

var _panel = null
var _completion = null
var _config = null
var _updater = null
var _next_poll := 0
var _snapshot: Dictionary = {}


func mod_ready() -> void:
	_setup()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _is_loaded_by_mod_loader():
		_setup()


func _exit_tree() -> void:
	# Drop the loader subscription so a freed mod node is never called back.
	if _config != null:
		_config.teardown()


func _setup() -> void:
	if _panel != null:
		return
	var layer := CanvasLayer.new()
	layer.name = "BatoStatsLayer"
	layer.layer = 110
	add_child(layer)

	_panel = CombatStatsPanel.new()
	_panel.name = "CombatStatsPanel"
	layer.add_child(_panel)

	_completion = BattleCompletionReporter.new()

	_config = ModConfig.new()
	_config.setup(get_node_or_null("/root/ModLoader"))
	_config.changed.connect(_on_feature_toggled)
	_panel.set_show_totals(_config.is_enabled(ModConfig.KEY_SHOW_TEAM_TOTALS))

	_setup_auto_updater()

	print("BatoStats++ %s loaded" % VERSION)


## The updater lives next to the mod and edits the mod's own folder, so it gets the folder of the
## running script (not a game path). It refuses to run on a developer install by itself.
func _setup_auto_updater() -> void:
	_updater = AutoUpdater.new()
	_updater.name = "AutoUpdater"
	add_child(_updater)
	_updater.setup(VERSION, get_script().resource_path.get_base_dir(),
		_config.is_enabled(ModConfig.KEY_AUTO_UPDATE))
	_updater.start()


## Apply a live settings change.
func _on_feature_toggled(key: String, value: bool) -> void:
	if key == ModConfig.KEY_AUTO_UPDATE and _updater != null:
		_updater.set_auto(value)
	elif key == ModConfig.KEY_SHOW_TEAM_TOTALS and _panel != null:
		_panel.set_show_totals(value)


func _process(_delta: float) -> void:
	if _panel == null:
		return
	var now := Time.get_ticks_msec()
	if now < _next_poll:
		return
	_next_poll = now + POLL_INTERVAL_MS
	_poll()


func _poll() -> void:
	var main = get_tree().current_scene
	var state = main.get("current_state") if main != null and NodeUtils.has_property(main, "current_state") else null
	if not NodeUtils.script_is(state, BATTLE_SCRIPT):
		_panel.hide_panel()
		_completion.reset()
		return

	# check() must run every poll so a replay re-arms the completion report.
	var completed: bool = _completion.check(state)
	if not BattleMonitor.is_over(state):
		_panel.hide_panel()
		return
	if not completed:
		return

	var sim = state.get("simulation") if NodeUtils.has_property(state, "simulation") else null
	var battle_data = sim.get("data") if sim != null and NodeUtils.has_property(sim, "data") else null
	_snapshot = CombatStats.capture(battle_data)
	_log_snapshot(_snapshot)
	_panel.show_snapshot(_snapshot)


func _log_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		print("BatoStats++ | capture failed (no battle data)")
		return
	var player: Dictionary = snapshot.get("player_team", {})
	var opponent: Dictionary = snapshot.get("opponent_team", {})
	print("BatoStats++ | captured | player units=%d opponent units=%d" % [
		player.get("units", []).size(), opponent.get("units", []).size()])


func _is_loaded_by_mod_loader() -> bool:
	if not is_inside_tree():
		return false
	var parent_node = get_parent()
	return parent_node != null and parent_node == get_node_or_null("/root/ModLoader")
