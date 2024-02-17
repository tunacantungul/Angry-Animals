extends StaticBody2D

@onready var vanish = $Vanish

func die():
	vanish.play("vanish")


func _on_vanish_animation_finished(anim_name):
	SignalManager.on_cup_destroyed.emit()
	queue_free()
