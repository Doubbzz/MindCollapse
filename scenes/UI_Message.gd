extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var body: Label = $Panel/VBoxContainer/Body
@onready var actions: HBoxContainer = $Panel/VBoxContainer/Actions

var _buttons_spawned := false
var _lock_released := true

func _ready() -> void:
    layer = 150
    process_mode = Node.PROCESS_MODE_ALWAYS
    panel.modulate = Color(1, 1, 1, 0)
    var tw := create_tween()
    tw.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.25)

func show_text_blocking(text: String, lock_secs: float, buttons: Array) -> void:
    body.text = text
    for child in actions.get_children():
        child.queue_free()
    actions.visible = false
    _buttons_spawned = false
    _lock_released = false
    GameState.push_input_block()
    await get_tree().process_frame
    await get_tree().create_timer(max(lock_secs, 0.0)).timeout
    if not _lock_released:
        GameState.pop_input_block()
        _lock_released = true
    actions.visible = true
    for data in buttons:
        var btn := Button.new()
        btn.text = data.get("label", "OK")
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.focus_mode = Control.FOCUS_ALL
        if data.has("action") and data["action"] is Callable:
            btn.pressed.connect(data["action"])
        else:
            btn.pressed.connect(func(): queue_free())
        btn.pressed.connect(GameState.play_ui_click)
        actions.add_child(btn)
    if buttons.is_empty():
        actions.visible = false
    else:
        _buttons_spawned = true
        await get_tree().process_frame
        if actions.get_child_count() > 0:
            var first_btn := actions.get_child(0)
            if first_btn is Button:
                first_btn.grab_focus()

func close() -> void:
    if not _buttons_spawned:
        return
    queue_free()

func _exit_tree() -> void:
    if not _lock_released:
        GameState.pop_input_block()
        _lock_released = true
