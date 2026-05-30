from std.collections import Dict, List

from lib.quantize.quantizer import QuantizerResult
from lib.utils.color_utils import ColorUtils


struct QuantizerMap:
    @staticmethod
    def quantize_map(pixels: List[Int]) -> Dict[Int, Int]:
        var count_by_color = Dict[Int, Int]()
        for pixel in pixels:
            if ColorUtils.alphaFromArgb(pixel) < 255:
                continue
            count_by_color[pixel] = count_by_color.get(pixel, 0) + 1
        return count_by_color^

    @staticmethod
    def quantize(pixels: List[Int], max_colors: Int) -> QuantizerResult:
        var count_by_color = QuantizerMap.quantize_map(pixels)
        return QuantizerResult(count_by_color^)
