from std.collections import List
from std.utils import StaticTuple

import std.math as math

from lib.dislike.dislike_analyzer import DislikeAnalyzer
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.temperature.temperature_cache import TemperatureCache
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
    def from_source(
        source_color_hct: Hct,
        variant: Int,
        is_dark: Bool,
        contrast_level: Float64,
        platform: Int = Platform.phone,
        spec_version: Int = SpecVersion.v2021,
    ) -> DynamicScheme:
        var actual_spec = DynamicScheme.maybe_fallback_spec_version(
            spec_version, variant
        )
        return DynamicScheme(
            source_color_hct.copy(),
            variant,
            is_dark,
            contrast_level,
            DynamicScheme._primary_palette(
                variant, source_color_hct.copy(), is_dark, platform, actual_spec
            ),
            DynamicScheme._secondary_palette(
                variant, source_color_hct.copy(), is_dark, platform, actual_spec
            ),
            DynamicScheme._tertiary_palette(
                variant, source_color_hct.copy(), is_dark, platform, actual_spec
            ),
            DynamicScheme._neutral_palette(
                variant, source_color_hct.copy(), is_dark, platform, actual_spec
            ),
            DynamicScheme._neutral_variant_palette(
                variant, source_color_hct.copy(), is_dark, platform, actual_spec
            ),
            DynamicScheme._error_palette(
                variant, source_color_hct.copy(), platform, actual_spec
            ),
            platform=platform,
            spec_version=actual_spec,
        )

    @staticmethod
    def _rotated(
        source_color: Hct, breakpoints: List[Float64], rotations: List[Float64]
    ) -> Float64:
        return DynamicScheme.get_rotated_hue_from_lists(
            source_color, breakpoints, rotations
        )

    @staticmethod
    def _list4(a: Float64, b: Float64, c: Float64, d: Float64) -> List[Float64]:
        var values = List[Float64]()
        values.append(a)
        values.append(b)
        values.append(c)
        values.append(d)
        return values^

    @staticmethod
    def _list6(
        a: Float64,
        b: Float64,
        c: Float64,
        d: Float64,
        e: Float64,
        f: Float64,
    ) -> List[Float64]:
        var values = List[Float64]()
        values.append(a)
        values.append(b)
        values.append(c)
        values.append(d)
        values.append(e)
        values.append(f)
        return values^

    @staticmethod
    def _list8(
        a: Float64,
        b: Float64,
        c: Float64,
        d: Float64,
        e: Float64,
        f: Float64,
        g: Float64,
        h: Float64,
    ) -> List[Float64]:
        var values = List[Float64]()
        values.append(a)
        values.append(b)
        values.append(c)
        values.append(d)
        values.append(e)
        values.append(f)
        values.append(g)
        values.append(h)
        return values^

    @staticmethod
    def _list9(
        a: Float64,
        b: Float64,
        c: Float64,
        d: Float64,
        e: Float64,
        f: Float64,
        g: Float64,
        h: Float64,
        i: Float64,
    ) -> List[Float64]:
        var values = DynamicScheme._list8(a, b, c, d, e, f, g, h)
        values.append(i)
        return values^

    @staticmethod
    def _expressive_neutral_hue(source_color: Hct) -> Float64:
        return DynamicScheme._rotated(
            source_color,
            DynamicScheme._list7(0.0, 71.0, 124.0, 253.0, 278.0, 300.0, 360.0),
            DynamicScheme._list6(10.0, 0.0, 10.0, 0.0, 10.0, 0.0),
        )

    @staticmethod
    def _list7(
        a: Float64,
        b: Float64,
        c: Float64,
        d: Float64,
        e: Float64,
        f: Float64,
        g: Float64,
    ) -> List[Float64]:
        var values = DynamicScheme._list6(a, b, c, d, e, f)
        values.append(g)
        return values^

    @staticmethod
    def _expressive_neutral_chroma(
        source_color: Hct, is_dark: Bool, platform: Int
    ) -> Float64:
        var hue = DynamicScheme._expressive_neutral_hue(source_color)
        if platform == Platform.phone:
            if is_dark:
                return 6.0 if Hct.is_yellow(hue) else 14.0
            return 18.0
        return 12.0

    @staticmethod
    def _vibrant_neutral_hue(source_color: Hct) -> Float64:
        return DynamicScheme._rotated(
            source_color,
            DynamicScheme._list6(0.0, 38.0, 105.0, 140.0, 333.0, 360.0),
            DynamicScheme._list5(-14.0, 10.0, -14.0, 10.0, -14.0),
        )

    @staticmethod
    def _list5(
        a: Float64, b: Float64, c: Float64, d: Float64, e: Float64
    ) -> List[Float64]:
        var values = DynamicScheme._list4(a, b, c, d)
        values.append(e)
        return values^

    @staticmethod
    def _vibrant_neutral_chroma(source_color: Hct, platform: Int) -> Float64:
        var hue = DynamicScheme._vibrant_neutral_hue(source_color)
        if platform == Platform.phone:
            return 28.0
        return 28.0 if Hct.is_blue(hue) else 20.0

    @staticmethod
    def _primary_palette(
        variant: Int,
        source: Hct,
        is_dark: Bool,
        platform: Int,
        spec_version: Int,
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025:
            if variant == Variant.neutral:
                if platform == Platform.phone:
                    return TonalPalette.of(
                        source.hue, 12.0 if Hct.is_blue(source.hue) else 8.0
                    )
                return TonalPalette.of(
                    source.hue, 16.0 if Hct.is_blue(source.hue) else 12.0
                )
            if variant == Variant.tonal_spot:
                return TonalPalette.of(
                    source.hue,
                    26.0 if platform == Platform.phone and is_dark else 32.0,
                )
            if variant == Variant.expressive:
                if platform == Platform.phone:
                    return TonalPalette.of(
                        source.hue, 36.0 if is_dark else 48.0
                    )
                return TonalPalette.of(source.hue, 40.0)
            if variant == Variant.vibrant:
                return TonalPalette.of(
                    source.hue, 74.0 if platform == Platform.phone else 56.0
                )

        if variant == Variant.content or variant == Variant.fidelity:
            return TonalPalette.of(source.hue, source.chroma)
        if variant == Variant.fruit_salad:
            return TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source.hue - 50.0), 48.0
            )
        if variant == Variant.monochrome:
            return TonalPalette.of(source.hue, 0.0)
        if variant == Variant.neutral:
            return TonalPalette.of(source.hue, 12.0)
        if variant == Variant.rainbow:
            return TonalPalette.of(source.hue, 48.0)
        if variant == Variant.tonal_spot:
            return TonalPalette.of(source.hue, 36.0)
        if variant == Variant.expressive:
            return TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source.hue + 240.0), 40.0
            )
        return TonalPalette.of(source.hue, 200.0)

    @staticmethod
    def _secondary_palette(
        variant: Int,
        source: Hct,
        is_dark: Bool,
        platform: Int,
        spec_version: Int,
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025:
            if variant == Variant.neutral:
                if platform == Platform.phone:
                    return TonalPalette.of(
                        source.hue, 6.0 if Hct.is_blue(source.hue) else 4.0
                    )
                return TonalPalette.of(
                    source.hue, 10.0 if Hct.is_blue(source.hue) else 6.0
                )
            if variant == Variant.tonal_spot:
                return TonalPalette.of(source.hue, 16.0)
            if variant == Variant.expressive:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list9(
                            0.0,
                            105.0,
                            140.0,
                            204.0,
                            253.0,
                            278.0,
                            300.0,
                            333.0,
                            360.0,
                        ),
                        DynamicScheme._list8(
                            -160.0,
                            155.0,
                            -100.0,
                            96.0,
                            -96.0,
                            -156.0,
                            -165.0,
                            -160.0,
                        ),
                    ),
                    16.0 if platform == Platform.phone and is_dark else 24.0,
                )
            if variant == Variant.vibrant:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list6(
                            0.0, 38.0, 105.0, 140.0, 333.0, 360.0
                        ),
                        DynamicScheme._list5(-14.0, 10.0, -14.0, 10.0, -14.0),
                    ),
                    56.0 if platform == Platform.phone else 36.0,
                )

        if variant == Variant.content or variant == Variant.fidelity:
            return TonalPalette.of(
                source.hue, math.max(source.chroma - 32.0, source.chroma * 0.5)
            )
        if variant == Variant.fruit_salad:
            return TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source.hue - 50.0), 36.0
            )
        if variant == Variant.monochrome:
            return TonalPalette.of(source.hue, 0.0)
        if variant == Variant.neutral:
            return TonalPalette.of(source.hue, 8.0)
        if variant == Variant.rainbow or variant == Variant.tonal_spot:
            return TonalPalette.of(source.hue, 16.0)
        if variant == Variant.expressive:
            return TonalPalette.of(
                DynamicScheme._rotated(
                    source,
                    DynamicScheme._list9(
                        0.0,
                        21.0,
                        51.0,
                        121.0,
                        151.0,
                        191.0,
                        271.0,
                        321.0,
                        360.0,
                    ),
                    DynamicScheme._list9(
                        45.0, 95.0, 45.0, 20.0, 45.0, 90.0, 45.0, 45.0, 45.0
                    ),
                ),
                24.0,
            )
        return TonalPalette.of(
            DynamicScheme._rotated(
                source,
                DynamicScheme._list9(
                    0.0, 41.0, 61.0, 101.0, 131.0, 181.0, 251.0, 301.0, 360.0
                ),
                DynamicScheme._list9(
                    18.0, 15.0, 10.0, 12.0, 15.0, 18.0, 15.0, 12.0, 12.0
                ),
            ),
            24.0,
        )

    @staticmethod
    def _tertiary_palette(
        variant: Int,
        source: Hct,
        is_dark: Bool,
        platform: Int,
        spec_version: Int,
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025:
            if variant == Variant.neutral:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list8(
                            0.0, 38.0, 105.0, 161.0, 204.0, 278.0, 333.0, 360.0
                        ),
                        DynamicScheme._list7(
                            -32.0, 26.0, 10.0, -39.0, 24.0, -15.0, -32.0
                        ),
                    ),
                    20.0 if platform == Platform.phone else 36.0,
                )
            if variant == Variant.tonal_spot:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list6(
                            0.0, 20.0, 71.0, 161.0, 333.0, 360.0
                        ),
                        DynamicScheme._list5(-40.0, 48.0, -32.0, 40.0, -32.0),
                    ),
                    28.0 if platform == Platform.phone else 32.0,
                )
            if variant == Variant.expressive:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list9(
                            0.0,
                            105.0,
                            140.0,
                            204.0,
                            253.0,
                            278.0,
                            300.0,
                            333.0,
                            360.0,
                        ),
                        DynamicScheme._list8(
                            -165.0,
                            160.0,
                            -105.0,
                            101.0,
                            -101.0,
                            -160.0,
                            -170.0,
                            -165.0,
                        ),
                    ),
                    48.0,
                )
            if variant == Variant.vibrant:
                return TonalPalette.of(
                    DynamicScheme._rotated(
                        source,
                        DynamicScheme._list9(
                            0.0,
                            38.0,
                            71.0,
                            105.0,
                            140.0,
                            161.0,
                            253.0,
                            333.0,
                            360.0,
                        ),
                        DynamicScheme._list8(
                            -72.0, 35.0, 24.0, -24.0, 62.0, 50.0, 62.0, -72.0
                        ),
                    ),
                    56.0,
                )

        if variant == Variant.content:
            var analogous = TemperatureCache(source.copy()).analogous(
                count=3, divisions=6
            )
            return TonalPalette.from_hct(
                DislikeAnalyzer.fix_if_disliked(
                    analogous[len(analogous) - 1].copy()
                )
            )
        if variant == Variant.fidelity:
            return TonalPalette.from_hct(
                DislikeAnalyzer.fix_if_disliked(
                    TemperatureCache(source.copy()).complement()
                )
            )
        if variant == Variant.fruit_salad:
            return TonalPalette.of(source.hue, 36.0)
        if variant == Variant.monochrome:
            return TonalPalette.of(source.hue, 0.0)
        if variant == Variant.neutral:
            return TonalPalette.of(source.hue, 16.0)
        if variant == Variant.rainbow or variant == Variant.tonal_spot:
            return TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source.hue + 60.0), 24.0
            )
        if variant == Variant.expressive:
            return TonalPalette.of(
                DynamicScheme._rotated(
                    source,
                    DynamicScheme._list9(
                        0.0,
                        21.0,
                        51.0,
                        121.0,
                        151.0,
                        191.0,
                        271.0,
                        321.0,
                        360.0,
                    ),
                    DynamicScheme._list9(
                        120.0, 120.0, 20.0, 45.0, 20.0, 15.0, 20.0, 120.0, 120.0
                    ),
                ),
                32.0,
            )
        return TonalPalette.of(
            DynamicScheme._rotated(
                source,
                DynamicScheme._list9(
                    0.0, 41.0, 61.0, 101.0, 131.0, 181.0, 251.0, 301.0, 360.0
                ),
                DynamicScheme._list9(
                    35.0, 30.0, 20.0, 25.0, 30.0, 35.0, 30.0, 25.0, 25.0
                ),
            ),
            32.0,
        )

    @staticmethod
    def _neutral_palette(
        variant: Int,
        source: Hct,
        is_dark: Bool,
        platform: Int,
        spec_version: Int,
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025:
            if variant == Variant.neutral:
                return TonalPalette.of(
                    source.hue, 1.4 if platform == Platform.phone else 6.0
                )
            if variant == Variant.tonal_spot:
                return TonalPalette.of(
                    source.hue, 5.0 if platform == Platform.phone else 10.0
                )
            if variant == Variant.expressive:
                return TonalPalette.of(
                    DynamicScheme._expressive_neutral_hue(source.copy()),
                    DynamicScheme._expressive_neutral_chroma(
                        source.copy(), is_dark, platform
                    ),
                )
            if variant == Variant.vibrant:
                return TonalPalette.of(
                    DynamicScheme._vibrant_neutral_hue(source.copy()),
                    DynamicScheme._vibrant_neutral_chroma(
                        source.copy(), platform
                    ),
                )

        if variant == Variant.content or variant == Variant.fidelity:
            return TonalPalette.of(source.hue, source.chroma / 8.0)
        if variant == Variant.fruit_salad or variant == Variant.vibrant:
            return TonalPalette.of(source.hue, 10.0)
        if variant == Variant.monochrome or variant == Variant.rainbow:
            return TonalPalette.of(source.hue, 0.0)
        if variant == Variant.neutral:
            return TonalPalette.of(source.hue, 2.0)
        if variant == Variant.tonal_spot:
            return TonalPalette.of(source.hue, 6.0)
        return TonalPalette.of(
            MathUtils.sanitizeDegreesDouble(source.hue + 15.0), 8.0
        )

    @staticmethod
    def _neutral_variant_palette(
        variant: Int,
        source: Hct,
        is_dark: Bool,
        platform: Int,
        spec_version: Int,
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025:
            if variant == Variant.neutral:
                var chroma = 1.4 if platform == Platform.phone else 6.0
                return TonalPalette.of(source.hue, chroma * 2.2)
            if variant == Variant.tonal_spot:
                var chroma = 5.0 if platform == Platform.phone else 10.0
                return TonalPalette.of(source.hue, chroma * 1.7)
            if variant == Variant.expressive:
                var hue = DynamicScheme._expressive_neutral_hue(source.copy())
                var chroma = DynamicScheme._expressive_neutral_chroma(
                    source.copy(), is_dark, platform
                )
                return TonalPalette.of(
                    hue, chroma * (1.6 if hue >= 105.0 and hue < 125.0 else 2.3)
                )
            if variant == Variant.vibrant:
                var hue = DynamicScheme._vibrant_neutral_hue(source.copy())
                return TonalPalette.of(
                    hue,
                    DynamicScheme._vibrant_neutral_chroma(
                        source.copy(), platform
                    )
                    * 1.29,
                )

        if variant == Variant.content or variant == Variant.fidelity:
            return TonalPalette.of(source.hue, (source.chroma / 8.0) + 4.0)
        if variant == Variant.fruit_salad:
            return TonalPalette.of(source.hue, 16.0)
        if (
            variant == Variant.monochrome
            or variant == Variant.neutral
            or variant == Variant.rainbow
        ):
            return TonalPalette.of(
                source.hue, 0.0 if variant != Variant.neutral else 2.0
            )
        if variant == Variant.tonal_spot:
            return TonalPalette.of(source.hue, 8.0)
        if variant == Variant.expressive:
            return TonalPalette.of(
                MathUtils.sanitizeDegreesDouble(source.hue + 15.0), 12.0
            )
        return TonalPalette.of(source.hue, 12.0)

    @staticmethod
    def _error_palette(
        variant: Int, source: Hct, platform: Int, spec_version: Int
    ) -> TonalPalette:
        from lib.dynamiccolor.variant import Variant

        if spec_version >= SpecVersion.v2025 and (
            variant == Variant.neutral
            or variant == Variant.tonal_spot
            or variant == Variant.expressive
            or variant == Variant.vibrant
        ):
            var error_hue = DynamicScheme.get_piecewise_hue_from_lists(
                source,
                DynamicScheme._list9(
                    0.0, 3.0, 13.0, 23.0, 33.0, 43.0, 153.0, 273.0, 360.0
                ),
                DynamicScheme._list8(
                    12.0, 22.0, 32.0, 12.0, 22.0, 32.0, 22.0, 12.0
                ),
            )
            if variant == Variant.neutral:
                return TonalPalette.of(
                    error_hue, 50.0 if platform == Platform.phone else 40.0
                )
            if variant == Variant.tonal_spot:
                return TonalPalette.of(
                    error_hue, 60.0 if platform == Platform.phone else 48.0
                )
            if variant == Variant.expressive:
                return TonalPalette.of(
                    error_hue, 64.0 if platform == Platform.phone else 48.0
                )
            return TonalPalette.of(
                error_hue, 80.0 if platform == Platform.phone else 60.0
            )
        return TonalPalette.of(25.0, 84.0)

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
    ) -> Float64:
        var rotation = DynamicScheme.get_piecewise_hue_from_lists(
            source_color, hues, rotations
        )
        if len(hues) - 1 <= 0 or len(rotations) <= 0:
            rotation = 0.0
        return MathUtils.sanitizeDegreesDouble(source_color.hue + rotation)
