from std.testing import assert_equal, assert_true

from lib.hct.hct import Hct
from lib.temperature.temperature_cache import TemperatureCache


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def main() raises:
    assert_near(
        TemperatureCache.raw_temperature(Hct.from_int(0xFF0000FF)),
        -1.393,
        0.001,
    )
    assert_near(
        TemperatureCache.raw_temperature(Hct.from_int(0xFFFF0000)), 2.351, 0.001
    )
    assert_near(
        TemperatureCache.raw_temperature(Hct.from_int(0xFF00FF00)),
        -0.267,
        0.001,
    )
    assert_near(
        TemperatureCache.raw_temperature(Hct.from_int(0xFFFFFFFF)), -0.5, 0.001
    )
    assert_near(
        TemperatureCache.raw_temperature(Hct.from_int(0xFF000000)), -0.5, 0.001
    )

    assert_near(
        TemperatureCache(Hct.from_int(0xFF0000FF)).input_relative_temperature(),
        0.0,
        0.001,
    )
    assert_near(
        TemperatureCache(Hct.from_int(0xFFFF0000)).input_relative_temperature(),
        1.0,
        0.001,
    )
    assert_near(
        TemperatureCache(Hct.from_int(0xFF00FF00)).input_relative_temperature(),
        0.467,
        0.001,
    )
    assert_near(
        TemperatureCache(Hct.from_int(0xFFFFFFFF)).input_relative_temperature(),
        0.5,
        0.001,
    )
    assert_near(
        TemperatureCache(Hct.from_int(0xFF000000)).input_relative_temperature(),
        0.5,
        0.001,
    )

    assert_equal(
        0xFF9D0002,
        TemperatureCache(Hct.from_int(0xFF0000FF)).complement().to_int(),
    )
    assert_equal(
        0xFF007BFE,
        TemperatureCache(Hct.from_int(0xFFFF0000)).complement().to_int(),
    )
    assert_equal(
        0xFFFFFFFF,
        TemperatureCache(Hct.from_int(0xFFFFFFFF)).complement().to_int(),
    )
    assert_equal(
        0xFFFFD2C9,
        TemperatureCache(Hct.from_int(0xFF00FF00)).complement().to_int(),
    )
    assert_equal(
        0xFF000000,
        TemperatureCache(Hct.from_int(0xFF000000)).complement().to_int(),
    )

    var blue_analogous = TemperatureCache(Hct.from_int(0xFF0000FF)).analogous()
    assert_equal(5, len(blue_analogous))
    assert_equal(0xFF00590C, blue_analogous[0].to_int())
    assert_equal(0xFF00564E, blue_analogous[1].to_int())
    assert_equal(0xFF0000FF, blue_analogous[2].to_int())
    assert_equal(0xFF6700CC, blue_analogous[3].to_int())
    assert_equal(0xFF81009F, blue_analogous[4].to_int())

    var red_analogous = TemperatureCache(Hct.from_int(0xFFFF0000)).analogous()
    assert_equal(0xFFF60082, red_analogous[0].to_int())
    assert_equal(0xFFFC004C, red_analogous[1].to_int())
    assert_equal(0xFFFF0000, red_analogous[2].to_int())
    assert_equal(0xFFD95500, red_analogous[3].to_int())
    assert_equal(0xFFAF7200, red_analogous[4].to_int())

    var green_analogous = TemperatureCache(Hct.from_int(0xFF00FF00)).analogous()
    assert_equal(0xFFCEE900, green_analogous[0].to_int())
    assert_equal(0xFF92F500, green_analogous[1].to_int())
    assert_equal(0xFF00FF00, green_analogous[2].to_int())
    assert_equal(0xFF00FD6F, green_analogous[3].to_int())
    assert_equal(0xFF00FAB3, green_analogous[4].to_int())

    var black_analogous = TemperatureCache(Hct.from_int(0xFF000000)).analogous()
    assert_equal(0xFF000000, black_analogous[0].to_int())
    assert_equal(0xFF000000, black_analogous[1].to_int())
    assert_equal(0xFF000000, black_analogous[2].to_int())
    assert_equal(0xFF000000, black_analogous[3].to_int())
    assert_equal(0xFF000000, black_analogous[4].to_int())

    var white_analogous = TemperatureCache(Hct.from_int(0xFFFFFFFF)).analogous()
    assert_equal(0xFFFFFFFF, white_analogous[0].to_int())
    assert_equal(0xFFFFFFFF, white_analogous[1].to_int())
    assert_equal(0xFFFFFFFF, white_analogous[2].to_int())
    assert_equal(0xFFFFFFFF, white_analogous[3].to_int())
    assert_equal(0xFFFFFFFF, white_analogous[4].to_int())
