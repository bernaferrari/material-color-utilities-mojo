from std.testing import assert_equal, TestSuite

from lib.palettes.core_palette import CorePalette
from lib.scheme.scheme_android import SchemeAndroid


def test_scheme_android() raises:
    var core = CorePalette.of(0xFFFF0000)
    var light = SchemeAndroid.light_from_core_palette(core)
    assert_equal(core.primary.get(90), light.color_accent_primary)
    assert_equal(core.primary.get(40), light.color_accent_primary_variant)
    assert_equal(core.secondary.get(90), light.color_accent_secondary)
    assert_equal(core.secondary.get(40), light.color_accent_secondary_variant)
    assert_equal(core.tertiary.get(90), light.color_accent_tertiary)
    assert_equal(core.tertiary.get(40), light.color_accent_tertiary_variant)
    assert_equal(core.neutral.get(10), light.text_color_primary)
    assert_equal(core.neutral_variant.get(30), light.text_color_secondary)
    assert_equal(core.neutral_variant.get(50), light.text_color_tertiary)
    assert_equal(core.neutral.get(95), light.text_color_primary_inverse)
    assert_equal(core.neutral.get(80), light.text_color_secondary_inverse)
    assert_equal(core.neutral.get(60), light.text_color_tertiary_inverse)
    assert_equal(core.neutral.get(95), light.color_background)
    assert_equal(core.neutral.get(98), light.color_background_floating)
    assert_equal(core.neutral.get(98), light.color_surface)
    assert_equal(core.neutral.get(90), light.color_surface_variant)
    assert_equal(core.neutral.get(100), light.color_surface_highlight)
    assert_equal(core.neutral.get(90), light.surface_header)
    assert_equal(core.neutral.get(0), light.under_surface)
    assert_equal(core.neutral.get(20), light.off_state)
    assert_equal(core.secondary.get(95), light.accent_surface)
    assert_equal(core.neutral.get(10), light.text_primary_on_accent)
    assert_equal(core.neutral_variant.get(30), light.text_secondary_on_accent)
    assert_equal(core.neutral.get(25), light.volume_background)
    assert_equal(core.neutral.get(80), light.scrim)

    var dark = SchemeAndroid.dark_from_core_palette(core)
    assert_equal(core.primary.get(90), dark.color_accent_primary)
    assert_equal(core.primary.get(70), dark.color_accent_primary_variant)
    assert_equal(core.secondary.get(90), dark.color_accent_secondary)
    assert_equal(core.secondary.get(70), dark.color_accent_secondary_variant)
    assert_equal(core.tertiary.get(90), dark.color_accent_tertiary)
    assert_equal(core.tertiary.get(70), dark.color_accent_tertiary_variant)
    assert_equal(core.neutral.get(95), dark.text_color_primary)
    assert_equal(core.neutral_variant.get(80), dark.text_color_secondary)
    assert_equal(core.neutral_variant.get(60), dark.text_color_tertiary)
    assert_equal(core.neutral.get(10), dark.text_color_primary_inverse)
    assert_equal(core.neutral.get(30), dark.text_color_secondary_inverse)
    assert_equal(core.neutral.get(50), dark.text_color_tertiary_inverse)
    assert_equal(core.neutral.get(10), dark.color_background)
    assert_equal(core.neutral.get(10), dark.color_background_floating)
    assert_equal(core.neutral.get(20), dark.color_surface)
    assert_equal(core.neutral.get(30), dark.color_surface_variant)
    assert_equal(core.neutral.get(35), dark.color_surface_highlight)
    assert_equal(core.neutral.get(30), dark.surface_header)
    assert_equal(core.neutral.get(0), dark.under_surface)
    assert_equal(core.neutral.get(20), dark.off_state)
    assert_equal(core.secondary.get(95), dark.accent_surface)
    assert_equal(core.neutral.get(10), dark.text_primary_on_accent)
    assert_equal(core.neutral_variant.get(30), dark.text_secondary_on_accent)
    assert_equal(core.neutral.get(25), dark.volume_background)
    assert_equal(core.neutral.get(80), dark.scrim)

    assert_equal(
        light.color_accent_primary,
        SchemeAndroid.light(0xFFFF0000).color_accent_primary,
    )
    assert_equal(
        dark.color_surface, SchemeAndroid.dark(0xFFFF0000).color_surface
    )
    assert_equal(
        SchemeAndroid.light_content(0xFFFF0000).color_accent_primary,
        SchemeAndroid.light_from_core_palette(
            CorePalette.content_of(0xFFFF0000)
        ).color_accent_primary,
    )
    assert_equal(
        SchemeAndroid.dark_content(0xFFFF0000).color_surface,
        SchemeAndroid.dark_from_core_palette(
            CorePalette.content_of(0xFFFF0000)
        ).color_surface,
    )

    assert_equal(
        SchemeAndroid.lightContent(0xFFFF0000).color_accent_primary,
        SchemeAndroid.light_content(0xFFFF0000).color_accent_primary,
    )
    assert_equal(
        SchemeAndroid.darkContent(0xFFFF0000).color_surface,
        SchemeAndroid.dark_content(0xFFFF0000).color_surface,
    )
    assert_equal(
        SchemeAndroid.lightFromCorePalette(core).color_accent_primary,
        SchemeAndroid.light_from_core_palette(core).color_accent_primary,
    )
    assert_equal(
        SchemeAndroid.darkFromCorePalette(core).color_surface,
        SchemeAndroid.dark_from_core_palette(core).color_surface,
    )

    assert_equal(
        0xFFE0E0FF, SchemeAndroid.light(0xFF0000FF).color_accent_primary
    )
    assert_equal(
        0xFFE0E0FF, SchemeAndroid.dark(0xFF0000FF).color_accent_primary
    )

    var third_party_light = SchemeAndroid.light(0xFF6750A4)
    assert_equal(0xFFE9DDFF, third_party_light.color_accent_primary)
    assert_equal(0xFFE8DEF8, third_party_light.color_accent_secondary)
    assert_equal(0xFFFFD9E3, third_party_light.color_accent_tertiary)
    assert_equal(0xFFFDF8FD, third_party_light.color_surface)
    assert_equal(0xFF1C1B1E, third_party_light.text_color_primary)

    var third_party_dark = SchemeAndroid.dark(0xFF6750A4)
    assert_equal(0xFFE9DDFF, third_party_dark.color_accent_primary)
    assert_equal(0xFFE8DEF8, third_party_dark.color_accent_secondary)
    assert_equal(0xFFFFD9E3, third_party_dark.color_accent_tertiary)
    assert_equal(0xFF313033, third_party_dark.color_surface)
    assert_equal(0xFFF4EFF4, third_party_dark.text_color_primary)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
