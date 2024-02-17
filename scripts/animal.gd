extends RigidBody2D

@onready var launch_sound = $LaunchSound
@onready var stretch_sound = $StretchSound
@onready var arrow = $Arrow
@onready var kick_sound = $KickSound

enum animal_state {READY, DRAG, RELEASE}

const drag_lim_max: Vector2 = Vector2(0,60)
const drag_lim_min: Vector2 = Vector2(-60,0)
const impulse_multiplier: float = 20.0
const impulse_max:float = 1200.0

var start_pos: Vector2 = Vector2.ZERO
var drag_start_pos: Vector2 = Vector2.ZERO
var dragged_vector: Vector2 = Vector2.ZERO
var last_dragged_vector: Vector2 = Vector2.ZERO
var arrow_scale_x: float = 0.0
var last_collision_count: int = 0

var state : animal_state = animal_state.READY

func _ready():
	arrow_scale_x = arrow.scale.x
	arrow.hide()
	start_pos = position
	
func _physics_process(delta):
	update(delta)
	
func get_impulse() -> Vector2:
	return dragged_vector * -1 * impulse_multiplier

func new_state(new_state : animal_state):
	state = new_state
	if state == animal_state.RELEASE:
		arrow.hide()
		freeze = false
		apply_central_impulse(get_impulse())
		launch_sound.play()
		SignalManager.on_attempt_made.emit()
	elif state == animal_state.DRAG:
		drag_start_pos = get_global_mouse_position()
		arrow.show()
	
	
func release_detect() -> bool:
	if state == animal_state.DRAG:
		if Input.is_action_just_released("drag") == true:
			new_state(animal_state.RELEASE)
			return true
	return false

func scale_arrow():
	var imp_len = get_impulse().length()
	var perc = imp_len / impulse_max
	
	arrow.scale.x = (arrow_scale_x * perc) + arrow_scale_x
	arrow.rotation = (start_pos - position).angle()

func play_strech_sound():
	if (last_dragged_vector - dragged_vector).length() > 0:
		if stretch_sound.playing == false:
			stretch_sound.play()
	
func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - drag_start_pos

func drag_in_limits():
	last_dragged_vector = dragged_vector
	
	dragged_vector.x = clampf(dragged_vector.x, drag_lim_min.x, drag_lim_max.x)
	
	dragged_vector.y = clampf(dragged_vector.y, drag_lim_min.y, drag_lim_max.y)
	
	position = start_pos + dragged_vector
	
	
func update_drag():
	if release_detect() == true:
		return
	var gmp = get_global_mouse_position()
	dragged_vector = get_dragged_vector(gmp)
	play_strech_sound()
	drag_in_limits()
	scale_arrow()
	
func play_collision():
	if (last_collision_count == 0 and get_contact_count() > 0 and kick_sound.playing == false):
		kick_sound.play()
		print("played")
	last_collision_count = get_contact_count()
	
func update_flight():
	play_collision()
	
func update(delta : float):
	match state:
		animal_state.DRAG:
			update_drag()
		animal_state.RELEASE:
			update_flight()
			
	
func die():
	SignalManager.on_animal_died.emit()
	queue_free()

func _on_notifier_screen_exited():
	die()


func _on_input_event(viewport, event: InputEvent, shape_idx):
	if state == animal_state.READY and event.is_action_pressed("drag"):
		new_state(animal_state.DRAG)


func _on_sleeping_state_changed():
	if sleeping == true:
		var cb = get_colliding_bodies()
		if cb.size() > 0:
			cb[0].die()
		call_deferred("die")
