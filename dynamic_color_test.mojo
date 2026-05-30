from std.testing import assert_equal, assert_true

from lib import DynamicColor as RootDynamicColor
from lib.contrast.contrast import Contrast
from lib.dynamiccolor.dynamic_color import DynamicColor, DynamicColorRole
from lib.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.hct.hct import Hct
from lib.scheme.scheme_content import SchemeContent
from lib.scheme.scheme_fidelity import SchemeFidelity
from lib.scheme.scheme_monochrome import SchemeMonochrome
from lib.scheme.scheme_tonal_spot import SchemeTonalSpot


def assert_near(actual: Float64, expected: Float64, tolerance: Float64) raises:
    assert_true(actual >= expected - tolerance)
    assert_true(actual <= expected + tolerance)


def assert_role_tone(
    scheme: DynamicScheme, role: Int, expected: Float64
) raises:
    assert_near(MaterialDynamicColors.get_hct(role, scheme).tone, expected, 1.0)


def assert_min_contrast(
    scheme: DynamicScheme,
    foreground_role: Int,
    background_role: Int,
    minimum_ratio: Float64,
) raises:
    var foreground_tone = MaterialDynamicColors.get_hct(
        foreground_role, scheme
    ).tone
    var background_tone = MaterialDynamicColors.get_hct(
        background_role, scheme
    ).tone
    assert_true(
        Contrast.ratio_of_tones(foreground_tone, background_tone)
        >= minimum_ratio
    )


def assert_text_surface_pairs(
    scheme: DynamicScheme, minimum_ratio: Float64
) raises:
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_primary,
        DynamicColorRole.primary,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_primary_container,
        DynamicColorRole.primary_container,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_secondary,
        DynamicColorRole.secondary,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_secondary_container,
        DynamicColorRole.secondary_container,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_tertiary,
        DynamicColorRole.tertiary,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_tertiary_container,
        DynamicColorRole.tertiary_container,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme, DynamicColorRole.on_error, DynamicColorRole.error, minimum_ratio
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_error_container,
        DynamicColorRole.error_container,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_background,
        DynamicColorRole.background,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_surface_variant,
        DynamicColorRole.surface_bright,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.on_surface_variant,
        DynamicColorRole.surface_dim,
        minimum_ratio,
    )
    assert_min_contrast(
        scheme,
        DynamicColorRole.inverse_on_surface,
        DynamicColorRole.inverse_surface,
        minimum_ratio,
    )


def assert_contrast_sweep_for(
    seed: Int, contrast_level: Float64, is_dark: Bool
) raises:
    var minimum_ratio = 4.5 if contrast_level >= 0.0 else 3.0
    assert_text_surface_pairs(
        SchemeContent.make(Hct.from_int(seed), is_dark, contrast_level),
        minimum_ratio,
    )
    assert_text_surface_pairs(
        SchemeMonochrome.make(Hct.from_int(seed), is_dark, contrast_level),
        minimum_ratio,
    )
    assert_text_surface_pairs(
        SchemeTonalSpot.make(Hct.from_int(seed), is_dark, contrast_level),
        minimum_ratio,
    )
    assert_text_surface_pairs(
        SchemeFidelity.make(Hct.from_int(seed), is_dark, contrast_level),
        minimum_ratio,
    )


