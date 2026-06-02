from std.collections import List
from std.testing import assert_true, TestSuite

from lib.contrast.contrast import Contrast
from lib.dynamiccolor.contrast_curve import ContrastCurve
from lib.dynamiccolor.dynamic_color import DynamicColorRole
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from lib.dynamiccolor.src.tone_delta_pair import TonePolarity
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.scheme.scheme_content import SchemeContent
from lib.scheme.scheme_expressive import SchemeExpressive
from lib.scheme.scheme_fidelity import SchemeFidelity
from lib.scheme.scheme_fruit_salad import SchemeFruitSalad
from lib.scheme.scheme_monochrome import SchemeMonochrome
from lib.scheme.scheme_neutral import SchemeNeutral
from lib.scheme.scheme_rainbow import SchemeRainbow
from lib.scheme.scheme_tonal_spot import SchemeTonalSpot
from lib.scheme.scheme_vibrant import SchemeVibrant


def scheme_from_variant(
    variant: Int, source: Hct, is_dark: Bool, contrast_level: Float64
) -> DynamicScheme:
    if variant == Variant.monochrome:
        return SchemeMonochrome.make(source, is_dark, contrast_level)
    if variant == Variant.neutral:
        return SchemeNeutral.make(source, is_dark, contrast_level)
    if variant == Variant.tonal_spot:
        return SchemeTonalSpot.make(source, is_dark, contrast_level)
    if variant == Variant.vibrant:
        return SchemeVibrant.make(source, is_dark, contrast_level)
    if variant == Variant.expressive:
        return SchemeExpressive.make(source, is_dark, contrast_level)
    if variant == Variant.fidelity:
        return SchemeFidelity.make(source, is_dark, contrast_level)
    if variant == Variant.content:
        return SchemeContent.make(source, is_dark, contrast_level)
    if variant == Variant.rainbow:
        return SchemeRainbow.make(source, is_dark, contrast_level)
    return SchemeFruitSalad.make(source, is_dark, contrast_level)


def assert_contrast(
    scheme: DynamicScheme,
    foreground: Int,
    background: Int,
    curve: ContrastCurve,
) raises:
    var foreground_tone = MaterialDynamicColors.get_hct(foreground, scheme).tone
    var background_tone = MaterialDynamicColors.get_hct(background, scheme).tone
    var actual = Contrast.ratio_of_tones(foreground_tone, background_tone)
    var desired = curve.getContrast(scheme.contrast_level)
    var tolerance = 0.05
    if desired <= 4.5:
        assert_true(actual >= desired - tolerance)
    else:
        assert_true(actual >= 4.5 - tolerance)
        var foreground_at_limit = (
            foreground_tone <= 0.5 or foreground_tone >= 99.5
        )
        if not foreground_at_limit:
            assert_true(actual >= desired - tolerance)


def assert_delta(
    scheme: DynamicScheme,
    role_a: Int,
    role_b: Int,
    delta: Float64,
    polarity: Int,
) raises:
    var tone_a = MaterialDynamicColors.get_hct(role_a, scheme).tone
    var tone_b = MaterialDynamicColors.get_hct(role_b, scheme).tone
    var a_should_be_lighter = (
        polarity == TonePolarity.lighter
        or (polarity == TonePolarity.nearer and not scheme.is_dark)
        or (polarity == TonePolarity.farther and scheme.is_dark)
    )
    var actual_delta = (
        tone_a - tone_b if a_should_be_lighter else tone_b - tone_a
    )
    assert_true(actual_delta >= delta - 0.5)


def assert_background_tone(scheme: DynamicScheme, role: Int) raises:
    var tone = MaterialDynamicColors.get_hct(role, scheme).tone
    assert_true(not (tone >= 50.5 and tone < 59.5))


def run_constraints(scheme: DynamicScheme) raises:
    assert_contrast(
        scheme,
        DynamicColorRole.on_surface,
        DynamicColorRole.surface_bright,
        ContrastCurve(4.5, 7.0, 11.0, 21.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.on_surface_variant,
        DynamicColorRole.surface_dim,
        ContrastCurve(3.0, 4.5, 7.0, 11.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.primary,
        DynamicColorRole.surface_dim,
        ContrastCurve(3.0, 4.5, 7.0, 7.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.secondary,
        DynamicColorRole.surface_bright,
        ContrastCurve(3.0, 4.5, 7.0, 7.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.on_primary,
        DynamicColorRole.primary,
        ContrastCurve(4.5, 7.0, 11.0, 21.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.on_primary_container,
        DynamicColorRole.primary_container,
        ContrastCurve(3.0, 4.5, 7.0, 11.0),
    )
    assert_contrast(
        scheme,
        DynamicColorRole.on_primary_fixed,
        DynamicColorRole.primary_fixed_dim,
        ContrastCurve(4.5, 7.0, 11.0, 21.0),
    )

    assert_delta(
        scheme,
        DynamicColorRole.primary,
        DynamicColorRole.primary_container,
        10.0,
        TonePolarity.farther,
    )
    assert_delta(
        scheme,
        DynamicColorRole.primary_fixed_dim,
        DynamicColorRole.primary_fixed,
        10.0,
        TonePolarity.darker,
    )

    assert_background_tone(scheme, DynamicColorRole.background)
    assert_background_tone(scheme, DynamicColorRole.primary)
    assert_background_tone(scheme, DynamicColorRole.primary_container)
    assert_background_tone(scheme, DynamicColorRole.surface)
    assert_background_tone(scheme, DynamicColorRole.surface_dim)


def test_scheme_correctness() raises:
    var variants = List[Int]()
    variants.append(Variant.monochrome)
    variants.append(Variant.tonal_spot)
    variants.append(Variant.vibrant)
    variants.append(Variant.fidelity)
    variants.append(Variant.content)

    var colors = List[Int]()
    colors.append(0xFF0000FF)
    colors.append(0xFF00FF00)
    colors.append(0xFFFFFF00)
    colors.append(0xFFFF0000)

    var contrast_levels = List[Float64]()
    contrast_levels.append(-1.0)
    contrast_levels.append(0.0)
    contrast_levels.append(0.5)
    contrast_levels.append(1.0)

    for variant in variants:
        for contrast_level in contrast_levels:
            for color in colors:
                run_constraints(
                    scheme_from_variant(
                        variant,
                        Hct.from_int(color),
                        False,
                        contrast_level,
                    )
                )
                run_constraints(
                    scheme_from_variant(
                        variant,
                        Hct.from_int(color),
                        True,
                        contrast_level,
                    )
                )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
