from std.collections import Dict, List
from std.testing import assert_equal, TestSuite

from lib.quantize.quantizer_wsmeans import QuantizerWsmeans


def dict_key_at(color_to_count: Dict[Int, Int], index: Int) -> Int:
    var current = 0
    for item in color_to_count.items():
        if current == index:
            return item.key
        current += 1
    return -1


def append_color(mut pixels: List[Int], color: Int, count: Int):
    for _ in range(count):
        pixels.append(color)


def test_quantizer_wsmeans() raises:
    comptime red = 0xFFFF0000
    comptime green = 0xFF00FF00
    comptime blue = 0xFF0000FF
    comptime max_colors = 256

    var random = List[Int]()
    random.append(0xFF141216)
    var random_result = QuantizerWsmeans.quantize(
        random, List[Int](), max_colors
    )
    assert_equal(1, len(random_result.color_to_count))
    assert_equal(0xFF141216, dict_key_at(random_result.color_to_count, 0))

    var red_pixels = List[Int]()
    red_pixels.append(red)
    var red_result = QuantizerWsmeans.quantize(
        red_pixels, List[Int](), max_colors
    )
    assert_equal(1, len(red_result.color_to_count))
    assert_equal(red, dict_key_at(red_result.color_to_count, 0))

    var green_pixels = List[Int]()
    green_pixels.append(green)
    var green_result = QuantizerWsmeans.quantize(
        green_pixels, List[Int](), max_colors
    )
    assert_equal(1, len(green_result.color_to_count))
    assert_equal(green, dict_key_at(green_result.color_to_count, 0))

    var blue_pixels = List[Int]()
    append_color(blue_pixels, blue, 5)
    var blue_result = QuantizerWsmeans.quantize(
        blue_pixels, List[Int](), max_colors
    )
    assert_equal(1, len(blue_result.color_to_count))
    assert_equal(blue, dict_key_at(blue_result.color_to_count, 0))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