def main() raises:
    var scheme = SchemeTonalSpot.make(Hct.from_int(0xFF0000FF), False, 0.0)
    var primary = DynamicColor(DynamicColorRole.primary)
    var root_primary = RootDynamicColor(DynamicColorRole.primary)
    assert_equal(primary.get_tone(scheme), root_primary.get_tone(scheme))
    assert_equal(
        MaterialDynamicColors.get_argb(DynamicColorRole.primary, scheme),
        primary.get_argb(scheme),
    )
    assert_true(
        Contrast.ratio_of_tones(
            MaterialDynamicColors.get_tone(
                DynamicColorRole.surface_dim, scheme
            ),
            primary.get_tone(scheme),
        )
        >= 4.5
    )
    assert_true(
        MaterialDynamicColors.get_tone(
            DynamicColorRole.primary_container, scheme
        )
        - primary.get_tone(scheme)
        >= 10.0
    )
    assert_equal(
        MaterialDynamicColors.foreground_tone(20.0, 4.5),
        DynamicColor.foreground_tone(20.0, 4.5),
    )
    assert_equal(49.0, DynamicColor.enable_light_foreground(55.0))
    assert_equal(61.0, DynamicColor.enable_light_foreground(61.0))
    assert_true(DynamicColor.tone_prefers_light_foreground(59.0))
    assert_true(not DynamicColor.tone_prefers_light_foreground(60.0))
    assert_true(DynamicColor.tone_allows_light_foreground(49.0))
    assert_true(not DynamicColor.tone_allows_light_foreground(50.0))

    var monochrome = SchemeMonochrome.make(Hct.from_int(0xFF0000FF), False, 0.0)
    assert_equal(
        90.0,
        MaterialDynamicColors.get_tone(
            DynamicColorRole.on_primary,
            monochrome,
        ),
    )

    var high_contrast = SchemeTonalSpot.make(
        Hct.from_int(0xFF0000FF), False, 1.0
    )
    assert_true(
        MaterialDynamicColors.get_tone(
            DynamicColorRole.on_primary_fixed, high_contrast
        )
        > MaterialDynamicColors.get_tone(
            DynamicColorRole.primary_fixed_dim, high_contrast
        )
    )

    assert_equal(
        0xFFFFFFFF,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_primary_container,
            SchemeFidelity.make(Hct.from_int(0xFFFF0000), False, 0.5),
        ),
    )
    assert_equal(
        0xFFFFFFFF,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_secondary_container,
            SchemeContent.make(Hct.from_int(0xFF0000FF), False, 0.5),
        ),
    )
    assert_equal(
        0xFF959B1A,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.on_tertiary_container,
            SchemeContent.make(Hct.from_int(0xFFFFFF00), True, -0.5),
        ),
    )
    assert_equal(
        0xFF2F2F3B,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.inverse_surface,
            SchemeContent.make(Hct.from_int(0xFF0000FF), False, 0.0),
        ),
    )
    assert_equal(
        0xFFFF422F,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.inverse_primary,
            SchemeContent.make(Hct.from_int(0xFFFF0000), False, -0.5),
        ),
    )
    assert_equal(
        0xFF484831,
        MaterialDynamicColors.get_argb(
            DynamicColorRole.outline_variant,
            SchemeContent.make(Hct.from_int(0xFFFFFF00), True, 0.0),
        ),
    )

    assert_contrast_sweep_for(0xFFFF0000, -1.0, False)
    assert_contrast_sweep_for(0xFFFF0000, -0.5, True)
    assert_contrast_sweep_for(0xFFFFFF00, 0.0, False)
    assert_contrast_sweep_for(0xFF00FF00, 0.5, True)
    assert_contrast_sweep_for(0xFF0000FF, 1.0, False)

    var fixed_scheme = SchemeTonalSpot.make(Hct.from_int(0xFFFF0000), True, 0.0)
    assert_equal(
        fixed_scheme.error_palette.key_color.to_int(),
        MaterialDynamicColors.get_argb(
            DynamicColorRole.error_palette_key_color, fixed_scheme
        ),
    )
    assert_role_tone(fixed_scheme, DynamicColorRole.primary_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.secondary_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.tertiary_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.error_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.primary_fixed, 90.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.primary_fixed_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.on_primary_fixed, 10.0)
    assert_role_tone(
        fixed_scheme, DynamicColorRole.on_primary_fixed_variant, 30.0
    )
    assert_role_tone(fixed_scheme, DynamicColorRole.secondary_fixed, 90.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.secondary_fixed_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.on_secondary_fixed, 10.0)
    assert_role_tone(
        fixed_scheme, DynamicColorRole.on_secondary_fixed_variant, 30.0
    )
    assert_role_tone(fixed_scheme, DynamicColorRole.tertiary_fixed, 90.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.tertiary_fixed_dim, 80.0)
    assert_role_tone(fixed_scheme, DynamicColorRole.on_tertiary_fixed, 10.0)
    assert_role_tone(
        fixed_scheme, DynamicColorRole.on_tertiary_fixed_variant, 30.0
    )

    var mono_fixed = SchemeMonochrome.make(Hct.from_int(0xFFFF0000), False, 0.0)
    assert_role_tone(mono_fixed, DynamicColorRole.primary_fixed, 40.0)
    assert_role_tone(mono_fixed, DynamicColorRole.primary_fixed_dim, 30.0)
    assert_role_tone(mono_fixed, DynamicColorRole.on_primary_fixed, 100.0)
    assert_role_tone(
        mono_fixed, DynamicColorRole.on_primary_fixed_variant, 90.0
    )
    assert_role_tone(mono_fixed, DynamicColorRole.secondary_fixed, 80.0)
    assert_role_tone(mono_fixed, DynamicColorRole.secondary_fixed_dim, 70.0)
    assert_role_tone(mono_fixed, DynamicColorRole.on_secondary_fixed, 10.0)
    assert_role_tone(
        mono_fixed, DynamicColorRole.on_secondary_fixed_variant, 25.0
    )
    assert_role_tone(mono_fixed, DynamicColorRole.tertiary_fixed, 40.0)
    assert_role_tone(mono_fixed, DynamicColorRole.tertiary_fixed_dim, 30.0)
    assert_role_tone(mono_fixed, DynamicColorRole.on_tertiary_fixed, 100.0)
    assert_role_tone(
        mono_fixed, DynamicColorRole.on_tertiary_fixed_variant, 90.0
    )

    var dark_mono_fixed = SchemeMonochrome.make(
        Hct.from_int(0xFFFF0000), True, 0.0
    )
    assert_role_tone(dark_mono_fixed, DynamicColorRole.primary_fixed, 40.0)
    assert_role_tone(dark_mono_fixed, DynamicColorRole.primary_fixed_dim, 30.0)
    assert_role_tone(dark_mono_fixed, DynamicColorRole.on_primary_fixed, 100.0)
    assert_role_tone(
        dark_mono_fixed, DynamicColorRole.on_primary_fixed_variant, 90.0
    )
    assert_role_tone(dark_mono_fixed, DynamicColorRole.secondary_fixed, 80.0)
    assert_role_tone(
        dark_mono_fixed, DynamicColorRole.secondary_fixed_dim, 70.0
    )
    assert_role_tone(dark_mono_fixed, DynamicColorRole.on_secondary_fixed, 10.0)
    assert_role_tone(
        dark_mono_fixed, DynamicColorRole.on_secondary_fixed_variant, 25.0
    )
    assert_role_tone(dark_mono_fixed, DynamicColorRole.tertiary_fixed, 40.0)
    assert_role_tone(dark_mono_fixed, DynamicColorRole.tertiary_fixed_dim, 30.0)
    assert_role_tone(dark_mono_fixed, DynamicColorRole.on_tertiary_fixed, 100.0)
    assert_role_tone(
        dark_mono_fixed, DynamicColorRole.on_tertiary_fixed_variant, 90.0
    )
