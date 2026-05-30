from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette


struct SchemeMonochrome:
    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        return DynamicScheme(
            source_color_hct.copy(),
            Variant.monochrome,
            is_dark,
            contrast_level,
            TonalPalette.of(source_color_hct.hue, 0.0),
            TonalPalette.of(source_color_hct.hue, 0.0),
            TonalPalette.of(source_color_hct.hue, 0.0),
            TonalPalette.of(source_color_hct.hue, 0.0),
            TonalPalette.of(source_color_hct.hue, 0.0),
            TonalPalette.of(25.0, 84.0),
        )
