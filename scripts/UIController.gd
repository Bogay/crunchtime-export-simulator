extends Control

@onready var game_manager = $GameManager
@onready var feedback_label = $VBoxContainer/FeedbackLabel
@onready var features_label = $VBoxContainer/FeaturesLabel
@onready var export_button = $VBoxContainer/ExportButton
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var upgrade_assets_button = $VBoxContainer/Upgrades/UpgradeAssets
@onready var upgrade_energy_button = $VBoxContainer/Upgrades/UpgradeEnergy
@onready var upgrade_tests_button = $VBoxContainer/Upgrades/UpgradeTests
@onready var upgrade_auto_button = $VBoxContainer/Upgrades/UpgradeAuto

var export_timer: float = 0.0


func _ready():
	game_manager.state_changed.connect(_on_state_changed)
	game_manager.export_started.connect(_on_export_started)
	game_manager.export_finished.connect(_on_export_finished)

	export_button.pressed.connect(_on_export_pressed)
	upgrade_assets_button.pressed.connect(_on_upgrade_assets_pressed)
	upgrade_energy_button.pressed.connect(_on_upgrade_energy_pressed)
	upgrade_tests_button.pressed.connect(_on_upgrade_tests_pressed)
	upgrade_auto_button.pressed.connect(_on_upgrade_auto_pressed)

	_on_state_changed()


func _process(delta):
	game_manager.process_features(delta)

	if game_manager.is_exporting:
		export_timer += delta
		progress_bar.value = (export_timer / game_manager.export_cooldown) * 100

		if export_timer >= game_manager.export_cooldown:
			export_timer = 0.0
			game_manager.finish_export()
			if game_manager.auto_mode_unlocked:
				game_manager.start_export()


func _on_state_changed():
	feedback_label.text = "Player Feedback: %d" % game_manager.player_feedback
	features_label.text = "New Features: %d" % game_manager.features

	var assets_cost = game_manager.calculate_upgrade_cost("assets")
	var energy_cost = game_manager.calculate_upgrade_cost("energy")
	var tests_cost = game_manager.calculate_upgrade_cost("tests")
	var auto_cost = game_manager.calculate_upgrade_cost("auto")

	upgrade_assets_button.text = "Upgrade Assets: %d" % assets_cost
	upgrade_energy_button.text = "Upgrade Energy: %d" % energy_cost
	upgrade_tests_button.text = "Upgrade Tests: %d" % tests_cost
	upgrade_auto_button.text = "Setup CI/CD: %d" % auto_cost

	upgrade_assets_button.disabled = game_manager.player_feedback < assets_cost
	upgrade_energy_button.disabled = (
		game_manager.player_feedback < energy_cost or game_manager.export_cooldown <= 0.5
	)
	upgrade_tests_button.disabled = (
		game_manager.player_feedback < tests_cost or game_manager.fail_chance <= 0.05
	)
	upgrade_auto_button.disabled = (
		game_manager.player_feedback < auto_cost or game_manager.auto_mode_unlocked
	)

	if game_manager.auto_mode_unlocked:
		upgrade_auto_button.text = "CI/CD Running!"


func _on_export_pressed():
	game_manager.start_export()


func _on_export_started():
	export_button.disabled = true
	error_label.text = ""
	progress_bar.modulate = Color.WHITE


func _on_export_finished(success: bool, error_msg: String):
	if success:
		progress_bar.modulate = Color.GREEN
		progress_bar.value = 100
	else:
		progress_bar.modulate = Color.RED
		error_label.text = error_msg
		# Penalty delay if not in auto mode
		if not game_manager.auto_mode_unlocked:
			await get_tree().create_timer(2.0).timeout

	if not game_manager.auto_mode_unlocked:
		export_button.disabled = false


func _on_upgrade_assets_pressed():
	game_manager.upgrade_assets()


func _on_upgrade_energy_pressed():
	game_manager.upgrade_energy()


func _on_upgrade_tests_pressed():
	game_manager.upgrade_tests()


func _on_upgrade_auto_pressed():
	if game_manager.upgrade_auto():
		game_manager.start_export()
