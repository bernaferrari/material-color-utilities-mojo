from std.collections import List
from std.testing import assert_equal, assert_true

from lib.hct.cam16 import Cam16
from lib.hct.hct import Hct
from lib.hct.viewing_conditions import ViewingConditions
from lib.utils.color_utils import ColorUtils


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def color_is_on_boundary(argb: Int) -> Bool:
    return (
        ColorUtils.redFromArgb(argb) == 0
        or ColorUtils.redFromArgb(argb) == 255
        or ColorUtils.greenFromArgb(argb) == 0
        or ColorUtils.greenFromArgb(argb) == 255
        or ColorUtils.blueFromArgb(argb) == 0
        or ColorUtils.blueFromArgb(argb) == 255
    )


def assert_cam(
    argb: Int,
    j: Float64,
    chroma: Float64,
    hue: Float64,
    m: Float64,
    s: Float64,
    q: Float64,
) raises:
    var cam = Cam16.from_int(argb)
    assert_near(cam.j, j, 0.001)
    assert_near(cam.chroma, chroma, 0.001)
    assert_near(cam.hue, hue, 0.001)
    assert_near(cam.m, m, 0.001)
    assert_near(cam.s, s, 0.001)
    assert_near(cam.q, q, 0.001)


def main() raises:
    comptime black = 0xFF000000
    comptime white = 0xFFFFFFFF
    comptime red = 0xFFFF0000
    comptime green = 0xFF00FF00
    comptime blue = 0xFF0000FF
    comptime midgray = 0xFF777777

    var cam = Cam16.from_int(red)
    assert_equal(red, cam.viewed(ViewingConditions.standard()))
    assert_equal(red, Cam16.fromInt(red).toInt())
    assert_equal(red, Cam16.fromInt(red).to_int())
    assert_true(Hct.from_int(red) == Hct.from_int(red))
    assert_equal(red, Hct.fromInt(red).toInt())
    assert_true(Hct.from_int(red) != Hct.from_int(blue))
    assert_equal("H27 C113 T53", Hct.from_int(red).__str__())

    assert_near(ColorUtils.yFromLstar(50.0), 18.418, 0.001)
    assert_near(ColorUtils.yFromLstar(0.0), 0.0, 0.001)
    assert_near(ColorUtils.yFromLstar(100.0), 100.0, 0.001)

    assert_cam(red, 46.445, 113.357, 27.408, 89.494, 91.889, 105.988)
    assert_cam(green, 79.331, 108.410, 142.139, 85.587, 78.604, 138.520)
    assert_cam(blue, 25.465, 87.230, 282.788, 68.867, 93.674, 78.481)
    assert_cam(black, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    assert_cam(white, 100.0, 2.869, 209.492, 2.265, 12.068, 155.521)

    var colors = List[Int]()
    colors.append(red)
    colors.append(green)
    colors.append(blue)
    colors.append(white)
    for color in colors:
        var color_cam = Cam16.from_int(color)
        var mapped = Hct.from_hct(
            color_cam.hue,
            color_cam.chroma,
            ColorUtils.lstarFromArgb(color),
        ).to_int()
        assert_equal(color, mapped)

    for r in range(0, 256, 51):
        for g in range(0, 256, 51):
            for b in range(0, 256, 51):
                var argb = ColorUtils.argbFromRgb(r, g, b)
                var hct = Hct.from_int(argb)
                var reconstructed = Hct.from_hct(
                    hct.hue, hct.chroma, hct.tone
                ).to_int()
                assert_equal(argb, reconstructed)

    for hue in range(15, 360, 30):
        for chroma in range(0, 101, 10):
            for tone in range(20, 81, 10):
                var hct_color = Hct.from_hct(
                    Float64(hue), Float64(chroma), Float64(tone)
                )
                if chroma > 0:
                    assert_near(hct_color.hue, Float64(hue), 4.0)

                assert_true(hct_color.chroma >= 0.0)
                assert_true(hct_color.chroma <= Float64(chroma) + 2.5)
                if hct_color.chroma < Float64(chroma) - 2.5:
                    assert_true(color_is_on_boundary(hct_color.to_int()))
                assert_near(hct_color.tone, Float64(tone), 0.5)

    var xyz = Cam16.from_int(red).xyz_in_viewing_conditions(
        ViewingConditions.srgb()
    )
    assert_near(xyz[0], 41.23, 0.01)
    assert_near(xyz[1], 21.26, 0.01)
    assert_near(xyz[2], 1.93, 0.01)
    var xyz_alias = Cam16.fromInt(red).xyzInViewingConditions(
        ViewingConditions.srgb()
    )
    assert_near(xyz_alias[0], xyz[0], 0.00001)
    assert_near(xyz_alias[1], xyz[1], 0.00001)
    assert_near(xyz_alias[2], xyz[2], 0.00001)
    assert_equal(
        Hct.from_int(red)
        .in_viewing_conditions(ViewingConditions.srgb())
        .to_int(),
        Hct.fromInt(red).inViewingConditions(ViewingConditions.srgb()).toInt(),
    )

    assert_equal(
        ViewingConditions.srgb().backgroundLstar,
        ViewingConditions.sRgb().backgroundLstar,
    )
    assert_equal(
        ViewingConditions.standard().backgroundLstar,
        ViewingConditions.make().backgroundLstar,
    )

    var red_in_black = (
        Hct.from_int(red)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt()
    )
    assert_equal(red_in_black, 0xFF9F5C51)

    var red_in_white = (
        Hct.from_int(red)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt()
    )
    assert_equal(red_in_white, 0xFFFF5D48)

    assert_equal(
        Hct.from_int(green)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt(),
        0xFFACD69D,
    )
    assert_equal(
        Hct.from_int(green)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt(),
        0xFF8EFF77,
    )
    assert_equal(
        Hct.from_int(blue)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt(),
        0xFF343654,
    )
    assert_equal(
        Hct.from_int(blue)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt(),
        0xFF3F49FF,
    )
    assert_equal(
        Hct.from_int(white)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt(),
        white,
    )
    assert_equal(
        Hct.from_int(white)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt(),
        white,
    )
    assert_equal(
        Hct.from_int(midgray)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt(),
        0xFF605F5F,
    )
    assert_equal(
        Hct.from_int(midgray)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt(),
        0xFF8E8E8E,
    )
    assert_equal(
        Hct.from_int(black)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(0.0))
        .toInt(),
        black,
    )
    assert_equal(
        Hct.from_int(black)
        .inViewingConditions(ViewingConditions.makeWithBackgroundLstar(100.0))
        .toInt(),
        black,
    )
