extends CharacterBody2D
class_name Player

@export var ACCELERATION: float = 500
@export var MAX_SPEED: float = 275
@export var FRICTION: float = 500
@export var INVINCIBILITY_DELAY: float = 0.5

@onready var weapon_mount_point: Marker2D = $WeaponMountPoint
@onready var gun_controller: Node = $GunController
@onready var stats: Stats = $Stats
@onready var collision_shape_2d = $CollisionShape2D
@onready var invincibility_timer = $InvincibilityTimer
@onready var blink_animation_player = $BlinkAnimationPlayer
@onready var shield_effect = $shieldEffect

enum power_up {
	SHIELD,
	RAPID_FIRE
}

var Death_Animation: PackedScene = preload("res://player/player_death_animation.tscn")
var explosion_sfx: Array = [
	"res://assets/musicSfx/playerExplosion.wav"
]
var world_camera: Camera2D
var invincibility: bool = false

func _ready() -> void:
	invincibility_timer.wait_time = INVINCIBILITY_DELAY

func _physics_process(delta) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO: # when we're moving
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: # when we're idle
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move_and_slide()

	look_at(get_global_mouse_position())
		
	if Input.is_action_pressed("primary_action"):
		gun_controller.fire()
	
	# TODO:
	#if Input.is_action_pressed("secondary_action"):
	#	gun_controller.secondary_fire()

func apply_power_up(type: power_up, duration: float) -> void:
	if type == power_up.SHIELD:
		invincibility = true
		# allows for multiple shield power-ups
		invincibility_timer.start(duration + invincibility_timer.time_left)
		shield_effect.visible = true
		shield_effect.self_modulate.a = 0.5
		
	else: 
		print("Unknown power-up")

# enemy collides with/damages player
func _on_area_2d_body_entered(body) -> void:
	if "enemy" in body.name:
		if not invincibility:
			#stats.current_HP -= body.damage
#			print("enemy hit me ", stats.current_HP, "/", stats.MAX_HP, ", ", body.damage)
			blink_animation_player.play("Start")
			apply_power_up(power_up.SHIELD, INVINCIBILITY_DELAY)

func _on_stats_no_health():
	Globals.player_position = global_position
	print ("game over!")
	SignalBus.emit_signal("game_over")
	
	var explosion = Death_Animation.instantiate()
	explosion.position = get_global_position()
	get_tree().get_root().add_child(explosion)
	
	queue_free()
	
	AudioManager.play_sfx(Globals.random_sfx(explosion_sfx))

func _on_invincibility_timer_timeout():
	invincibility = false
	shield_effect.visible = false
	blink_animation_player.play("Stop")
