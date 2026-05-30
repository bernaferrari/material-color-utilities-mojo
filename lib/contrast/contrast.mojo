import std.math as math
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils


struct Contrast:
    @staticmethod
    def _ratio_of_ys(y1: Float64, y2: Float64) -> Float64:
        var lighter = math.max(y1, y2)
        var darker = math.min(y1, y2)
        return (lighter + 5.0) / (darker + 5.0)

    @staticmethod
    def ratio_of_tones(tone_a: Float64, tone_b: Float64) -> Float64:
        var tone_a2 = MathUtils.clampDouble(0.0, 100.0, tone_a)
        var tone_b2 = MathUtils.clampDouble(0.0, 100.0, tone_b)
        var y_a = ColorUtils.yFromLstar(tone_a2)
        var y_b = ColorUtils.yFromLstar(tone_b2)
        return Contrast._ratio_of_ys(y_a, y_b)

    @staticmethod
    def lighter_tone(tone: Float64, ratio: Float64) -> Float64:
        if tone < 0.0 or tone > 100.0:
            return -1.0
        var dark_y = ColorUtils.yFromLstar(tone)
        var light_y = ratio * (dark_y + 5.0) - 5.0
        var real_contrast = Contrast._ratio_of_ys(light_y, dark_y)
        var delta = math.abs(real_contrast - ratio)
        if real_contrast < ratio and delta > 0.04:
            return -1.0
        var light_tone = ColorUtils.lstarFromY(light_y) + 0.4
        if light_tone < 0 or light_tone > 100:
            return -1.0
        return light_tone

    @staticmethod
    def darker_tone(tone: Float64, ratio: Float64) -> Float64:
        if tone < 0.0 or tone > 100.0:
            return -1.0
        var light_y = ColorUtils.yFromLstar(tone)
        var dark_y = (light_y + 5.0) / ratio - 5.0
        var real_contrast = Contrast._ratio_of_ys(light_y, dark_y)
        var delta = math.abs(real_contrast - ratio)
        if real_contrast < ratio and delta > 0.04:
            return -1.0
        var dark_tone = ColorUtils.lstarFromY(dark_y) - 0.4
        if dark_tone < 0 or dark_tone > 100:
            return -1.0
        return dark_tone

    @staticmethod
    def lighter_unsafe(tone: Float64, ratio: Float64) -> Float64:
        var lighter_safe = Contrast.lighter_tone(tone, ratio)
        return 100.0 if lighter_safe < 0.0 else lighter_safe

    @staticmethod
    def darker_unsafe(tone: Float64, ratio: Float64) -> Float64:
        var darker_safe = Contrast.darker_tone(tone, ratio)
        return 0.0 if darker_safe < 0.0 else darker_safe
