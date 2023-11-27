import math
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import clampDouble


struct Contrast:
    @staticmethod
    fn ratio_of_tones(tone_a: Float32, tone_b: Float32) -> Float32:
        let tone_a2 = clampDouble(tone_a, 0.0, 100.0)
        let tone_b2 = clampDouble(tone_b, 0.0, 100.0)
        let y_a = ColorUtils.yFromLstar(tone_a2)
        let y_b = ColorUtils.yFromLstar(tone_b2)
        return (math.max(y_a, y_b) + 5.0) / (math.min(y_a, y_b) + 5.0)

    @staticmethod
    fn lighter_tone(tone: Float32, ratio: Float32) -> Float32:
        if tone < 0.0 or tone > 100.0:
            return -1.0
        let dark_y = ColorUtils.yFromLstar(tone)
        let light_y = ratio * (dark_y + 5.0) - 5.0
        let light_tone = ColorUtils.lstarFromY(light_y)
        if tone < 0.0 or tone > 100.0:
            return -1.0
        if light_tone < 0 or light_tone > 1000:
            return -1.0
        return light_tone

    @staticmethod
    fn darker_tone(tone: Float32, ratio: Float32) -> Float32:
        if tone < 0.0 or tone > 100.0:
            return -1.0
        let light_y = ColorUtils.yFromLstar(tone)
        let dark_y = (light_y + 5.0) / ratio - 5.0
        let dark_tone = ColorUtils.lstarFromY(dark_y)
        if dark_tone < 0 or dark_tone > 1000:
            return -1.0
        return dark_tone

    @staticmethod
    fn lighter_unsafe(tone: Float32, ratio: Float32) -> Float32:
        let lighter_safe = Contrast.lighter_tone(tone, ratio)
        return 100.0 if lighter_safe < 0.0 else lighter_safe

    @staticmethod
    fn darker_unsafe(tone: Float32, ratio: Float32) -> Float32:
        let darker_safe = Contrast.darker_tone(tone, ratio)
        return 0.0 if darker_safe < 0.0 else darker_safe
