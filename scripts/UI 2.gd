extends CanvasLayer

@export var score_label: Label
# @export var distance_label: Label # Removed
@export var cars_label: Label
@export var game_over_label: Label
@export var restart_button: Button
@export var background_dim: ColorRect
@export var name_entry_panel: Panel
@export var name_input: LineEdit
@export var turbo_label: Label
@export var turbo_bar: ProgressBar

var final_score: int = 0

func _ready():
	# HUD is visible, Game Over elements hidden
	if game_over_label: game_over_label.visible = false
	if restart_button: restart_button.visible = false
	if background_dim: background_dim.visible = false
	if name_entry_panel: name_entry_panel.visible = false
	
	var road = get_parent()
	if road.has_signal("score_updated"):
		road.score_updated.connect(update_display)
	if road.has_signal("turbo_updated"):
		road.turbo_updated.connect(update_turbo)
	# Fallback for different node structure if needed
	elif road.get_node_or_null("Game"):
		var game = road.get_node("Game")
		if game.has_signal("score_updated"):
			game.score_updated.connect(update_display)
		if game.has_signal("turbo_updated"):
			game.turbo_updated.connect(update_turbo)

func update_turbo(is_ready, charge_percent, is_active):
	if turbo_label:
		if is_active:
			turbo_label.text = "TURBO!!!"
			turbo_label.add_theme_color_override("font_color", Color(0, 1, 1, 1)) # Cyan
		elif is_ready:
			turbo_label.text = "TURBO READY"
			turbo_label.add_theme_color_override("font_color", Color(0, 1, 0, 1)) # Green
		else:
			turbo_label.text = "RECHARGING"
			turbo_label.add_theme_color_override("font_color", Color(1, 0, 0, 1)) # Red
			
	if turbo_bar:
		turbo_bar.value = charge_percent
		# Optional: Change bar style based on state?


func update_display(score, _distance, cars):
	final_score = score
	if score_label:
		score_label.text = "SCORE: " + str(score)
	# if distance_label:
	# 	distance_label.text = "DIST: " + str(distance)
	if cars_label:
		cars_label.text = "CARS: " + str(cars)

func show_game_over():
	if background_dim: background_dim.visible = true
	get_tree().paused = true
	
	if ScoreManager.check_is_high_score(final_score):
		if name_entry_panel:
			name_entry_panel.visible = true
			if name_input: name_input.grab_focus()
	else:
		if game_over_label: game_over_label.visible = true
		if restart_button: restart_button.visible = true

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_submit_pressed():
	var name = "AAA"
	if name_input and name_input.text.length() > 0:
		name = name_input.text.to_upper()
		
	ScoreManager.add_score(name, final_score)
	
	# Go to high scores
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/HighScores.tscn")
