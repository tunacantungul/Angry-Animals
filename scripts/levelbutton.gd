extends TextureButton

const hover_scale: Vector2 = Vector2(1.1, 1.1)
const default_scale: Vector2 = Vector2(1.0, 1.0)

@export var level_number: int = 1

@onready var level_label = $MC/VBoxContainer/LevelLabel
@onready var score_label = $MC/VBoxContainer/ScoreLabel

var level_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	level_label.text = str(level_number)
	var best_score = ScoreManager.get_best_for_level(str(level_number))
	score_label.text = str(best_score)
	level_scene = load("res://scenes/level/level_%s.tscn" % level_number)


func _on_pressed():
	ScoreManager.set_level_selected(level_number)
	get_tree().change_scene_to_packed(level_scene)


func _on_mouse_entered():
	scale = hover_scale


func _on_mouse_exited():
	scale = default_scale
