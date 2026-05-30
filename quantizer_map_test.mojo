from std.collections import List
from std.testing import assert_equal

from lib.quantize.quantizer_map import QuantizerMap


def main() raises:
    var pixels = List[Int]()
    pixels.append(0xFF000000)
    pixels.append(0xFF000000)
    pixels.append(0xFFFFFFFF)
    pixels.append(0x00000000)

    var result = QuantizerMap.quantize(pixels, 128)
    assert_equal(2, result.color_to_count[0xFF000000])
    assert_equal(1, result.color_to_count[0xFFFFFFFF])
    assert_equal(2, len(result.color_to_count))

    var color_to_count = QuantizerMap.quantize_map(pixels)
    assert_equal(2, color_to_count[0xFF000000])
    assert_equal(1, color_to_count[0xFFFFFFFF])
    assert_equal(2, len(color_to_count))
