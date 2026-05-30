from std.testing import assert_equal, assert_true
from std.utils import StaticTuple

from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.palettes.core_palette import CorePalette
from lib.utils.color_utils import ColorUtils


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def assert_color_close(actual: Int, expected: Int, tolerance: Int = 2) raises:
    assert_true(
        abs(ColorUtils.redFromArgb(actual) - ColorUtils.redFromArgb(expected))
        <= tolerance
    )
    assert_true(
        abs(
            ColorUtils.greenFromArgb(actual)
            - ColorUtils.greenFromArgb(expected)
        )
        <= tolerance
    )
    assert_true(
        abs(ColorUtils.blueFromArgb(actual) - ColorUtils.blueFromArgb(expected))
        <= tolerance
    )


def main() raises:
    var hct = Hct.from_int(0xFF0000FF)
    var tones = TonalPalette.of(hct.hue, hct.chroma)

    assert_equal(0xFF000000, tones.get(0))
    assert_color_close(tones.get(10), 0xFF00006E, 1)
    assert_color_close(tones.get(20), 0xFF0001AC, 1)
    assert_color_close(tones.get(30), 0xFF0000EF, 1)
    assert_color_close(tones.get(40), 0xFF343DFF, 1)
    assert_color_close(tones.get(50), 0xFF5A64FF, 1)
    assert_color_close(tones.get(60), 0xFF7C84FF, 1)
    assert_color_close(tones.get(70), 0xFF9DA3FF, 1)
    assert_color_close(tones.get(80), 0xFFBEC2FF, 1)
    assert_color_close(tones.get(90), 0xFFE0E0FF, 1)
    assert_color_close(tones.get(95), 0xFFF1EFFF, 1)
    assert_color_close(tones.get(99), 0xFFFFFBFF, 1)
    assert_equal(0xFFFFFFFF, tones.get(100))
    assert_equal(0xFF00003C, tones.get(3))

    assert_equal(0xFF000000, tones.as_list()[0])
    assert_equal(0xFF00006E, tones.as_list()[1])
    assert_equal(0xFFBEC2FF, tones.as_list()[8])
    assert_equal(0xFFFFFFFF, tones.as_list()[12])

    var from_list = TonalPalette.from_list(
        StaticTuple[Int, 13](0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
    )
    assert_equal(12, from_list.get(100))
    assert_equal(5, from_list.get(50))
    assert_equal(0, from_list.get(0))

    var hue_chroma_palette = TonalPalette.of(270.0, 36.0)
    var cached_palette = hue_chroma_palette.as_list()
    var broken_palette = StaticTuple[Int, 13](
        cached_palette[0],
        cached_palette[1],
        Hct.from_hct(180.0, 24.0, 20.0).to_int(),
        cached_palette[3],
        cached_palette[4],
        cached_palette[5],
        cached_palette[6],
        cached_palette[7],
        cached_palette[8],
        Hct.from_hct(0.0, 12.0, 90.0).to_int(),
        cached_palette[10],
        cached_palette[11],
        cached_palette[12],
    )
    var rebuilt_palette = TonalPalette.from_list(broken_palette)
    var rebuilt_clean_palette = TonalPalette.from_list(cached_palette)
    assert_near(rebuilt_palette.hue, 270.0, 1.0)
    assert_near(rebuilt_palette.chroma, 36.0, 1.0)
    assert_equal(rebuilt_clean_palette.hue, rebuilt_palette.hue)
    assert_equal(rebuilt_clean_palette.chroma, rebuilt_palette.chroma)
    assert_equal(broken_palette[2], rebuilt_palette.get(20))
    assert_equal(broken_palette[5], rebuilt_palette.get(50))
    assert_equal(broken_palette[9], rebuilt_palette.get(90))
    assert_equal(broken_palette[11], rebuilt_palette.get(99))
    assert_color_close(rebuilt_palette.get(15), hue_chroma_palette.get(15))
    assert_color_close(rebuilt_palette.get(53), hue_chroma_palette.get(53))
    assert_color_close(rebuilt_palette.get(78), hue_chroma_palette.get(78))
    assert_near(rebuilt_palette.get_hct(15.0).tone, 15.0, 1.0)
    assert_near(rebuilt_palette.get_hct(53.0).tone, 53.0, 1.0)
    assert_near(rebuilt_palette.get_hct(78.0).tone, 78.0, 1.0)
    assert_equal(
        12,
        TonalPalette.from_list(
            StaticTuple[Int, 13](0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
        ).as_list()[12],
    )

    var palette_1 = TonalPalette.of(270.0, 36.0)
    var palette_2 = TonalPalette.of(180.0, 36.0)
    var palette_3 = TonalPalette.of(270.0, 12.0)
    var palette_4 = TonalPalette.from_list(palette_1.as_list())
    var broken_list = palette_1.as_list()
    broken_list[2] = Hct.from_hct(180.0, 24.0, 20.0).to_int()
    broken_list[9] = Hct.from_hct(0.0, 12.0, 90.0).to_int()
    var palette_5 = TonalPalette.from_list(broken_list)
    assert_true(palette_1 == palette_1)
    assert_true(palette_1 != palette_2)
    assert_true(palette_1 != palette_3)
    assert_true(palette_1 == palette_4)
    assert_true(palette_1 != palette_5)
    assert_true(palette_4 == palette_1)
    assert_true(palette_5 == palette_5)
    assert_true(palette_5 != palette_4)
    assert_equal("TonalPalette.of(270.0, 36.0)", palette_1.__str__())
    assert_equal("TonalPalette.fromList(...)", palette_4.__str__())

    var core = CorePalette.of(0xFF0000FF)
    assert_equal(0xFFFFFFFF, core.primary.get(100))
    assert_equal(0xFF000000, core.primary.get(0))
    assert_true(core == CorePalette.of(0xFF0000FF))
    assert_true(core != CorePalette.of(0xFF123456))
    assert_true(CorePalette.from_list(core.as_list()) == core)
    assert_equal(True, core.__str__().byte_length() > 0)

    var content = CorePalette.content_of(0xFF0000FF)
    assert_equal(0xFFFFFFFF, content.primary.get(100))
    assert_equal(0xFF000000, content.primary.get(0))
