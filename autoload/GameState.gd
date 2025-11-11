extends Node

var breakdown_lines := [
    "Nice... you’re one step closer to collapse.",
    "Keep going — the cracks are showing.",
    "Another step, another fracture in your mind.",
    "You moved forward. Your sanity didn’t.",
    "Closer than ever. Too close."
]

var _rng := RandomNumberGenerator.new()
var _fade_rect: ColorRect
var _fade_layer: CanvasLayer
var _ui_click: AudioStreamPlayer
var _input_blockers := 0

func _ready() -> void:
    randomize()
    _setup_fade_layer()
    _setup_ui_click()

func randomize() -> void:
    _rng.randomize()

func pick_breakdown_line() -> String:
    if breakdown_lines.is_empty():
        return "The void echoes back at you."
    return breakdown_lines[_rng.randi_range(0, breakdown_lines.size() - 1)]

func fade_to_black(duration: float = 0.6, on_done: Callable = Callable()) -> void:
    if _fade_rect == null:
        return
    _fade_rect.visible = true
    _fade_rect.modulate.a = 0.0
    var tw := create_tween()
    tw.tween_property(_fade_rect, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    await tw.finished
    if on_done.is_valid():
        on_done.call()

func fade_from_black(duration: float = 0.6) -> void:
    if _fade_rect == null:
        return
    _fade_rect.visible = true
    _fade_rect.modulate.a = 1.0
    var tw := create_tween()
    tw.tween_property(_fade_rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    await tw.finished
    _fade_rect.visible = false

func play_ui_click() -> void:
    if _ui_click == null:
        return
    if _ui_click.stream == null:
        _ui_click.stream = _build_ui_click_sample()
    if _ui_click.playing:
        _ui_click.stop()
    _ui_click.play()

func push_input_block() -> void:
    _input_blockers += 1

func pop_input_block() -> void:
    _input_blockers = max(_input_blockers - 1, 0)

func inputs_locked() -> bool:
    return _input_blockers > 0

func _setup_fade_layer() -> void:
    _fade_layer = CanvasLayer.new()
    _fade_layer.name = "GlobalFade"
    _fade_layer.layer = 200
    add_child(_fade_layer)

    _fade_rect = ColorRect.new()
    _fade_rect.name = "FadeRect"
    _fade_rect.color = Color(0, 0, 0, 1)
    _fade_rect.modulate.a = 0.0
    _fade_rect.visible = false
    _fade_rect.size = Vector2(4096, 4096)
    _fade_rect.anchor_left = 0.0
    _fade_rect.anchor_top = 0.0
    _fade_rect.anchor_right = 1.0
    _fade_rect.anchor_bottom = 1.0
    _fade_rect.offset_left = 0.0
    _fade_rect.offset_top = 0.0
    _fade_rect.offset_right = 0.0
    _fade_rect.offset_bottom = 0.0
    _fade_layer.add_child(_fade_rect)

func _setup_ui_click() -> void:
    _ui_click = AudioStreamPlayer.new()
    _ui_click.name = "UIClick"
    _ui_click.bus = "Master"
    _ui_click.stream = _build_ui_click_sample()
    add_child(_ui_click)

func _build_ui_click_sample() -> AudioStreamSample:
    var sample := AudioStreamSample.new()
    sample.mix_rate = 44100
    sample.format = AudioStreamSample.FORMAT_16_BITS
    sample.stereo = false
    sample.loop_mode = AudioStreamSample.LOOP_DISABLED
    var duration := 0.18
    var length := int(duration * sample.mix_rate)
    var data := PackedByteArray()
    data.resize(length * 2)
    for i in range(length):
        var t := float(i) / float(sample.mix_rate)
        var freq := 800.0 + t * 400.0
        var amp := clamp(1.0 - t * 4.0, 0.0, 1.0)
        var value := sin(TAU * freq * t) * amp
        var int_val := int(value * 32767.0)
        data[i * 2] = int_val & 0xFF
        data[i * 2 + 1] = (int_val >> 8) & 0xFF
    sample.data = data
    return sample
