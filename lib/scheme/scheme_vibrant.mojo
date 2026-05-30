from std.utils import StaticTuple

from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette


struct SchemeVibrant:
    comptime _hues = StaticTuple[Float64, 9](
        0, 41, 61, 101, 131, 181, 251, 301, 360
    )
    comptime _secondary_rotations = StaticTuple[Float64, 9](
        18, 15, 10, 12, 15, 18, 15, 12, 12
    )
    comptime _tertiary_rotations = StaticTuple[Float64, 9](
        35, 30, 20, 25, 30, 35, 30, 25, 25
    )

    @staticmethod
    def make(
        source_color_hct: Hct, is_dark: Bool, contrast_level: Float64
    ) -> DynamicScheme:
        return DynamicScheme(
            source_color_hct.copy(),
            Variant.vibrant,
            is_dark,
            contrast_level,
            TonalPalette.of(source_color_hct.hue, 200.0),
            TonalPalette.of(
                DynamicScheme.get_rotated_hue(
                    source_color_hct.copy(),
                    SchemeVibrant._hues,
                    SchemeVibrant._secondary_rotations,
                ),
                24.0,
            ),
            TonalPalette.of(
                DynamicScheme.get_rotated_hue(
                    source_color_hct.copy(),
                    SchemeVibrant._hues,
                    SchemeVibrant._tertiary_rotations,
                ),
                32.0,
            ),
            TonalPalette.of(source_color_hct.hue, 10.0),
            TonalPalette.of(source_color_hct.hue, 12.0),
            TonalPalette.of(25.0, 84.0),
        )
