from std.collections import Dict, List

from lib.blend.blend import Blend
from lib.palettes.core_palette import CorePalette
from lib.palettes.tonal_palette import TonalPalette
from lib.scheme.scheme import Scheme
from lib.utils.image_utils import ImageUtils
from lib.utils.string_utils import StringUtils


struct CustomColor(Copyable, Movable):
    var value: Int
    var name: String
    var blend: Bool

    def __init__(out self, value: Int, name: String, blend: Bool):
        self.value = value
        self.name = name
        self.blend = blend


struct ColorGroup(Copyable, Movable):
    var color: Int
    var on_color: Int
    var color_container: Int
    var on_color_container: Int

    def __init__(
        out self,
        color: Int,
        on_color: Int,
        color_container: Int,
        on_color_container: Int,
    ):
        self.color = color
        self.on_color = on_color
        self.color_container = color_container
        self.on_color_container = on_color_container


struct CustomColorGroup(Copyable, Movable):
    var color: CustomColor
    var value: Int
    var light: ColorGroup
    var dark: ColorGroup

    def __init__(
        out self,
        var color: CustomColor,
        value: Int,
        var light: ColorGroup,
        var dark: ColorGroup,
    ):
        self.color = color^
        self.value = value
        self.light = light^
        self.dark = dark^


struct Theme(Movable):
    var source: Int
    var light_scheme: Scheme
    var dark_scheme: Scheme
    var primary_palette: TonalPalette
    var secondary_palette: TonalPalette
    var tertiary_palette: TonalPalette
    var neutral_palette: TonalPalette
    var neutral_variant_palette: TonalPalette
    var error_palette: TonalPalette
    var custom_colors: List[CustomColorGroup]

    def __init__(
        out self,
        source: Int,
        var light_scheme: Scheme,
        var dark_scheme: Scheme,
        var primary_palette: TonalPalette,
        var secondary_palette: TonalPalette,
        var tertiary_palette: TonalPalette,
        var neutral_palette: TonalPalette,
        var neutral_variant_palette: TonalPalette,
        var error_palette: TonalPalette,
        var custom_colors: List[CustomColorGroup],
    ):
        self.source = source
        self.light_scheme = light_scheme^
        self.dark_scheme = dark_scheme^
        self.primary_palette = primary_palette^
        self.secondary_palette = secondary_palette^
        self.tertiary_palette = tertiary_palette^
        self.neutral_palette = neutral_palette^
        self.neutral_variant_palette = neutral_variant_palette^
        self.error_palette = error_palette^
        self.custom_colors = custom_colors^


struct ThemeUtils:
    @staticmethod
    def theme_from_source_color(
        source: Int, var custom_colors: List[CustomColor]
    ) -> Theme:
        var palette = CorePalette.of(source)
        var groups = List[CustomColorGroup]()
        for color in custom_colors:
            groups.append(ThemeUtils.custom_color(source, color))
        return Theme(
            source,
            Scheme.light(source),
            Scheme.dark(source),
            palette.primary.copy(),
            palette.secondary.copy(),
            palette.tertiary.copy(),
            palette.neutral.copy(),
            palette.neutral_variant.copy(),
            palette.error.copy(),
            groups^,
        )

    @staticmethod
    def themeFromSourceColor(
        source: Int, var custom_colors: List[CustomColor]
    ) -> Theme:
        return ThemeUtils.theme_from_source_color(source, custom_colors^)

    @staticmethod
    def theme_from_image_bytes(
        image_bytes: List[Int], var custom_colors: List[CustomColor]
    ) -> Theme:
        return ThemeUtils.theme_from_source_color(
            ImageUtils.source_color_from_image_bytes(image_bytes),
            custom_colors^,
        )

    @staticmethod
    def custom_color(source: Int, color: CustomColor) -> CustomColorGroup:
        var value = color.value
        if color.blend:
            value = Blend.harmonize(value, source)
        var palette = CorePalette.of(value)
        var tones = palette.primary.copy()
        return CustomColorGroup(
            color.copy(),
            value,
            ColorGroup(
                tones.get(40),
                tones.get(100),
                tones.get(90),
                tones.get(10),
            ),
            ColorGroup(
                tones.get(80),
                tones.get(20),
                tones.get(30),
                tones.get(90),
            ),
        )

    @staticmethod
    def customColor(source: Int, color: CustomColor) -> CustomColorGroup:
        return ThemeUtils.custom_color(source, color)

    @staticmethod
    def scheme_properties(
        scheme: Scheme, suffix: String = ""
    ) -> Dict[String, String]:
        var properties = Dict[String, String]()
        ThemeUtils._set_scheme_property(
            properties, "primary", scheme.primary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-primary", scheme.on_primary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "primary-container", scheme.primary_container, suffix
        )
        ThemeUtils._set_scheme_property(
            properties,
            "on-primary-container",
            scheme.on_primary_container,
            suffix,
        )
        ThemeUtils._set_scheme_property(
            properties, "secondary", scheme.secondary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-secondary", scheme.on_secondary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties,
            "secondary-container",
            scheme.secondary_container,
            suffix,
        )
        ThemeUtils._set_scheme_property(
            properties,
            "on-secondary-container",
            scheme.on_secondary_container,
            suffix,
        )
        ThemeUtils._set_scheme_property(
            properties, "tertiary", scheme.tertiary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-tertiary", scheme.on_tertiary, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "tertiary-container", scheme.tertiary_container, suffix
        )
        ThemeUtils._set_scheme_property(
            properties,
            "on-tertiary-container",
            scheme.on_tertiary_container,
            suffix,
        )
        ThemeUtils._set_scheme_property(
            properties, "error", scheme.error, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-error", scheme.on_error, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "error-container", scheme.error_container, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-error-container", scheme.on_error_container, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "background", scheme.background, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-background", scheme.on_background, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "surface", scheme.surface, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-surface", scheme.on_surface, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "surface-variant", scheme.surface_variant, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "on-surface-variant", scheme.on_surface_variant, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "outline", scheme.outline, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "outline-variant", scheme.outline_variant, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "shadow", scheme.shadow, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "scrim", scheme.scrim, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "inverse-surface", scheme.inverse_surface, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "inverse-on-surface", scheme.inverse_on_surface, suffix
        )
        ThemeUtils._set_scheme_property(
            properties, "inverse-primary", scheme.inverse_primary, suffix
        )
        return properties^

    @staticmethod
    def _set_scheme_property(
        mut properties: Dict[String, String],
        token: String,
        color: Int,
        suffix: String,
    ):
        properties[
            String("--md-sys-color-") + token + suffix
        ] = StringUtils.hexFromArgb(color)
