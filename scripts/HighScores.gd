extends Control

@export var score_list_container: VBoxContainer
@export var back_button: Button

func _ready():
	display_scores()
	
func display_scores():
	# Clear existing children if any
	for child in score_list_container.get_children():
		child.queue_free()
		
	var scores = ScoreManager.high_scores
	
	for i in range(scores.size()):
		var entry = scores[i]
		var line = HBoxContainer.new()
		
		var rank_lbl = Label.new()
		rank_lbl.text = str(i + 1) + "."
		rank_lbl.custom_minimum_size.x = 40
		
		var name_lbl = Label.new()
		name_lbl.text = entry["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var score_lbl = Label.new()
		score_lbl.text = str(entry["score"])
		
		line.add_child(rank_lbl)
		line.add_child(name_lbl)
		line.add_child(score_lbl)
		
		score_list_container.add_child(line)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
