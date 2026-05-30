from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.utils.math_utils import MathUtils


struct SchemeFruitSalad:
    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        var shifted_hue = MathUtils.sanitizeDegreesDouble(
            source_color_hct.hue - 50.0
        )
        return DynamicScheme(
            source_color_hct.copy(),
            Variant.fruit_salad,
            is_dark,
            contrast_level,
            TonalPalette.of(shifted_hue, 48.0),
            TonalPalette.of(shifted_hue, 36.0),
            TonalPalette.of(source_color_hct.hue, 36.0),
            TonalPalette.of(source_color_hct.hue, 10.0),
            TonalPalette.of(source_color_hct.hue, 16.0),
            TonalPalette.of(25.0, 84.0),
        )
