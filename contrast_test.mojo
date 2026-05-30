from std.testing import assert_true

from lib.contrast.contrast import Contrast


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def main() raises:
    assert_near(Contrast.ratio_of_tones(-10.0, 110.0), 21.0, 0.001)

    assert_near(Contrast.lighter_tone(90.0, 10.0), -1.0, 0.001)
    assert_near(Contrast.lighter_tone(110.0, 2.0), -1.0, 0.001)
    assert_near(Contrast.lighter_tone(-10.0, 2.0), -1.0, 0.001)
    assert_near(Contrast.lighter_unsafe(100.0, 2.0), 100.0, 0.001)

    assert_near(Contrast.darker_tone(10.0, 20.0), -1.0, 0.001)
    assert_near(Contrast.darker_tone(110.0, 2.0), -1.0, 0.001)
    assert_near(Contrast.darker_tone(-10.0, 2.0), -1.0, 0.001)
    assert_near(Contrast.darker_unsafe(0.0, 2.0), 0.0, 0.001)
