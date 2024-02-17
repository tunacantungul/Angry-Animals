extends Node

var level_selected: int = 1
var level_scores: Dictionary = {}

const default_score: int = 1000
const scores_path = "user://animals.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_from_disc()

func set_level_selected(ls: int):
	level_selected = ls
	
func get_level_selected() -> int:
	return level_selected

func check_and_add(level: String):
	if level_scores.has(level) == false:
		level_scores[level] = default_score

func set_score_for_level(score: int, level: String):
	check_and_add(level)
	if level_scores[level] > score:
		level_scores[level] = score
		save_to_disc()

func get_best_for_level(level: String):
	check_and_add(level)
	return level_scores[level]

func save_to_disc():
	var file = FileAccess.open(scores_path, FileAccess.WRITE)
	var score_json_str = JSON.stringify(level_scores)
	file.store_string(score_json_str)
	
func load_from_disc():
	var file = FileAccess.open(scores_path, FileAccess.READ)
	if file == null:
		save_to_disc()
	else:
		var data = file.get_as_text()
		level_scores = JSON.parse_string(data)
	
	
