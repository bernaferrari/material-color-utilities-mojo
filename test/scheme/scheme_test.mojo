from std.testing import assert_equal, assert_true, TestSuite
from std.utils import StaticTuple

from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.hct.hct import Hct
from lib.scheme.scheme import Scheme
from lib.scheme.scheme_tonal_spot import SchemeTonalSpot
from lib.scheme.scheme_vibrant import SchemeVibrant


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def test_scheme() raises:
    var light = Scheme.light(0xFF0000FF)
    assert_equal(0xFF343DFF, light.primary)
    assert_equal(0xFFFFFFFF, light.on_primary)
    assert_equal(0xFFE0E0FF, light.primary_container)

    var dark = Scheme.dark(0xFF0000FF)
    assert_equal(0xFFBEC2FF, dark.primary)
    assert_equal(0xFF0001AC, dark.on_primary)

    var hues = StaticTuple[Float64, 3](0, 42, 360)
    var rotations = StaticTuple[Float64, 3](0, 15, 0)
    assert_near(
        DynamicScheme.get_rotated_hue(
            Hct.from_hct(43, 16, 16), hues, rotations
        ),
        58.0,
        1.0,
    )

    var scheme = SchemeTonalSpot.make(Hct.from_int(0xFF0000FF), False, 0.0)
    assert_equal(36.0, scheme.primary_palette.chroma)
    assert_equal(16.0, scheme.secondary_palette.chroma)

    var vibrant = SchemeVibrant.make(Hct.from_int(0xFF0000FF), False, 0.0)
    assert_equal(200.0, vibrant.primary_palette.chroma)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
