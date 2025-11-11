extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    GameState.fade_from_black(0.6)
    animation_player.animation_finished.connect(_on_animation_finished)
    animation_player.play("enter")

func _on_animation_finished(name: StringName) -> void:
    if name != StringName("enter"):
        return
    await GameState.fade_to_black(0.6)
    var msg := preload("res://scenes/UI_Message.tscn").instantiate()
    add_child(msg)
    msg.show_text_blocking("Hum… I just woke up…", 1.8, [])
    await get_tree().create_timer(2.2).timeout
    msg.queue_free()
    get_tree().change_scene_to_file("res://scenes/Chapter1.tscn")
