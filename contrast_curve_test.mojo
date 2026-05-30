from std.testing import assert_equal

from lib.dynamiccolor.contrast_curve import ContrastCurve


def main() raises:
    var curve = ContrastCurve(1.0, 3.0, 7.0, 11.0)
    assert_equal(1.0, curve.get(-2.0))
    assert_equal(1.0, curve.get(-1.0))
    assert_equal(2.0, curve.get(-0.5))
    assert_equal(3.0, curve.get(0.0))
    assert_equal(5.0, curve.get(0.25))
    assert_equal(7.0, curve.get(0.5))
    assert_equal(9.0, curve.get(0.75))
    assert_equal(11.0, curve.get(1.0))
    assert_equal(11.0, curve.get(2.0))
    assert_equal(curve.get(0.25), curve.getContrast(0.25))
