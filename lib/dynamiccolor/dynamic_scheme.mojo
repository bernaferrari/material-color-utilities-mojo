from std.collections import List
from std.utils import StaticTuple

from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.utils.math_utils import MathUtils


struct DynamicScheme(Copyable, Movable):
    var source_color_argb: Int
    var source_color_hct: Hct
    var variant: Int
    var is_dark: Bool
    var contrast_level: Float64
    var primary_palette: TonalPalette
    var secondary_palette: TonalPalette
    var tertiary_palette: TonalPalette
    var neutral_palette: TonalPalette
    var neutral_variant_palette: TonalPalette
    var error_palette: TonalPalette

    def __init__(
        out self,
        var source_color_hct: Hct,
        variant: Int,
        is_dark: Bool,
        contrast_level: Float64,
        var primary_palette: TonalPalette,
        var secondary_palette: TonalPalette,
        var tertiary_palette: TonalPalette,
        var neutral_palette: TonalPalette,
        var neutral_variant_palette: TonalPalette,
        var error_palette: TonalPalette,
    ):
        self.source_color_argb = source_color_hct.to_int()
        self.source_color_hct = source_color_hct^
        self.variant = variant
        self.is_dark = is_dark
        self.contrast_level = contrast_level
        self.primary_palette = primary_palette^
        self.secondary_palette = secondary_palette^
        self.tertiary_palette = tertiary_palette^
        self.neutral_palette = neutral_palette^
        self.neutral_variant_palette = neutral_variant_palette^
        self.error_palette = error_palette^

    @staticmethod
    def get_rotated_hue[
        size: Int
    ](
        source_color: Hct,
        hues: StaticTuple[Float64, size],
        rotations: StaticTuple[Float64, size],
    ) -> Float64:
        if size == 1:
            return MathUtils.sanitizeDegreesDouble(
                source_color.hue + rotations[0]
            )
        for i in range(size - 1):
            if hues[i] < source_color.hue and source_color.hue < hues[i + 1]:
                return MathUtils.sanitizeDegreesDouble(
                    source_color.hue + rotations[i]
                )
        return source_color.hue

    @staticmethod
    def get_rotated_hue_from_lists(
        source_color: Hct, hues: List[Float64], rotations: List[Float64]
    ) raises -> Float64:
        if len(hues) != len(rotations):
            raise Error("hues and rotations must have the same length")
        if len(hues) == 0:
            return source_color.hue
        if len(hues) == 1:
            return MathUtils.sanitizeDegreesDouble(
                source_color.hue + rotations[0]
            )
        for i in range(len(hues) - 1):
            if hues[i] < source_color.hue and source_color.hue < hues[i + 1]:
                return MathUtils.sanitizeDegreesDouble(
                    source_color.hue + rotations[i]
                )
        return source_color.hue
