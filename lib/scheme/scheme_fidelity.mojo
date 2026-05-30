import std.math as math

from lib.dislike.dislike_analyzer import DislikeAnalyzer
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.temperature.temperature_cache import TemperatureCache


struct SchemeFidelity:
    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        var complement = TemperatureCache(source_color_hct.copy()).complement()
        return DynamicScheme(
            source_color_hct.copy(),
            Variant.fidelity,
            is_dark,
            contrast_level,
            TonalPalette.of(source_color_hct.hue, source_color_hct.chroma),
            TonalPalette.of(
                source_color_hct.hue,
                math.max(
                    source_color_hct.chroma - 32.0,
                    source_color_hct.chroma * 0.5,
                ),
            ),
            TonalPalette.from_hct(DislikeAnalyzer.fix_if_disliked(complement)),
            TonalPalette.of(
                source_color_hct.hue, source_color_hct.chroma / 8.0
            ),
            TonalPalette.of(
                source_color_hct.hue, (source_color_hct.chroma / 8.0) + 4.0
            ),
            TonalPalette.of(25.0, 84.0),
        )
