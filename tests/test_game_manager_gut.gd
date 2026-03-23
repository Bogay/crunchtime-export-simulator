extends GutTest

const GameManager = preload("res://scripts/GameManager.gd")

var gm


func before_each():
	gm = GameManager.new()


func after_each():
	gm.free()


func test_initial_values():
	assert_eq(gm.player_feedback, 0, "Initial feedback should be 0")
	assert_eq(gm.export_cooldown, 3.0, "Initial cooldown should be 3.0")
	assert_eq(gm.fail_chance, 0.3, "Initial fail chance should be 0.3")


func test_upgrade_assets():
	gm.player_feedback = 100
	var cost = gm.calculate_upgrade_cost("assets")
	var success = gm.upgrade_assets()

	assert_true(success, "Upgrade should be successful")
	assert_eq(gm.player_feedback, 100 - cost, "Feedback should be deducted")
	assert_eq(gm.feedback_per_export, 2, "Feedback per export should increase")


func test_upgrade_energy():
	gm.player_feedback = 100
	var initial_cooldown = gm.export_cooldown
	var success = gm.upgrade_energy()

	assert_true(success, "Upgrade should be successful")
	assert_eq(gm.export_cooldown, initial_cooldown - 0.5, "Cooldown should decrease")


func test_calculate_upgrade_cost():
	gm.upgrade_levels["assets"] = 0
	assert_eq(gm.calculate_upgrade_cost("assets"), 10)

	gm.upgrade_levels["assets"] = 1
	assert_eq(gm.calculate_upgrade_cost("assets"), 15) # 10 * 1.5
