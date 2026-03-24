extends Node

# Core Metrics
var player_feedback: int = 0
var export_cooldown: float = 3.0
var fail_chance: float = 0.3
var feedback_per_export: int = 1
var is_exporting: bool = false
var auto_mode_unlocked: bool = false
var features: int = 0
var feature_timer: float = 0.0
var feature_rate: float = 5.0
var slowdown_factor: float = 1.0

# Upgrade Levels
var upgrade_levels = {
	"assets": 0,
	"energy": 0,
	"tests": 0,
}

# Base Costs
const BASE_COSTS = {
	"assets": 10,
	"energy": 25,
	"tests": 50,
	"auto": 300,
}

# Signal for UI updates
signal state_changed
signal export_started
signal export_finished(success: bool, error_msg: String)

var error_messages = [
	"Error: No Main Scene Defined",
	"Export Failed: WebGL memory out of bounds",
	"Error: Forgot to check SharedArrayBuffer in Export Presets",
	"Crash: Null instance on line 42",
]


func calculate_upgrade_cost(upgrade_id: String) -> int:
	if upgrade_id == "auto":
		return BASE_COSTS["auto"]
	var level = upgrade_levels[upgrade_id]
	return int(BASE_COSTS[upgrade_id] * pow(1.5, level))


func start_export():
	if is_exporting:
		return
	is_exporting = true
	emit_signal("export_started")
	emit_signal("state_changed")


func finish_export():
	var success = randf() > fail_chance
	var error_msg = ""
	if success:
		player_feedback += feedback_per_export * (1 + features)
		features = 0
	else:
		error_msg = error_messages[randi() % error_messages.size()]

	is_exporting = false
	emit_signal("export_finished", success, error_msg)
	emit_signal("state_changed")


func add_feature():
	features += 1
	emit_signal("state_changed")


func process_features(delta: float):
	feature_timer += delta
	var effective_rate = feature_rate + (features * slowdown_factor)
	while feature_timer >= effective_rate:
		feature_timer -= (feature_rate + (features * slowdown_factor))
		add_feature()
		effective_rate = feature_rate + (features * slowdown_factor)


func upgrade_assets():
	var cost = calculate_upgrade_cost("assets")
	if player_feedback >= cost:
		player_feedback -= cost
		upgrade_levels["assets"] += 1
		feedback_per_export += 1
		emit_signal("state_changed")
		return true
	return false


func upgrade_energy():
	var cost = calculate_upgrade_cost("energy")
	if player_feedback >= cost and export_cooldown > 0.5:
		player_feedback -= cost
		upgrade_levels["energy"] += 1
		export_cooldown = max(0.5, export_cooldown - 0.5)
		emit_signal("state_changed")
		return true
	return false


func upgrade_tests():
	var cost = calculate_upgrade_cost("tests")
	if player_feedback >= cost and fail_chance > 0.05:
		player_feedback -= cost
		upgrade_levels["tests"] += 1
		fail_chance = max(0.05, fail_chance - 0.1)
		emit_signal("state_changed")
		return true
	return false


func upgrade_auto():
	var cost = calculate_upgrade_cost("auto")
	if player_feedback >= cost and not auto_mode_unlocked:
		player_feedback -= cost
		auto_mode_unlocked = true
		fail_chance = 0.0
		export_cooldown = 0.2
		emit_signal("state_changed")
		return true
	return false
