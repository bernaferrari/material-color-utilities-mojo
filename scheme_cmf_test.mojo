from std.testing import assert_equal, assert_true

from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.scheme.scheme_cmf import SchemeCmf


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def main() raises:
    var primary = Hct.from_int(0xFFFF0000)
    var secondary = Hct.from_int(0xFF0000FF)
    var scheme = SchemeCmf.make_with_secondary(primary, secondary, False, 0.0)

    assert_equal(Variant.cmf, scheme.variant)
    assert_equal(primary.to_int(), scheme.source_color_argb)
    assert_near(scheme.primary_palette.hue, primary.hue, 0.0001)
    assert_near(scheme.primary_palette.chroma, primary.chroma, 0.0001)
    assert_near(scheme.secondary_palette.hue, primary.hue, 0.0001)
    assert_near(scheme.secondary_palette.chroma, primary.chroma * 0.5, 0.0001)
    assert_near(scheme.tertiary_palette.hue, secondary.hue, 0.0001)
    assert_near(scheme.tertiary_palette.chroma, secondary.chroma, 0.0001)
    assert_near(scheme.neutral_palette.hue, primary.hue, 0.0001)
    assert_near(scheme.neutral_palette.chroma, primary.chroma * 0.2, 0.0001)
    assert_near(scheme.neutral_variant_palette.hue, primary.hue, 0.0001)
    assert_near(
        scheme.neutral_variant_palette.chroma, primary.chroma * 0.2, 0.0001
    )
    assert_near(
        scheme.error_palette.hue,
        SchemeCmf.get_error_hue(primary.hue, secondary.hue),
        0.0001,
    )

    var single_source = SchemeCmf.make(primary, True, 0.5)
    assert_near(single_source.tertiary_palette.hue, primary.hue, 0.0001)
    assert_near(
        single_source.tertiary_palette.chroma, primary.chroma * 0.75, 0.0001
    )
    assert_near(single_source.error_palette.chroma, primary.chroma, 0.0001)

    assert_equal(28.0, SchemeCmf.get_error_hue(8.0, 24.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(8.0, 32.0))
    assert_equal(20.0, SchemeCmf.get_error_hue(8.0, 33.0))
    assert_equal(32.0, SchemeCmf.get_error_hue(16.0, 24.0))
    assert_equal(20.0, SchemeCmf.get_error_hue(16.0, 32.0))
    assert_equal(24.0, SchemeCmf.get_error_hue(16.0, 33.0))
    assert_equal(32.0, SchemeCmf.get_error_hue(20.0, 28.0))
    assert_equal(24.0, SchemeCmf.get_error_hue(20.0, 32.0))
    assert_equal(28.0, SchemeCmf.get_error_hue(20.0, 33.0))
    assert_equal(32.0, SchemeCmf.get_error_hue(28.0, 24.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(28.0, 25.0))
    assert_equal(24.0, SchemeCmf.get_error_hue(32.0, 20.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(32.0, 28.0))
    assert_equal(20.0, SchemeCmf.get_error_hue(32.0, 29.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(40.0, 28.0))
    assert_equal(24.0, SchemeCmf.get_error_hue(40.0, 29.0))
    assert_equal(20.0, SchemeCmf.get_error_hue(152.0, 36.0))
    assert_equal(32.0, SchemeCmf.get_error_hue(152.0, 37.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(272.0, 28.0))
    assert_equal(24.0, SchemeCmf.get_error_hue(272.0, 29.0))
    assert_equal(32.0, SchemeCmf.get_error_hue(300.0, 28.0))
    assert_equal(16.0, SchemeCmf.get_error_hue(300.0, 29.0))
