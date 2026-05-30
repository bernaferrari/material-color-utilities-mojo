from std.collections import Dict, List

from lib.quantize.quantizer import QuantizerResult
from lib.quantize.quantizer_wu import QuantizerWu
from lib.quantize.quantizer_wsmeans import QuantizerWsmeans


struct QuantizerCelebi:
    @staticmethod
    def quantize(pixels: List[Int], max_colors: Int) -> QuantizerResult:
        var wu = QuantizerWu.quantize(pixels, max_colors)
        var clusters = List[Int]()
        for item in wu.color_to_count.items():
            clusters.append(item.key)
        return QuantizerWsmeans.quantize(pixels, clusters^, max_colors)

    @staticmethod
    def quantize_map(pixels: List[Int], max_colors: Int) -> Dict[Int, Int]:
        var result = QuantizerCelebi.quantize(pixels, max_colors)
        return result.color_to_count.copy()
