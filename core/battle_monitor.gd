extends RefCounted
## Battle-state helpers.

const NodeUtils = preload("node_utils.gd")


## True when the battle state's simulation reports battle_over.
static func is_over(state) -> bool:
	if not NodeUtils.has_property(state, "simulation"):
		return false
	var sim = state.get("simulation")
	if sim == null or not is_instance_valid(sim):
		return false
	if not NodeUtils.has_property(sim, "data"):
		return false
	var data = sim.get("data")
	if data == null:
		return false
	return bool(data.get("battle_over"))
