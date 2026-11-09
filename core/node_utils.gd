extends RefCounted
## Scene-tree reflection helpers shared by the mod's modules.

## True when `obj` is a valid instance that exposes `property`.
static func has_property(obj, property: String) -> bool:
	if not is_instance_valid(obj):
		return false
	return property in obj


## True when `obj`'s script (or any base script) is `script_path`.
static func script_is(obj, script_path: String) -> bool:
	if not is_instance_valid(obj):
		return false
	var script: Script = obj.get_script()
	while script != null:
		if str(script.resource_path) == script_path:
			return true
		script = script.get_base_script()
	return false
