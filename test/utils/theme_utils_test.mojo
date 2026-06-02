from std.collections import List
from std.testing import assert_equal, TestSuite

from lib.blend.blend import Blend
from lib.palettes.core_palette import CorePalette
from lib.scheme.scheme import Scheme
from lib.utils.theme_utils import CustomColor, ThemeUtils


def test_theme_utils() raises:
    var custom_colors = List[CustomColor]()
    custom_colors.append(CustomColor(0xFF00FF00, "brand", True))
    var theme = ThemeUtils.theme_from_source_color(0xFFFF0000, custom_colors^)
    var palette = CorePalette.of(0xFFFF0000)

    assert_equal(0xFFFF0000, theme.source)
    assert_equal(Scheme.light(0xFFFF0000).primary, theme.light_scheme.primary)
    assert_equal(Scheme.dark(0xFFFF0000).surface, theme.dark_scheme.surface)
    assert_equal(palette.primary.get(40), theme.primary_palette.get(40))
    assert_equal(palette.secondary.get(40), theme.secondary_palette.get(40))
    assert_equal(palette.tertiary.get(40), theme.tertiary_palette.get(40))
    assert_equal(palette.neutral.get(40), theme.neutral_palette.get(40))
    assert_equal(
        palette.neutral_variant.get(40), theme.neutral_variant_palette.get(40)
    )
    assert_equal(palette.error.get(40), theme.error_palette.get(40))
    assert_equal(1, len(theme.custom_colors))

    var expected_value = Blend.harmonize(0xFF00FF00, 0xFFFF0000)
    var group = theme.custom_colors[0].copy()
    assert_equal(expected_value, group.value)
    var tones = CorePalette.of(expected_value).primary.copy()
    assert_equal(tones.get(40), group.light.color)
    assert_equal(tones.get(100), group.light.on_color)
    assert_equal(tones.get(90), group.light.color_container)
    assert_equal(tones.get(10), group.light.on_color_container)
    assert_equal(tones.get(80), group.dark.color)
    assert_equal(tones.get(20), group.dark.on_color)
    assert_equal(tones.get(30), group.dark.color_container)
    assert_equal(tones.get(90), group.dark.on_color_container)

    var properties = ThemeUtils.scheme_properties(Scheme.light(0xFFFF0000))
    assert_equal("#C00100", properties["--md-sys-color-primary"])
    assert_equal("#FFFFFF", properties["--md-sys-color-on-primary"])
    assert_equal("#FFFBFF", properties["--md-sys-color-background"])

    var suffixed = ThemeUtils.scheme_properties(
        Scheme.dark(0xFFFF0000), "-dark"
    )
    assert_equal("#FFB4A8", suffixed["--md-sys-color-primary-dark"])

    var bytes = List[Int]()
    bytes.append(255)
    bytes.append(0)
    bytes.append(0)
    bytes.append(255)
    bytes.append(255)
    bytes.append(0)
    bytes.append(0)
    bytes.append(255)
    var no_custom = List[CustomColor]()
    assert_equal(
        0xFFFF0000,
        ThemeUtils.theme_from_image_bytes(bytes, no_custom^).source,
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
