extends RefCounted
## Centralized user-facing feature toggles for BatoStats++.
##
## Configuration lives here: setting keys, defaults, persistence lookups, and
## change notifications. Feature logic (mod_main.gd) never reads the Mod Loader
## directly; it asks this module.
##
## Values are persisted by the community Mod Loader in user://mod_settings.cfg
## (declared in mod.json). When the loader is absent (standalone run) the
## defaults below are used, so every feature stays enabled.

const MOD_ID := "batostats_plus_plus"

const KEY_AUTO_UPDATE := "auto_update"
const KEY_SHOW_TEAM_TOTALS := "show_team_totals"

const DEFAULTS := {
	KEY_AUTO_UPDATE: true,
	KEY_SHOW_TEAM_TOTALS: true,
}

## Emitted when a known setting changes. Only our own keys are re-emitted.
signal changed(key: String, value: bool)

var _loader = null


## Bind to the Mod Loader (may be null when running standalone). Subscribes to
## config_changed exactly once, so repeated setup calls cannot duplicate signals.
func setup(loader) -> void:
	_loader = loader
	if _loader == null:
		return
	if not _loader.has_signal("config_changed"):
		return
	if not _loader.config_changed.is_connected(_on_loader_config_changed):
		_loader.config_changed.connect(_on_loader_config_changed)


## Disconnect from the Mod Loader. Called when the mod node leaves the tree so a
## freed mod is never called back through the loader's config_changed signal.
func teardown() -> void:
	if _loader != null and _loader.has_signal("config_changed"):
		if _loader.config_changed.is_connected(_on_loader_config_changed):
			_loader.config_changed.disconnect(_on_loader_config_changed)
	_loader = null


## True when the feature is enabled. Unknown keys fall back to enabled.
func is_enabled(key: String) -> bool:
	if not DEFAULTS.has(key):
		return true
	if _loader != null and _loader.has_method("get_config"):
		var value = _loader.get_config(MOD_ID, key, DEFAULTS[key])
		if value is bool:
			return value
	return DEFAULTS[key]


func _on_loader_config_changed(mod_id: String, key: String, value) -> void:
	if mod_id != MOD_ID:
		return
	if not DEFAULTS.has(key):
		return
	if not (value is bool):
		return
	changed.emit(key, value)
