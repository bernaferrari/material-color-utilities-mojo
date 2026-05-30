from std.collections import Dict, List
from std.testing import assert_equal, assert_true

from lib.quantize.quantizer_celebi import QuantizerCelebi
from lib.quantize.quantizer_wu import QuantizerWu
from lib.quantize.quantizer_wsmeans import QuantizerWsmeans
from lib.quantize.src.point_provider_lab import PointProviderLab


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


def single_color_cases() raises:
    var red = List[Int]()
    append_color(red, 0xFFFF0000, 1)
    var wu_red = QuantizerWu.quantize(red, 256)
    assert_equal(1, len(wu_red.color_to_count))
    assert_equal(0xFFFF0000, dict_key_at(wu_red.color_to_count, 0))

    var ws_red = QuantizerWsmeans.quantize(red, List[Int](), 256)
    assert_equal(1, len(ws_red.color_to_count))
    assert_equal(0xFFFF0000, dict_key_at(ws_red.color_to_count, 0))

    var celebi_red = QuantizerCelebi.quantize(red, 256)
    assert_equal(1, len(celebi_red.color_to_count))
    assert_equal(0xFFFF0000, dict_key_at(celebi_red.color_to_count, 0))
    assert_equal(1, QuantizerCelebi.quantize_map(red, 256)[0xFFFF0000])

    var green = List[Int]()
    append_color(green, 0xFF00FF00, 1)
    var celebi_green = QuantizerCelebi.quantize(green, 256)
    assert_equal(1, len(celebi_green.color_to_count))
    assert_equal(1, celebi_green.color_to_count[0xFF00FF00])

    var random = List[Int]()
    append_color(random, 0xFF141216, 1)
    var wu = QuantizerWu.quantize(random, 256)
    assert_equal(1, len(wu.color_to_count))
    assert_equal(0xFF141216, dict_key_at(wu.color_to_count, 0))
    var ws_random = QuantizerWsmeans.quantize(random, List[Int](), 256)
    assert_equal(0xFF141216, dict_key_at(ws_random.color_to_count, 0))

    var blue = List[Int]()
    append_color(blue, 0xFF0000FF, 5)
    var wu_blue = QuantizerWu.quantize(blue, 256)
    assert_equal(1, len(wu_blue.color_to_count))
    assert_equal(0xFF0000FF, dict_key_at(wu_blue.color_to_count, 0))
    var ws_blue = QuantizerWsmeans.quantize(blue, List[Int](), 256)
    assert_equal(1, len(ws_blue.color_to_count))
    assert_equal(0xFF0000FF, dict_key_at(ws_blue.color_to_count, 0))
    var celebi = QuantizerCelebi.quantize(blue, 256)
    assert_equal(1, len(celebi.color_to_count))
    assert_equal(5, celebi.color_to_count[0xFF0000FF])
    assert_equal(0xFF0000FF, dict_key_at(celebi.color_to_count, 0))


def multicolor_cases() raises:
    var red_green = List[Int]()
    append_color(red_green, 0xFFFF0000, 2)
    append_color(red_green, 0xFF00FF00, 3)
    var wu_rg = QuantizerWu.quantize(red_green, 256)
    assert_equal(2, len(wu_rg.color_to_count))
    assert_equal(0xFF00FF00, dict_key_at(wu_rg.color_to_count, 0))
    assert_equal(0xFFFF0000, dict_key_at(wu_rg.color_to_count, 1))
    var celebi_rg = QuantizerCelebi.quantize(red_green, 256)
    assert_equal(2, len(celebi_rg.color_to_count))
    assert_equal(0xFF00FF00, dict_key_at(celebi_rg.color_to_count, 0))
    assert_equal(0xFFFF0000, dict_key_at(celebi_rg.color_to_count, 1))
    assert_equal(2, celebi_rg.color_to_count[0xFFFF0000])
    assert_equal(3, celebi_rg.color_to_count[0xFF00FF00])

    var rgb = List[Int]()
    rgb.append(0xFFFF0000)
    rgb.append(0xFF00FF00)
    rgb.append(0xFF0000FF)
    var wu_rgb = QuantizerWu.quantize(rgb, 256)
    assert_equal(3, len(wu_rgb.color_to_count))
    assert_equal(0xFF0000FF, dict_key_at(wu_rgb.color_to_count, 0))
    assert_equal(0xFFFF0000, dict_key_at(wu_rgb.color_to_count, 1))
    assert_equal(0xFF00FF00, dict_key_at(wu_rgb.color_to_count, 2))
    var celebi_rgb = QuantizerCelebi.quantize(rgb, 256)
    assert_equal(3, len(celebi_rgb.color_to_count))
    assert_equal(0xFF0000FF, dict_key_at(celebi_rgb.color_to_count, 0))
    assert_equal(0xFFFF0000, dict_key_at(celebi_rgb.color_to_count, 1))
    assert_equal(0xFF00FF00, dict_key_at(celebi_rgb.color_to_count, 2))
    assert_equal(1, celebi_rgb.color_to_count[0xFFFF0000])
    assert_equal(1, celebi_rgb.color_to_count[0xFF00FF00])
    assert_equal(1, celebi_rgb.color_to_count[0xFF0000FF])


def main() raises:
    single_color_cases()
    multicolor_cases()

    var pixels = List[Int]()
    pixels.append(0xFFFF0000)
    pixels.append(0xFFFF0000)
    pixels.append(0xFF00FF00)
    pixels.append(0xFF0000FF)

    var wu = QuantizerWu.quantize(pixels, 2)
    assert_equal(2, len(wu.color_to_count))
    assert_true(wu.color_to_count.get(0xFFFF0000, -1) >= 0)

    var clusters = List[Int]()
    clusters.append(0xFFFF0000)
    var wsmeans = QuantizerWsmeans.quantize(pixels, clusters^, 3)
    assert_equal(3, len(wsmeans.color_to_count))
    assert_equal(2, wsmeans.color_to_count[0xFFFF0000])

    var celebi = QuantizerCelebi.quantize(pixels, 3)
    assert_equal(3, len(celebi.color_to_count))
    assert_equal(2, celebi.color_to_count[0xFFFF0000])

    var lab = PointProviderLab.from_int(0xFFFF0000)
    assert_equal(0xFFFF0000, PointProviderLab.to_int(lab))
