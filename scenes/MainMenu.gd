extends Control

@onready var play_btn: Button = $CanvasLayer/VBoxContainer/PlayBtn
@onready var run_btn: Button = $CanvasLayer/VBoxContainer/RunBtn
func _ready() -> void:
    GameState.fade_from_black(0.6)
    play_btn.pressed.connect(_on_play)
    run_btn.pressed.connect(_on_run)

func _on_play() -> void:
    GameState.fade_to_black(0.6, func():
        get_tree().change_scene_to_file("res://scenes/CutInDoor.tscn"))

func _on_run() -> void:
    var msg := preload("res://scenes/UI_Message.tscn").instantiate()
    add_child(msg)
    msg.show_text_blocking(
        "You can’t escape your mind. Running only feeds the fear.",
        2.0,
        [
            {"label": "Close Game", "action": func(): get_tree().quit()},
            {"label": "Back to Menu", "action": func(): msg.queue_free()}
        ]
    )
