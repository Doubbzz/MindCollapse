extends Node
class_name AudioClickGenerator

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
        var normalized_t := clamp(t / duration, 0.0, 1.0)
        var freq := lerp(800.0, 1200.0, normalized_t)
        var amp := max(1.0 - normalized_t, 0.0)
        var value := sin(TAU * freq * t) * amp
        var int_val := int(clamp(value, -1.0, 1.0) * 32767.0)
        data[i * 2] = int_val & 0xFF
        data[i * 2 + 1] = (int_val >> 8) & 0xFF

    sample.data = data
    return sample
