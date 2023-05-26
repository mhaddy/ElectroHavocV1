extends CanvasLayer

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var start_button = $StartButton
@onready var score_label = $ScoreLabel

var score: int = 0

signal start_game

func _ready():
	SignalBus.update_score.connect(_on_update_score)
	
func show_message(text):
	message.text = text
	message.show()
	message.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await message_timer.timeout

	message.text = "Stay alive! LMB to shoot."
	message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	start_button.show()

func _on_update_score(points):
	score += points
	score_label.text = str(score)

func _on_message_timer_timeout():
	message.hide()

func _on_start_button_pressed():
	start_button.hide()
	start_game.emit()