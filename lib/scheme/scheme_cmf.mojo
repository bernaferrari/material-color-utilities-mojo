import std.math as math

from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette


struct SchemeCmf:
    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        return SchemeCmf.make_with_secondary(
            source_color_hct.copy(),
            source_color_hct.copy(),
            is_dark,
            contrast_level,
        )

    @staticmethod
    def make_with_secondary(
        source_color_hct: Hct,
        secondary_source_color_hct: Hct,
        is_dark: Bool,
        contrast_level: Float64,
    ) -> DynamicScheme:
        var tertiary_palette = TonalPalette.of(
            source_color_hct.hue, source_color_hct.chroma * 0.75
        )
        if source_color_hct.to_int() != secondary_source_color_hct.to_int():
            tertiary_palette = TonalPalette.of(
                secondary_source_color_hct.hue,
                secondary_source_color_hct.chroma,
            )

        return DynamicScheme(
            source_color_hct.copy(),
            Variant.cmf,
            is_dark,
            contrast_level,
            TonalPalette.of(source_color_hct.hue, source_color_hct.chroma),
            TonalPalette.of(
                source_color_hct.hue, source_color_hct.chroma * 0.5
            ),
            tertiary_palette^,
            TonalPalette.of(
                source_color_hct.hue, source_color_hct.chroma * 0.2
            ),
            TonalPalette.of(
                source_color_hct.hue, source_color_hct.chroma * 0.2
            ),
            TonalPalette.of(
                SchemeCmf.get_error_hue(
                    source_color_hct.hue, secondary_source_color_hct.hue
                ),
                math.max(source_color_hct.chroma, 50.0),
            ),
        )

    @staticmethod
    def get_error_hue(primary_hue: Float64, tertiary_hue: Float64) -> Float64:
        if primary_hue <= 8.0:
            if tertiary_hue <= 24.0:
                return 28.0
            return 16.0 if tertiary_hue <= 32.0 else 20.0
        if primary_hue <= 16.0:
            if tertiary_hue <= 24.0:
                return 32.0
            return 20.0 if tertiary_hue <= 32.0 else 24.0
        if primary_hue <= 20.0:
            if tertiary_hue <= 28.0:
                return 32.0
            return 24.0 if tertiary_hue <= 32.0 else 28.0
        if primary_hue <= 28.0:
            return 32.0 if tertiary_hue <= 24.0 else 16.0
        if primary_hue <= 32.0:
            if tertiary_hue <= 20.0:
                return 24.0
            return 16.0 if tertiary_hue <= 28.0 else 20.0
        if primary_hue <= 40.0:
            return (
                16.0 if tertiary_hue > 20.0 and tertiary_hue <= 28.0 else 24.0
            )
        if primary_hue <= 152.0:
            return (
                20.0 if tertiary_hue > 24.0 and tertiary_hue <= 36.0 else 32.0
            )
        if primary_hue <= 272.0:
            return (
                16.0 if tertiary_hue > 20.0 and tertiary_hue <= 28.0 else 24.0
            )
        return 32.0 if tertiary_hue > 12.0 and tertiary_hue <= 28.0 else 16.0
