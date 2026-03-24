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


func test_features_and_feedback():
	assert_eq(gm.features, 0, "Should have features variable initialized to 0")

	gm.add_feature()
	gm.add_feature()
	assert_eq(gm.features, 2, "Features should increment")

	var initial_feedback = gm.player_feedback
	gm.fail_chance = -1.0 # Force success
	gm.finish_export()

	assert_gt(gm.player_feedback, initial_feedback, "Feedback should increase with features")
	assert_eq(gm.features, 0, "Features should reset after successful export")


func test_feedback_calculation_with_features():
	gm.features = 10
	gm.feedback_per_export = 2
	gm.fail_chance = -1.0
	gm.finish_export()
	# Expected: 2 * (1 + 10) = 22
	assert_eq(gm.player_feedback, 22, "Feedback should be multiplied by (1 + features)")


func test_feature_generation():
	gm.features = 0
	# Manual call to process features
	# With slowdown: 1st takes 5s, 2nd takes 6s, 3rd takes 7s
	gm.process_features(6.0) # 5s base
	assert_eq(gm.features, 1, "Should generate 1 feature after 6 seconds")

	gm.process_features(10.0) # 16s total. Need 5+6+7=18s for 3 features.
	assert_eq(gm.features, 2, "Should have 2 features total (at 16s)")

	gm.process_features(3.0) # 19s total.
	assert_eq(gm.features, 3, "Should have 3 features total (at 19s)")


func test_feature_generation_slowdown():
	gm.features = 0
	gm.feature_timer = 0.0
	gm.feature_rate = 1.0 # Base rate 1s for testing

	# First feature at 1s
	gm.process_features(1.1)
	assert_eq(gm.features, 1, "First feature should take ~1s")

	# Second feature should take longer than 1s
	gm.feature_timer = 0.0
	gm.process_features(1.1)
	assert_eq(gm.features, 1, "Second feature should NOT have generated yet at 1.1s")

	gm.process_features(1.0) # 2.1s total for second feature
	assert_eq(gm.features, 2, "Second feature should generate after more time")
