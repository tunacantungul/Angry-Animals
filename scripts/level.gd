extends Node

const ANIMAL = preload("res://scenes/animal/animal.tscn")

@onready var spawn = $Spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_bird()
	SignalManager.on_animal_died.connect(spawn_bird)


func spawn_bird():
	var spawn_bird = ANIMAL.instantiate()
	spawn_bird.position = spawn.position
	add_child(spawn_bird)
