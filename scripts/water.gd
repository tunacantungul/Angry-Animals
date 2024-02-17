extends Area2D

@onready var splash_sound = $SplashSound

func _on_body_entered(body):
	splash_sound.play()
