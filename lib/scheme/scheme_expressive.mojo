from std.utils import StaticTuple

from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.utils.math_utils import MathUtils


struct SchemeExpressive:
    comptime _hues = StaticTuple[Float64, 9](
        0, 21, 51, 121, 151, 191, 271, 321, 360
    )
    comptime _secondary_rotations = StaticTuple[Float64, 9](
        45, 95, 45, 20, 45, 90, 45, 45, 45
    )
    comptime _tertiary_rotations = StaticTuple[Float64, 9](
        120, 120, 20, 45, 20, 15, 20, 120, 120
    )

    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        return DynamicScheme(
            source_color_hct.copy(),
            Variant.expressive,
            is_dark,
            contrast_level,
            TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source_color_hct.hue + 240.0),
                40.0,
            ),
            TonalPalette.of(
                DynamicScheme.get_rotated_hue(
                    source_color_hct.copy(),
                    SchemeExpressive._hues,
                    SchemeExpressive._secondary_rotations,
                ),
                24.0,
            ),
            TonalPalette.of(
                DynamicScheme.get_rotated_hue(
                    source_color_hct.copy(),
                    SchemeExpressive._hues,
                    SchemeExpressive._tertiary_rotations,
                ),
                32.0,
            ),
            TonalPalette.of(source_color_hct.hue + 15.0, 8.0),
            TonalPalette.of(source_color_hct.hue + 15.0, 12.0),
            TonalPalette.of(25.0, 84.0),
        )
