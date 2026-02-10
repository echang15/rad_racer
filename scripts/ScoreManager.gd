extends Node

const SAVE_PATH = "user://highscores.save"
const MAX_SCORES = 10

# Structure: Array of Dictionaries { "name": "AAA", "score": 12345 }
var high_scores: Array = []

func _ready():
	load_scores()
	if high_scores.is_empty():
		# Default scores if none exist
		high_scores = [
			{"name": "RAD", "score": 5000},
			{"name": "CPU", "score": 4000},
			{"name": "NES", "score": 3000},
			{"name": "GDT", "score": 2000},
			{"name": "BOT", "score": 1000}
		]
		save_scores()

func load_scores():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		if data is Array:
			high_scores = data
			# Ensure loaded data is valid (optional deeper check could go here)
		file.close()

func save_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(high_scores)
	file.close()

func check_is_high_score(score: int) -> bool:
	if high_scores.size() < MAX_SCORES:
		return true
	
	# Check if better than the lowest score
	var lowest_score = high_scores[high_scores.size() - 1]["score"]
	return score > lowest_score

func add_score(player_name: String, score: int):
	var new_entry = {"name": player_name, "score": score}
	high_scores.append(new_entry)
	
	# Sort descending
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	# Keep only top 10
	if high_scores.size() > MAX_SCORES:
		high_scores.resize(MAX_SCORES)
		
	save_scores()
