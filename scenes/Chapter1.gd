extends Node2D

@onready var note: Area2D = $Note
@onready var sfx: AudioStreamPlayer = $SfxJumpscare
@onready var fade: ColorRect = $FadeLayer/ColorRect

var interacted := false

func _ready() -> void:
    GameState.fade_from_black(0.8)
    GameState.randomize()
    _place_note_random()
    note.body_entered.connect(_on_note_body_entered)

func _place_note_random() -> void:
    var spots := $NoteSpawns.get_children()
    if spots.is_empty():
        return
    var idx := randi() % spots.size()
    var spot := spots[idx]
    note.global_position = spot.global_position

func _on_note_body_entered(body: Node) -> void:
    if interacted:
        return
    interacted = true
    note.monitoring = false
    var msg := preload("res://scenes/UI_Message.tscn").instantiate()
    add_child(msg)
    msg.show_text_blocking(GameState.pick_breakdown_line(), 5.0, [])
    await get_tree().create_timer(5.0).timeout
    msg.queue_free()
    _trigger_breakdown()

func _trigger_breakdown() -> void:
    sfx.stream = _build_jumpscare_stream()
    if sfx.playing:
        sfx.stop()
    sfx.play()
    await _fade_to_black(0.35)
    await _show_title_and_back()

func _fade_to_black(duration: float) -> void:
    fade.visible = true
    var tw := create_tween()
    tw.tween_property(fade, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
    await tw.finished

func _show_title_and_back() -> void:
    var msg := preload("res://scenes/UI_Message.tscn").instantiate()
    add_child(msg)
    msg.show_text_blocking("Chapter 1: The Beginning of the End", 1.5, [
        {"label": "Back to Menu", "action": func():
            get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")}
    ])

func _build_jumpscare_stream() -> AudioStreamSample:
    var sample := AudioStreamSample.new()
    sample.mix_rate = 44100
    sample.format = AudioStreamSample.FORMAT_16_BITS
    sample.stereo = false
    sample.loop_mode = AudioStreamSample.LOOP_DISABLED
    var length := int(0.45 * sample.mix_rate)
    var data := PackedByteArray()
    data.resize(length * 2)
    for i in range(length):
        var t := float(i) / float(sample.mix_rate)
        var tone := sin(TAU * 420.0 * t) * (1.0 - t * 1.1)
        var noise := (randf() * 2.0 - 1.0) * 0.5 * (1.0 - t)
        var value := clamp(tone + noise, -1.0, 1.0)
        var int_val := int(value * 32767.0)
        if int_val > 32767:
            int_val = 32767
        elif int_val < -32768:
            int_val = -32768
        data[i * 2] = int_val & 0xFF
        data[i * 2 + 1] = (int_val >> 8) & 0xFF
    sample.data = data
    return sample
