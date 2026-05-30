from std.math import round
from std.testing import assert_equal, assert_true

from lib.utils.color_utils import ColorUtils


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def range_value(
    start: Float64, stop: Float64, case_count: Int, index: Int
) -> Float64:
    return start + ((stop - start) / Float64(case_count - 1)) * Float64(index)


def rgb_range_value(index: Int) -> Int:
    return Int(round(range_value(0.0, 255.0, 8, index)))


def assert_rgb_near(
    actual_argb: Int, r: Int, g: Int, b: Int, tolerance: Float64
) raises:
    assert_near(
        Float64(ColorUtils.redFromArgb(actual_argb)), Float64(r), tolerance
    )
    assert_near(
        Float64(ColorUtils.greenFromArgb(actual_argb)), Float64(g), tolerance
    )
    assert_near(
        Float64(ColorUtils.blueFromArgb(actual_argb)), Float64(b), tolerance
    )


def main() raises:
    for i in range(1234):
        assert_near(
            range_value(3.0, 9999.0, 1234, i),
            3.0 + 8.1070559611 * Float64(i),
            1e-5,
        )

    for i in range(1001):
        var y = range_value(0.0, 100.0, 1001, i)
        assert_near(ColorUtils.yFromLstar(ColorUtils.lstarFromY(y)), y, 1e-5)
        var lstar = y
        assert_near(
            ColorUtils.lstarFromY(ColorUtils.yFromLstar(lstar)), lstar, 1e-5
        )

    assert_near(ColorUtils.yFromLstar(0.0), 0.0, 1e-5)
    assert_near(ColorUtils.yFromLstar(0.1), 0.0110705, 1e-5)
    assert_near(ColorUtils.yFromLstar(0.2), 0.0221411, 1e-5)
    assert_near(ColorUtils.yFromLstar(0.3), 0.0332116, 1e-5)
    assert_near(ColorUtils.yFromLstar(0.4), 0.0442822, 1e-5)
    assert_near(ColorUtils.yFromLstar(0.5), 0.0553528, 1e-5)
    assert_near(ColorUtils.yFromLstar(1.0), 0.1107056, 1e-5)
    assert_near(ColorUtils.yFromLstar(2.0), 0.2214112, 1e-5)
    assert_near(ColorUtils.yFromLstar(3.0), 0.3321169, 1e-5)
    assert_near(ColorUtils.yFromLstar(4.0), 0.4428225, 1e-5)
    assert_near(ColorUtils.yFromLstar(5.0), 0.5535282, 1e-5)
    assert_near(ColorUtils.yFromLstar(8.0), 0.8856451, 1e-5)
    assert_near(ColorUtils.yFromLstar(10.0), 1.1260199, 1e-5)
    assert_near(ColorUtils.yFromLstar(15.0), 1.9085832, 1e-5)
    assert_near(ColorUtils.yFromLstar(20.0), 2.9890524, 1e-5)
    assert_near(ColorUtils.yFromLstar(25.0), 4.4154767, 1e-5)
    assert_near(ColorUtils.yFromLstar(30.0), 6.2359055, 1e-5)
    assert_near(ColorUtils.yFromLstar(40.0), 11.2509737, 1e-5)
    assert_near(ColorUtils.yFromLstar(50.0), 18.4186518, 1e-5)
    assert_near(ColorUtils.yFromLstar(60.0), 28.1233342, 1e-5)
    assert_near(ColorUtils.yFromLstar(70.0), 40.7494157, 1e-5)
    assert_near(ColorUtils.yFromLstar(80.0), 56.6812907, 1e-5)
    assert_near(ColorUtils.yFromLstar(90.0), 76.3033539, 1e-5)
    assert_near(ColorUtils.yFromLstar(95.0), 87.6183294, 1e-5)
    assert_near(ColorUtils.yFromLstar(99.0), 97.4360239, 1e-5)
    assert_near(ColorUtils.yFromLstar(100.0), 100.0, 1e-5)

    assert_near(ColorUtils.lstarFromY(0.0), 0.0, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.1), 0.9032962, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.2), 1.8065925, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.3), 2.7098888, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.4), 3.6131851, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.5), 4.5164814, 1e-5)
    assert_near(ColorUtils.lstarFromY(0.8856451), 8.0, 1e-5)
    assert_near(ColorUtils.lstarFromY(1.0), 8.9914424, 1e-5)
    assert_near(ColorUtils.lstarFromY(2.0), 15.4872443, 1e-5)
    assert_near(ColorUtils.lstarFromY(3.0), 20.0438970, 1e-5)
    assert_near(ColorUtils.lstarFromY(4.0), 23.6714419, 1e-5)
    assert_near(ColorUtils.lstarFromY(5.0), 26.7347653, 1e-5)
    assert_near(ColorUtils.lstarFromY(10.0), 37.8424304, 1e-5)
    assert_near(ColorUtils.lstarFromY(15.0), 45.6341970, 1e-5)
    assert_near(ColorUtils.lstarFromY(20.0), 51.8372115, 1e-5)
    assert_near(ColorUtils.lstarFromY(25.0), 57.0754208, 1e-5)
    assert_near(ColorUtils.lstarFromY(30.0), 61.6542222, 1e-5)
    assert_near(ColorUtils.lstarFromY(40.0), 69.4695307, 1e-5)
    assert_near(ColorUtils.lstarFromY(50.0), 76.0692610, 1e-5)
    assert_near(ColorUtils.lstarFromY(60.0), 81.8381891, 1e-5)
    assert_near(ColorUtils.lstarFromY(70.0), 86.9968642, 1e-5)
    assert_near(ColorUtils.lstarFromY(80.0), 91.6848609, 1e-5)
    assert_near(ColorUtils.lstarFromY(90.0), 95.9967686, 1e-5)
    assert_near(ColorUtils.lstarFromY(95.0), 98.0335184, 1e-5)
    assert_near(ColorUtils.lstarFromY(99.0), 99.6120372, 1e-5)
    assert_near(ColorUtils.lstarFromY(100.0), 100.0, 1e-5)

    var epsilon = 1e-6
    var delta = 1e-8
    assert_near(
        ColorUtils.yFromLstar(8.0 - delta),
        ColorUtils.yFromLstar(8.0),
        epsilon,
    )
    assert_near(
        ColorUtils.yFromLstar(8.0 + delta),
        ColorUtils.yFromLstar(8.0),
        epsilon,
    )

    for r_index in range(8):
        var r = rgb_range_value(r_index)
        for g_index in range(8):
            var g = rgb_range_value(g_index)
            for b_index in range(8):
                var b = rgb_range_value(b_index)
                var argb = ColorUtils.argbFromRgb(r, g, b)
                var xyz = ColorUtils.xyzFromArgb(argb)
                var converted_xyz = ColorUtils.argbFromXyz(
                    xyz[0], xyz[1], xyz[2]
                )
                assert_rgb_near(converted_xyz, r, g, b, 1.5)

                var lab = ColorUtils.labFromArgb(argb)
                var converted_lab = ColorUtils.argbFromLab(
                    lab[0], lab[1], lab[2]
                )
                assert_rgb_near(converted_lab, r, g, b, 1.5)

                var lstar = ColorUtils.lstarFromArgb(argb)
                var y = ColorUtils.yFromLstar(lstar)
                var y2 = ColorUtils.xyzFromArgb(argb)[1]
                assert_near(y, y2, 1e-5)

    for component in range(256):
        var argb = ColorUtils.argbFromRgb(component, component, component)
        var lstar = ColorUtils.lstarFromArgb(argb)
        var converted = ColorUtils.argbFromLstar(lstar)
        assert_equal(converted, argb)
        assert_equal(
            ColorUtils.delinearized(ColorUtils.linearized(component)),
            component,
        )

    for i in range(1001):
        var lstar = range_value(0.0, 100.0, 1001, i)
        var argb = ColorUtils.argbFromLstar(lstar)
        var y = ColorUtils.xyzFromArgb(argb)[1]
        var y2 = ColorUtils.yFromLstar(lstar)
        assert_near(y, y2, 1.0)
