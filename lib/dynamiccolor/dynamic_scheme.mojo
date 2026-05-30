from std.collections import List
from std.utils import StaticTuple

from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.utils.math_utils import MathUtils


struct SpecVersion:
    comptime v2021 = 2021
    comptime v2025 = 2025
    comptime v2026 = 2026


struct Platform:
    comptime phone = 0
    comptime watch = 1


struct DynamicScheme(Copyable, Movable):
    var source_color_argb: Int
    var source_color_hct: Hct
    var secondary_source_color_hct: Hct
    var variant: Int
    var is_dark: Bool
    var contrast_level: Float64
    var platform: Int
    var spec_version: Int
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
        platform: Int = Platform.phone,
        spec_version: Int = SpecVersion.v2021,
    ):
        self.source_color_argb = source_color_hct.to_int()
        self.source_color_hct = source_color_hct^
        self.secondary_source_color_hct = self.source_color_hct.copy()
        self.variant = variant
        self.is_dark = is_dark
        self.contrast_level = contrast_level
        self.platform = platform
        self.spec_version = DynamicScheme.maybe_fallback_spec_version(
            spec_version, variant
        )
        self.primary_palette = primary_palette^
        self.secondary_palette = secondary_palette^
        self.tertiary_palette = tertiary_palette^
        self.neutral_palette = neutral_palette^
        self.neutral_variant_palette = neutral_variant_palette^
        self.error_palette = error_palette^

    @staticmethod
    def maybe_fallback_spec_version(spec_version: Int, variant: Int) -> Int:
        from lib.dynamiccolor.variant import Variant

        if variant == Variant.cmf:
            return spec_version
        if (
            variant == Variant.expressive
            or variant == Variant.vibrant
            or variant == Variant.tonal_spot
            or variant == Variant.neutral
        ):
            return (
                SpecVersion.v2025 if spec_version
                == SpecVersion.v2026 else spec_version
            )
        return SpecVersion.v2021

    @staticmethod
    def get_piecewise_hue_from_lists(
        source_color: Hct, hue_breakpoints: List[Float64], hues: List[Float64]
    ) -> Float64:
        var size = len(hue_breakpoints) - 1
        if len(hues) < size:
            size = len(hues)
        if size <= 0:
            return source_color.hue
        for i in range(size):
            if (
                source_color.hue >= hue_breakpoints[i]
                and source_color.hue < hue_breakpoints[i + 1]
            ):
                return MathUtils.sanitizeDegreesDouble(hues[i])
        return source_color.hue

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
        var rotation = DynamicScheme.get_piecewise_hue_from_lists(
            source_color, hues, rotations
        )
        if len(hues) - 1 <= 0 or len(rotations) <= 0:
            rotation = 0.0
        return MathUtils.sanitizeDegreesDouble(source_color.hue + rotation)
