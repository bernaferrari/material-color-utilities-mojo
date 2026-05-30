from std.collections import List

from lib.quantize.quantizer_celebi import QuantizerCelebi
from lib.score.score import Score
from lib.utils.color_utils import ColorUtils


struct ImageUtils:
    @staticmethod
    def source_color_from_image_bytes(image_bytes: List[Int]) -> Int:
        var pixels = List[Int]()
        var i = 0
        while i + 3 < len(image_bytes):
            var r = image_bytes[i]
            var g = image_bytes[i + 1]
            var b = image_bytes[i + 2]
            var a = image_bytes[i + 3]
            if a >= 255:
                pixels.append(ColorUtils.argbFromRgb(r, g, b))
            i += 4

        var result = QuantizerCelebi.quantize(pixels^, 128)
        var ranked = Score.score(result.color_to_count)
        return ranked[0]
