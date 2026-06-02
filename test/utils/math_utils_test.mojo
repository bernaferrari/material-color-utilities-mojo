from std.math import abs
from std.testing import assert_equal, TestSuite

from lib.utils.math_utils import MathUtils


def original_rotation_direction(
    from_value: Float64, to_value: Float64
) -> Float64:
    var a = to_value - from_value
    var b = to_value - from_value + 360.0
    var c = to_value - from_value - 360.0
    var a_abs = abs(a)
    var b_abs = abs(b)
    var c_abs = abs(c)
    if a_abs <= b_abs and a_abs <= c_abs:
        return 1.0 if a >= 0.0 else -1.0
    if b_abs <= a_abs and b_abs <= c_abs:
        return 1.0 if b >= 0.0 else -1.0
    return 1.0 if c >= 0.0 else -1.0


def test_math_utils() raises:
    var from_value = 0.0
    while from_value < 360.0:
        var to_value = 7.5
        while to_value < 360.0:
            var expected = original_rotation_direction(from_value, to_value)
            var actual = MathUtils.rotationDirection(from_value, to_value)
            assert_equal(expected, actual)
            assert_equal(1.0, abs(actual))
            to_value += 15.0
        from_value += 15.0


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
