import std.math as math

from lib.contrast.contrast import Contrast
from lib.dislike.dislike_analyzer import DislikeAnalyzer
from lib.dynamiccolor.contrast_curve import ContrastCurve
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.src.tone_delta_pair import TonePolarity
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct
from lib.palettes.tonal_palette import TonalPalette
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils


struct _Role:
    comptime primary_palette_key_color = 0
    comptime secondary_palette_key_color = 1
    comptime tertiary_palette_key_color = 2
    comptime neutral_palette_key_color = 3
    comptime neutral_variant_palette_key_color = 4
    comptime background = 5
    comptime on_background = 6
    comptime surface = 7
    comptime surface_dim = 8
    comptime surface_bright = 9
    comptime surface_container_lowest = 10
    comptime surface_container_low = 11
    comptime surface_container = 12
    comptime surface_container_high = 13
    comptime surface_container_highest = 14
    comptime on_surface = 15
    comptime surface_variant = 16
    comptime on_surface_variant = 17
    comptime inverse_surface = 18
    comptime inverse_on_surface = 19
    comptime outline = 20
    comptime outline_variant = 21
    comptime shadow = 22
    comptime scrim = 23
    comptime surface_tint = 24
    comptime primary = 25
    comptime on_primary = 26
    comptime primary_container = 27
    comptime on_primary_container = 28
    comptime inverse_primary = 29
    comptime secondary = 30
    comptime on_secondary = 31
    comptime secondary_container = 32
    comptime on_secondary_container = 33
    comptime tertiary = 34
    comptime on_tertiary = 35
    comptime tertiary_container = 36
    comptime on_tertiary_container = 37
    comptime error = 38
    comptime on_error = 39
    comptime error_container = 40
    comptime on_error_container = 41
    comptime primary_fixed = 42
    comptime primary_fixed_dim = 43
    comptime on_primary_fixed = 44
    comptime on_primary_fixed_variant = 45
    comptime secondary_fixed = 46
    comptime secondary_fixed_dim = 47
    comptime on_secondary_fixed = 48
    comptime on_secondary_fixed_variant = 49
    comptime tertiary_fixed = 50
    comptime tertiary_fixed_dim = 51
    comptime on_tertiary_fixed = 52
    comptime on_tertiary_fixed_variant = 53
    comptime error_palette_key_color = 54
    comptime primary_dim = 55
    comptime secondary_dim = 56
    comptime tertiary_dim = 57
    comptime error_dim = 58


struct MaterialDynamicColors:
    @staticmethod
    def _is_fidelity(scheme: DynamicScheme) -> Bool:
        return (
            scheme.variant == Variant.fidelity
            or scheme.variant == Variant.content
        )

    @staticmethod
    def _is_monochrome(scheme: DynamicScheme) -> Bool:
        return scheme.variant == Variant.monochrome

    @staticmethod
    def _is_cmf_2026(scheme: DynamicScheme) -> Bool:
        return scheme.variant == Variant.cmf and scheme.spec_version >= 2026

    @staticmethod
    def _is_2025(scheme: DynamicScheme) -> Bool:
        return scheme.spec_version >= 2025 and (
            scheme.variant == Variant.neutral
            or scheme.variant == Variant.tonal_spot
            or scheme.variant == Variant.expressive
            or scheme.variant == Variant.vibrant
        )

    @staticmethod
    def _highest_surface_role(scheme: DynamicScheme) -> Int:
        return _Role.surface_bright if scheme.is_dark else _Role.surface_dim

    @staticmethod
    def _find_best_tone_for_chroma(
        hue: Float64,
        chroma: Float64,
        tone: Float64,
        by_decreasing_tone: Bool,
    ) -> Float64:
        var answer = tone
        var current_tone = tone
        var best_candidate = Hct.from_hct(hue, chroma, answer)
        while best_candidate.chroma < chroma:
            if current_tone < 0.0 or current_tone > 100.0:
                break
            current_tone += -1.0 if by_decreasing_tone else 1.0
            var new_candidate = Hct.from_hct(hue, chroma, current_tone)
            if best_candidate.chroma < new_candidate.chroma:
                best_candidate = new_candidate^
                answer = current_tone
        return answer

    @staticmethod
    def _t_max_c(
        palette: TonalPalette,
        lower_bound: Float64 = 0.0,
        upper_bound: Float64 = 100.0,
        chroma_multiplier: Float64 = 1.0,
    ) -> Float64:
        return MathUtils.clampDouble(
            lower_bound,
            upper_bound,
            MaterialDynamicColors._find_best_tone_for_chroma(
                palette.hue, palette.chroma * chroma_multiplier, 100.0, True
            ),
        )

    @staticmethod
    def _t_min_c(
        palette: TonalPalette,
        lower_bound: Float64 = 0.0,
        upper_bound: Float64 = 100.0,
    ) -> Float64:
        return MathUtils.clampDouble(
            lower_bound,
            upper_bound,
            MaterialDynamicColors._find_best_tone_for_chroma(
                palette.hue, palette.chroma, 0.0, False
            ),
        )

    @staticmethod
    def _find_desired_chroma_by_tone(
        hue: Float64,
        chroma: Float64,
        tone: Float64,
        by_decreasing_tone: Bool,
    ) -> Float64:
        var answer = tone
        var closest_to_chroma = Hct.from_hct(hue, chroma, tone)
        if closest_to_chroma.chroma < chroma:
            var chroma_peak = closest_to_chroma.chroma
            while closest_to_chroma.chroma < chroma:
                if by_decreasing_tone:
                    answer -= 1.0
                else:
                    answer += 1.0
                if answer < 0.0 or answer > 100.0:
                    break

                var potential_solution = Hct.from_hct(hue, chroma, answer)
                if chroma_peak > potential_solution.chroma:
                    break
                if math.abs(potential_solution.chroma - chroma) < 0.4:
                    break

                var potential_delta = math.abs(
                    potential_solution.chroma - chroma
                )
                var current_delta = math.abs(closest_to_chroma.chroma - chroma)
                var potential_chroma = potential_solution.chroma
                if potential_delta < current_delta:
                    closest_to_chroma = potential_solution^
                chroma_peak = math.max(chroma_peak, potential_chroma)

        return answer

    @staticmethod
    def tone_prefers_light_foreground(tone: Float64) -> Bool:
        return Int(round(tone)) < 60

    @staticmethod
    def tone_allows_light_foreground(tone: Float64) -> Bool:
        return Int(round(tone)) <= 49

    @staticmethod
    def enable_light_foreground(tone: Float64) -> Float64:
        if MaterialDynamicColors.tone_prefers_light_foreground(
            tone
        ) and not MaterialDynamicColors.tone_allows_light_foreground(tone):
            return 49.0
        return tone

    @staticmethod
    def foreground_tone(bg_tone: Float64, ratio: Float64) -> Float64:
        var lighter_tone = Contrast.lighter_unsafe(bg_tone, ratio)
        var darker_tone = Contrast.darker_unsafe(bg_tone, ratio)
        var lighter_ratio = Contrast.ratio_of_tones(lighter_tone, bg_tone)
        var darker_ratio = Contrast.ratio_of_tones(darker_tone, bg_tone)
        var prefer_lighter = (
            MaterialDynamicColors.tone_prefers_light_foreground(bg_tone)
        )

        if prefer_lighter:
            var negligible_difference = (
                math.abs(lighter_ratio - darker_ratio) < 0.1
                and lighter_ratio < ratio
                and darker_ratio < ratio
            )
            if (
                lighter_ratio >= ratio
                or lighter_ratio >= darker_ratio
                or negligible_difference
            ):
                return lighter_tone
            return darker_tone

        if darker_ratio >= ratio or darker_ratio >= lighter_ratio:
            return darker_tone
        return lighter_tone

    @staticmethod
    def _surface_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.background or role == _Role.surface:
                return 4.0 if scheme.is_dark else 98.0
            if role == _Role.surface_dim:
                return 4.0 if scheme.is_dark else 87.0
            if role == _Role.surface_bright:
                return 18.0 if scheme.is_dark else 98.0
            if role == _Role.surface_container_lowest:
                return 0.0 if scheme.is_dark else 100.0
            if role == _Role.surface_container_low:
                return 6.0 if scheme.is_dark else 96.0
            if role == _Role.surface_container:
                return 9.0 if scheme.is_dark else 94.0
            if role == _Role.surface_container_high:
                return 12.0 if scheme.is_dark else 92.0
            if role == _Role.surface_container_highest:
                return 15.0 if scheme.is_dark else 90.0
        if MaterialDynamicColors._is_2025(scheme):
            if role == _Role.background or role == _Role.surface:
                if scheme.platform == 1:
                    return 0.0
                if scheme.is_dark:
                    return 4.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 99.0
                return 97.0 if scheme.variant == Variant.vibrant else 98.0
            if role == _Role.surface_dim:
                if scheme.is_dark:
                    return 4.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 90.0
                return 85.0 if scheme.variant == Variant.vibrant else 87.0
            if role == _Role.surface_bright:
                if scheme.is_dark:
                    return 18.0 if scheme.spec_version >= 2025 else 24.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 99.0
                return 97.0 if scheme.variant == Variant.vibrant else 98.0
            if role == _Role.surface_container_lowest:
                return 0.0 if scheme.is_dark else 100.0
            if role == _Role.surface_container_low:
                if scheme.platform == 1:
                    return 15.0
                if scheme.is_dark:
                    return 6.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 98.0
                return 95.0 if scheme.variant == Variant.vibrant else 96.0
            if role == _Role.surface_container:
                if scheme.platform == 1:
                    return 20.0
                if scheme.is_dark:
                    return 9.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 96.0
                return 92.0 if scheme.variant == Variant.vibrant else 94.0
            if role == _Role.surface_container_high:
                if scheme.platform == 1:
                    return 25.0
                if scheme.is_dark:
                    return 12.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 94.0
                return 90.0 if scheme.variant == Variant.vibrant else 92.0
            if role == _Role.surface_container_highest:
                if scheme.is_dark:
                    return 15.0
                if Hct.is_yellow(scheme.neutral_palette.hue):
                    return 92.0
                return 88.0 if scheme.variant == Variant.vibrant else 90.0
        if role == _Role.background or role == _Role.surface:
            return 6.0 if scheme.is_dark else 98.0
        if role == _Role.surface_dim:
            if scheme.is_dark:
                return 6.0
            return ContrastCurve(87.0, 87.0, 80.0, 75.0).getContrast(
                scheme.contrast_level
            )
        if role == _Role.surface_bright:
            if scheme.is_dark:
                return ContrastCurve(24.0, 24.0, 29.0, 34.0).getContrast(
                    scheme.contrast_level
                )
            return 98.0
        if role == _Role.surface_container_lowest:
            if scheme.is_dark:
                return ContrastCurve(4.0, 4.0, 2.0, 0.0).getContrast(
                    scheme.contrast_level
                )
            return 100.0
        if role == _Role.surface_container_low:
            if scheme.is_dark:
                return ContrastCurve(10.0, 10.0, 11.0, 12.0).getContrast(
                    scheme.contrast_level
                )
            return ContrastCurve(96.0, 96.0, 96.0, 95.0).getContrast(
                scheme.contrast_level
            )
        if role == _Role.surface_container:
            if scheme.is_dark:
                return ContrastCurve(12.0, 12.0, 16.0, 20.0).getContrast(
                    scheme.contrast_level
                )
            return ContrastCurve(94.0, 94.0, 92.0, 90.0).getContrast(
                scheme.contrast_level
            )
        if role == _Role.surface_container_high:
            if scheme.is_dark:
                return ContrastCurve(17.0, 17.0, 21.0, 25.0).getContrast(
                    scheme.contrast_level
                )
            return ContrastCurve(92.0, 92.0, 88.0, 85.0).getContrast(
                scheme.contrast_level
            )
        if role == _Role.surface_container_highest:
            if scheme.is_dark:
                return ContrastCurve(22.0, 22.0, 26.0, 30.0).getContrast(
                    scheme.contrast_level
                )
            return ContrastCurve(90.0, 90.0, 84.0, 80.0).getContrast(
                scheme.contrast_level
            )
        return -1.0

    @staticmethod
    def _primary_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.primary or role == _Role.primary_dim:
                if scheme.source_color_hct.chroma <= 12.0:
                    return 80.0 if scheme.is_dark else 40.0
                return scheme.source_color_hct.tone
            if role == _Role.on_primary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.primary_container:
                if (
                    not scheme.is_dark
                ) and scheme.source_color_hct.chroma <= 12.0:
                    return 90.0
                if scheme.source_color_hct.tone > 55.0:
                    return MathUtils.clampDouble(
                        61.0, 90.0, scheme.source_color_hct.tone
                    )
                return MathUtils.clampDouble(
                    30.0, 49.0, scheme.source_color_hct.tone
                )
            if role == _Role.on_primary_container:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.inverse_primary:
                return 40.0 if scheme.is_dark else 80.0
        if MaterialDynamicColors._is_2025(scheme):
            if role == _Role.primary or role == _Role.primary_dim:
                if role == _Role.primary_dim:
                    if scheme.variant == Variant.neutral:
                        return 85.0
                    if scheme.variant == Variant.tonal_spot:
                        return MaterialDynamicColors._t_max_c(
                            scheme.primary_palette, 0.0, 90.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.primary_palette
                    )
                if scheme.variant == Variant.neutral:
                    if scheme.platform == 0:
                        return 80.0 if scheme.is_dark else 40.0
                    return 90.0
                if scheme.variant == Variant.tonal_spot:
                    if scheme.platform == 0:
                        if scheme.is_dark:
                            return 80.0
                        return MaterialDynamicColors._t_max_c(
                            scheme.primary_palette
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.primary_palette, 0.0, 90.0
                    )
                if scheme.variant == Variant.expressive:
                    if scheme.platform == 0:
                        var upper = 98.0
                        if Hct.is_yellow(scheme.primary_palette.hue):
                            upper = 25.0
                        elif Hct.is_cyan(scheme.primary_palette.hue):
                            upper = 88.0
                        return MaterialDynamicColors._t_max_c(
                            scheme.primary_palette, 0.0, upper
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.primary_palette
                    )
                var upper = 98.0
                if Hct.is_cyan(scheme.primary_palette.hue):
                    upper = 88.0
                return MaterialDynamicColors._t_max_c(
                    scheme.primary_palette, 0.0, upper
                )
            if role == _Role.on_primary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.primary_container:
                if scheme.platform == 1:
                    return 30.0
                if scheme.variant == Variant.neutral:
                    return 30.0 if scheme.is_dark else 90.0
                if scheme.variant == Variant.tonal_spot:
                    if scheme.is_dark:
                        return MaterialDynamicColors._t_min_c(
                            scheme.primary_palette, 35.0, 93.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.primary_palette, 0.0, 90.0
                    )
                if scheme.variant == Variant.expressive:
                    if scheme.is_dark:
                        return MaterialDynamicColors._t_max_c(
                            scheme.primary_palette, 30.0, 93.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.primary_palette,
                        78.0,
                        88.0 if Hct.is_cyan(
                            scheme.primary_palette.hue
                        ) else 90.0,
                    )
                if scheme.is_dark:
                    return MaterialDynamicColors._t_min_c(
                        scheme.primary_palette, 66.0, 93.0
                    )
                return MaterialDynamicColors._t_max_c(
                    scheme.primary_palette,
                    66.0,
                    88.0 if Hct.is_cyan(scheme.primary_palette.hue) else 93.0,
                )
            if role == _Role.on_primary_container:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.inverse_primary:
                return MaterialDynamicColors._t_max_c(scheme.primary_palette)
        if scheme.variant == Variant.monochrome:
            if role == _Role.primary:
                return 100.0 if scheme.is_dark else 0.0
            if role == _Role.on_primary:
                return 10.0 if scheme.is_dark else 90.0
            if role == _Role.primary_container:
                return 85.0 if scheme.is_dark else 25.0
            if role == _Role.on_primary_container:
                return 0.0 if scheme.is_dark else 100.0
        if role == _Role.primary:
            return 80.0 if scheme.is_dark else 40.0
        if role == _Role.on_primary:
            return 20.0 if scheme.is_dark else 100.0
        if role == _Role.primary_container:
            if MaterialDynamicColors._is_fidelity(scheme):
                return scheme.source_color_hct.tone
            return 30.0 if scheme.is_dark else 90.0
        if role == _Role.on_primary_container:
            if MaterialDynamicColors._is_fidelity(scheme):
                return MaterialDynamicColors.foreground_tone(
                    MaterialDynamicColors._primary_tone(
                        _Role.primary_container, scheme
                    ),
                    4.5,
                )
            return 90.0 if scheme.is_dark else 10.0
        if role == _Role.inverse_primary:
            return 40.0 if scheme.is_dark else 80.0
        return 80.0 if scheme.is_dark else 40.0

    @staticmethod
    def _secondary_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.secondary or role == _Role.secondary_dim:
                if scheme.is_dark:
                    return MaterialDynamicColors._t_min_c(
                        scheme.secondary_palette
                    )
                return MaterialDynamicColors._t_max_c(scheme.secondary_palette)
            if role == _Role.on_secondary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.secondary_container:
                if scheme.is_dark:
                    return MaterialDynamicColors._t_min_c(
                        scheme.secondary_palette, 20.0, 49.0
                    )
                return MaterialDynamicColors._t_max_c(
                    scheme.secondary_palette, 61.0, 90.0
                )
            if role == _Role.on_secondary_container:
                return 20.0 if scheme.is_dark else 100.0
        if MaterialDynamicColors._is_2025(scheme):
            if role == _Role.secondary or role == _Role.secondary_dim:
                if role == _Role.secondary_dim:
                    if scheme.variant == Variant.neutral:
                        return 85.0
                    return MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette, 0.0, 90.0
                    )
                if scheme.platform == 1:
                    if scheme.variant == Variant.neutral:
                        return 90.0
                    return MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette, 0.0, 90.0
                    )
                if scheme.variant == Variant.neutral:
                    if scheme.is_dark:
                        return MaterialDynamicColors._t_min_c(
                            scheme.secondary_palette, 0.0, 98.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette
                    )
                if scheme.variant == Variant.vibrant:
                    return MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette,
                        0.0,
                        90.0 if scheme.is_dark else 98.0,
                    )
                return (
                    80.0 if scheme.is_dark else MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette
                    )
                )
            if role == _Role.on_secondary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.secondary_container:
                if scheme.platform == 1:
                    return 30.0
                if scheme.variant == Variant.vibrant:
                    if scheme.is_dark:
                        return MaterialDynamicColors._t_min_c(
                            scheme.secondary_palette, 30.0, 40.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette, 84.0, 90.0
                    )
                if scheme.variant == Variant.expressive:
                    return 15.0 if scheme.is_dark else MaterialDynamicColors._t_max_c(
                        scheme.secondary_palette, 90.0, 95.0
                    )
                return 25.0 if scheme.is_dark else 90.0
            if role == _Role.on_secondary_container:
                return 20.0 if scheme.is_dark else 100.0
        if scheme.variant == Variant.monochrome:
            if role == _Role.secondary:
                return 80.0 if scheme.is_dark else 40.0
            if role == _Role.on_secondary:
                return 10.0 if scheme.is_dark else 100.0
            if role == _Role.secondary_container:
                return 30.0 if scheme.is_dark else 85.0
            if role == _Role.on_secondary_container:
                return 90.0 if scheme.is_dark else 10.0
        if role == _Role.secondary:
            return 80.0 if scheme.is_dark else 40.0
        if role == _Role.on_secondary:
            return 20.0 if scheme.is_dark else 100.0
        if role == _Role.secondary_container:
            var initial_tone = 30.0 if scheme.is_dark else 90.0
            if not MaterialDynamicColors._is_fidelity(scheme):
                return initial_tone
            return MaterialDynamicColors._find_desired_chroma_by_tone(
                scheme.secondary_palette.hue,
                scheme.secondary_palette.chroma,
                initial_tone,
                False if scheme.is_dark else True,
            )
        if role == _Role.on_secondary_container:
            if MaterialDynamicColors._is_fidelity(scheme):
                return MaterialDynamicColors.foreground_tone(
                    MaterialDynamicColors._secondary_tone(
                        _Role.secondary_container, scheme
                    ),
                    4.5,
                )
            return 90.0 if scheme.is_dark else 10.0
        return 80.0 if scheme.is_dark else 40.0

    @staticmethod
    def _tertiary_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.tertiary or role == _Role.tertiary_dim:
                return scheme.secondary_source_color_hct.tone
            if role == _Role.on_tertiary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.tertiary_container:
                if scheme.secondary_source_color_hct.tone > 55.0:
                    return MathUtils.clampDouble(
                        61.0, 90.0, scheme.secondary_source_color_hct.tone
                    )
                return MathUtils.clampDouble(
                    20.0, 49.0, scheme.secondary_source_color_hct.tone
                )
            if role == _Role.on_tertiary_container:
                return 20.0 if scheme.is_dark else 100.0
        if MaterialDynamicColors._is_2025(scheme):
            if role == _Role.tertiary or role == _Role.tertiary_dim:
                if role == _Role.tertiary_dim:
                    if scheme.variant == Variant.tonal_spot:
                        return MaterialDynamicColors._t_max_c(
                            scheme.tertiary_palette, 0.0, 90.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette
                    )
                if scheme.platform == 1:
                    if scheme.variant == Variant.tonal_spot:
                        return MaterialDynamicColors._t_max_c(
                            scheme.tertiary_palette, 0.0, 90.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette
                    )
                if (
                    scheme.variant == Variant.expressive
                    or scheme.variant == Variant.vibrant
                ):
                    var upper = 98.0 if scheme.is_dark else 100.0
                    if Hct.is_cyan(scheme.tertiary_palette.hue):
                        upper = 88.0
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette, 0.0, upper
                    )
                if scheme.is_dark:
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette, 0.0, 98.0
                    )
                return MaterialDynamicColors._t_max_c(scheme.tertiary_palette)
            if role == _Role.on_tertiary:
                return 20.0 if scheme.is_dark else 100.0
            if role == _Role.tertiary_container:
                if scheme.platform == 1:
                    if scheme.variant == Variant.tonal_spot:
                        return MaterialDynamicColors._t_max_c(
                            scheme.tertiary_palette, 0.0, 90.0
                        )
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette
                    )
                if scheme.variant == Variant.neutral:
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette,
                        0.0,
                        93.0 if scheme.is_dark else 96.0,
                    )
                if scheme.variant == Variant.tonal_spot:
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette,
                        0.0,
                        93.0 if scheme.is_dark else 100.0,
                    )
                if scheme.variant == Variant.expressive:
                    var upper = 93.0 if scheme.is_dark else 100.0
                    if Hct.is_cyan(scheme.tertiary_palette.hue):
                        upper = 88.0
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette, 75.0, upper
                    )
                if scheme.is_dark:
                    return MaterialDynamicColors._t_max_c(
                        scheme.tertiary_palette, 0.0, 93.0
                    )
                return MaterialDynamicColors._t_max_c(
                    scheme.tertiary_palette, 72.0, 100.0
                )
            if role == _Role.on_tertiary_container:
                return 20.0 if scheme.is_dark else 100.0
        if scheme.variant == Variant.monochrome:
            if role == _Role.tertiary:
                return 90.0 if scheme.is_dark else 25.0
            if role == _Role.on_tertiary:
                return 10.0 if scheme.is_dark else 90.0
            if role == _Role.tertiary_container:
                return 60.0 if scheme.is_dark else 49.0
            if role == _Role.on_tertiary_container:
                return 0.0 if scheme.is_dark else 100.0
        if role == _Role.tertiary:
            return 80.0 if scheme.is_dark else 40.0
        if role == _Role.on_tertiary:
            return 20.0 if scheme.is_dark else 100.0
        if role == _Role.tertiary_container:
            if MaterialDynamicColors._is_fidelity(scheme):
                var proposed_hct = scheme.tertiary_palette.get_hct(
                    scheme.source_color_hct.tone
                )
                return DislikeAnalyzer.fix_if_disliked(proposed_hct).tone
            return 30.0 if scheme.is_dark else 90.0
        if role == _Role.on_tertiary_container:
            if MaterialDynamicColors._is_fidelity(scheme):
                return MaterialDynamicColors.foreground_tone(
                    MaterialDynamicColors._tertiary_tone(
                        _Role.tertiary_container, scheme
                    ),
                    4.5,
                )
            return 90.0 if scheme.is_dark else 10.0
        return 80.0 if scheme.is_dark else 40.0

    @staticmethod
    def _fixed_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_2025(scheme):
            if role == _Role.primary_fixed:
                var temp = scheme.copy()
                temp.is_dark = False
                temp.contrast_level = 0.0
                return MaterialDynamicColors._primary_tone(
                    _Role.primary_container, temp
                )
            if role == _Role.primary_fixed_dim:
                return MaterialDynamicColors._fixed_tone(
                    _Role.primary_fixed, scheme
                )
            if role == _Role.on_primary_fixed:
                return 10.0
            if role == _Role.on_primary_fixed_variant:
                return 30.0
            if role == _Role.secondary_fixed:
                var temp = scheme.copy()
                temp.is_dark = False
                temp.contrast_level = 0.0
                return MaterialDynamicColors._secondary_tone(
                    _Role.secondary_container, temp
                )
            if role == _Role.secondary_fixed_dim:
                return MaterialDynamicColors._fixed_tone(
                    _Role.secondary_fixed, scheme
                )
            if role == _Role.on_secondary_fixed:
                return 10.0
            if role == _Role.on_secondary_fixed_variant:
                return 30.0
            if role == _Role.tertiary_fixed:
                var temp = scheme.copy()
                temp.is_dark = False
                temp.contrast_level = 0.0
                return MaterialDynamicColors._tertiary_tone(
                    _Role.tertiary_container, temp
                )
            if role == _Role.tertiary_fixed_dim:
                return MaterialDynamicColors._fixed_tone(
                    _Role.tertiary_fixed, scheme
                )
            if role == _Role.on_tertiary_fixed:
                return 10.0
            if role == _Role.on_tertiary_fixed_variant:
                return 30.0
        var mono = MaterialDynamicColors._is_monochrome(scheme)
        if role == _Role.primary_fixed:
            return 40.0 if mono else 90.0
        if role == _Role.primary_fixed_dim:
            return 30.0 if mono else 80.0
        if role == _Role.on_primary_fixed:
            return 100.0 if mono else 10.0
        if role == _Role.on_primary_fixed_variant:
            return 90.0 if mono else 30.0
        if role == _Role.secondary_fixed:
            return 80.0 if mono else 90.0
        if role == _Role.secondary_fixed_dim:
            return 70.0 if mono else 80.0
        if role == _Role.on_secondary_fixed:
            return 10.0
        if role == _Role.on_secondary_fixed_variant:
            return 25.0 if mono else 30.0
        if role == _Role.tertiary_fixed:
            return 40.0 if mono else 90.0
        if role == _Role.tertiary_fixed_dim:
            return 30.0 if mono else 80.0
        if role == _Role.on_tertiary_fixed:
            return 100.0 if mono else 10.0
        if role == _Role.on_tertiary_fixed_variant:
            return 90.0 if mono else 30.0
        return -1.0

    @staticmethod
    def palette_for(role: Int, scheme: DynamicScheme) -> TonalPalette:
        if (
            role == _Role.primary
            or role == _Role.on_primary
            or role == _Role.primary_container
            or role == _Role.on_primary_container
            or role == _Role.inverse_primary
            or role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.on_primary_fixed
            or role == _Role.on_primary_fixed_variant
            or role == _Role.surface_tint
            or role == _Role.primary_palette_key_color
            or role == _Role.primary_dim
        ):
            return scheme.primary_palette.copy()
        if (
            role == _Role.secondary
            or role == _Role.on_secondary
            or role == _Role.secondary_container
            or role == _Role.on_secondary_container
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.on_secondary_fixed
            or role == _Role.on_secondary_fixed_variant
            or role == _Role.secondary_palette_key_color
            or role == _Role.secondary_dim
        ):
            return scheme.secondary_palette.copy()
        if (
            role == _Role.tertiary
            or role == _Role.on_tertiary
            or role == _Role.tertiary_container
            or role == _Role.on_tertiary_container
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
            or role == _Role.on_tertiary_fixed
            or role == _Role.on_tertiary_fixed_variant
            or role == _Role.tertiary_palette_key_color
            or role == _Role.tertiary_dim
        ):
            return scheme.tertiary_palette.copy()
        if (
            role == _Role.surface_variant
            or role == _Role.on_surface_variant
            or role == _Role.outline
            or role == _Role.outline_variant
            or role == _Role.neutral_variant_palette_key_color
        ):
            if (
                MaterialDynamicColors._is_2025(scheme)
                or MaterialDynamicColors._is_cmf_2026(scheme)
            ) and role != _Role.neutral_variant_palette_key_color:
                return scheme.neutral_palette.copy()
            return scheme.neutral_variant_palette.copy()
        if (
            role == _Role.error
            or role == _Role.on_error
            or role == _Role.error_container
            or role == _Role.on_error_container
            or role == _Role.error_palette_key_color
            or role == _Role.error_dim
        ):
            return scheme.error_palette.copy()
        return scheme.neutral_palette.copy()

    @staticmethod
    def _surface_chroma_multiplier(role: Int, scheme: DynamicScheme) -> Float64:
        if not MaterialDynamicColors._is_2025(scheme):
            return 1.0
        if role == _Role.surface_dim:
            if scheme.is_dark:
                return 1.0
            if scheme.variant == Variant.neutral:
                return 2.5
            if scheme.variant == Variant.tonal_spot:
                return 1.7
            if scheme.variant == Variant.expressive:
                return 2.7 if Hct.is_yellow(
                    scheme.neutral_palette.hue
                ) else 1.75
            if scheme.variant == Variant.vibrant:
                return 1.36
        if role == _Role.surface_bright:
            if not scheme.is_dark:
                return 1.0
            if scheme.variant == Variant.neutral:
                return 2.5
            if scheme.variant == Variant.tonal_spot:
                return 1.7
            if scheme.variant == Variant.expressive:
                return 2.7 if Hct.is_yellow(
                    scheme.neutral_palette.hue
                ) else 1.75
            if scheme.variant == Variant.vibrant:
                return 1.36
        if role == _Role.surface_container_low:
            if scheme.platform != 0:
                return 1.0
            if scheme.variant == Variant.neutral:
                return 1.3
            if scheme.variant == Variant.tonal_spot:
                return 1.25
            if scheme.variant == Variant.expressive:
                return 1.3 if Hct.is_yellow(
                    scheme.neutral_palette.hue
                ) else 1.15
            if scheme.variant == Variant.vibrant:
                return 1.08
        if role == _Role.surface_container:
            if scheme.platform != 0:
                return 1.0
            if scheme.variant == Variant.neutral:
                return 1.6
            if scheme.variant == Variant.tonal_spot:
                return 1.4
            if scheme.variant == Variant.expressive:
                return 1.6 if Hct.is_yellow(scheme.neutral_palette.hue) else 1.3
            if scheme.variant == Variant.vibrant:
                return 1.15
        if role == _Role.surface_container_high:
            if scheme.platform != 0:
                return 1.0
            if scheme.variant == Variant.neutral:
                return 1.9
            if scheme.variant == Variant.tonal_spot:
                return 1.5
            if scheme.variant == Variant.expressive:
                return 1.95 if Hct.is_yellow(
                    scheme.neutral_palette.hue
                ) else 1.45
            if scheme.variant == Variant.vibrant:
                return 1.22
        if (
            role == _Role.surface_container_highest
            or role == _Role.surface_variant
        ):
            if scheme.variant == Variant.neutral:
                return 2.2
            if scheme.variant == Variant.tonal_spot:
                return 1.7
            if scheme.variant == Variant.expressive:
                return 2.3 if Hct.is_yellow(scheme.neutral_palette.hue) else 1.6
            if scheme.variant == Variant.vibrant:
                return 1.29
        if (
            role == _Role.on_surface
            or role == _Role.on_surface_variant
            or role == _Role.outline
            or role == _Role.outline_variant
        ):
            if scheme.platform == 0:
                if scheme.variant == Variant.neutral:
                    return 2.2
                if scheme.variant == Variant.tonal_spot:
                    return 1.7
                if scheme.variant == Variant.expressive:
                    if Hct.is_yellow(scheme.neutral_palette.hue):
                        return 3.0 if scheme.is_dark else 2.3
                    return 1.6
        return 1.0

    @staticmethod
    def _chroma_multiplier(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.surface_dim:
                return 1.0 if scheme.is_dark else 1.7
            if role == _Role.surface_bright:
                return 1.7 if scheme.is_dark else 1.0
            if role == _Role.surface_container_low:
                return 1.25
            if role == _Role.surface_container:
                return 1.4
            if role == _Role.surface_container_high:
                return 1.5
            if (
                role == _Role.surface_container_highest
                or role == _Role.on_surface
                or role == _Role.on_surface_variant
                or role == _Role.outline
                or role == _Role.outline_variant
                or role == _Role.inverse_surface
            ):
                return 1.7
        return MaterialDynamicColors._surface_chroma_multiplier(role, scheme)

    @staticmethod
    def _base_tone(role: Int, scheme: DynamicScheme) -> Float64:
        if (
            role == _Role.primary_palette_key_color
            or role == _Role.secondary_palette_key_color
            or role == _Role.tertiary_palette_key_color
            or role == _Role.neutral_palette_key_color
            or role == _Role.neutral_variant_palette_key_color
            or role == _Role.error_palette_key_color
        ):
            return MaterialDynamicColors.palette_for(
                role, scheme
            ).key_color.tone
        var surface_tone = MaterialDynamicColors._surface_tone(role, scheme)
        if surface_tone >= 0.0:
            return surface_tone
        if MaterialDynamicColors._is_2025(
            scheme
        ) or MaterialDynamicColors._is_cmf_2026(scheme):
            if (
                role == _Role.on_surface
                or role == _Role.on_surface_variant
                or role == _Role.outline
                or role == _Role.outline_variant
                or role == _Role.inverse_on_surface
                or role == _Role.on_primary
                or role == _Role.on_primary_container
                or role == _Role.on_secondary
                or role == _Role.on_secondary_container
                or role == _Role.on_tertiary
                or role == _Role.on_tertiary_container
                or role == _Role.on_error
                or role == _Role.on_error_container
                or role == _Role.on_primary_fixed
                or role == _Role.on_primary_fixed_variant
                or role == _Role.on_secondary_fixed
                or role == _Role.on_secondary_fixed_variant
                or role == _Role.on_tertiary_fixed
                or role == _Role.on_tertiary_fixed_variant
            ):
                var bg_role = MaterialDynamicColors._modern_background_role(
                    role, scheme
                )
                if bg_role >= 0:
                    return MaterialDynamicColors.get_tone(bg_role, scheme)
        if role == _Role.on_background or role == _Role.on_surface:
            return 90.0 if scheme.is_dark else 10.0
        if role == _Role.surface_variant:
            return 30.0 if scheme.is_dark else 90.0
        if role == _Role.on_surface_variant:
            return 80.0 if scheme.is_dark else 30.0
        if role == _Role.inverse_surface:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                return 98.0 if scheme.is_dark else 4.0
            if MaterialDynamicColors._is_2025(scheme):
                return 98.0 if scheme.is_dark else 4.0
            return 90.0 if scheme.is_dark else 20.0
        if role == _Role.inverse_on_surface:
            return 20.0 if scheme.is_dark else 95.0
        if role == _Role.outline:
            return 60.0 if scheme.is_dark else 50.0
        if role == _Role.outline_variant:
            return 30.0 if scheme.is_dark else 80.0
        if role == _Role.shadow or role == _Role.scrim:
            return 0.0
        if (
            role == _Role.primary
            or role == _Role.on_primary
            or role == _Role.primary_container
            or role == _Role.on_primary_container
            or role == _Role.inverse_primary
            or role == _Role.primary_dim
        ):
            return MaterialDynamicColors._primary_tone(role, scheme)
        if (
            role == _Role.secondary
            or role == _Role.on_secondary
            or role == _Role.secondary_container
            or role == _Role.on_secondary_container
            or role == _Role.secondary_dim
        ):
            return MaterialDynamicColors._secondary_tone(role, scheme)
        if (
            role == _Role.tertiary
            or role == _Role.on_tertiary
            or role == _Role.tertiary_container
            or role == _Role.on_tertiary_container
            or role == _Role.tertiary_dim
        ):
            return MaterialDynamicColors._tertiary_tone(role, scheme)
        if role == _Role.error:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                return MaterialDynamicColors._t_max_c(scheme.error_palette)
            if MaterialDynamicColors._is_2025(scheme):
                if scheme.platform == 0:
                    if scheme.is_dark:
                        return MaterialDynamicColors._t_min_c(
                            scheme.error_palette, 0.0, 98.0
                        )
                    return MaterialDynamicColors._t_max_c(scheme.error_palette)
                return MaterialDynamicColors._t_min_c(scheme.error_palette)
            return 80.0 if scheme.is_dark else 40.0
        if role == _Role.on_error:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                return 20.0 if scheme.is_dark else 100.0
            if MaterialDynamicColors._is_2025(scheme):
                return 20.0 if scheme.is_dark else 100.0
            return 20.0 if scheme.is_dark else 100.0
        if role == _Role.error_container:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                if scheme.is_dark:
                    return MaterialDynamicColors._t_min_c(scheme.error_palette)
                return MaterialDynamicColors._t_max_c(scheme.error_palette)
            if MaterialDynamicColors._is_2025(scheme):
                if scheme.platform == 1:
                    return 30.0
                if scheme.is_dark:
                    return MaterialDynamicColors._t_min_c(
                        scheme.error_palette, 30.0, 93.0
                    )
                return MaterialDynamicColors._t_max_c(
                    scheme.error_palette, 0.0, 90.0
                )
            return 30.0 if scheme.is_dark else 90.0
        if role == _Role.on_error_container:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                return 20.0 if scheme.is_dark else 100.0
            if MaterialDynamicColors._is_2025(scheme):
                return 20.0 if scheme.is_dark else 100.0
            return 90.0 if scheme.is_dark else 10.0
        if role == _Role.error_dim:
            if MaterialDynamicColors._is_cmf_2026(scheme):
                return MaterialDynamicColors._t_max_c(scheme.error_palette)
            if MaterialDynamicColors._is_2025(scheme):
                return MaterialDynamicColors._t_min_c(scheme.error_palette)
            return 80.0 if scheme.is_dark else 40.0
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if role == _Role.primary_fixed or role == _Role.primary_fixed_dim:
                if scheme.source_color_hct.chroma <= 12.0:
                    return 90.0
                if scheme.source_color_hct.tone > 55.0:
                    return MathUtils.clampDouble(
                        61.0, 90.0, scheme.source_color_hct.tone
                    )
                return MathUtils.clampDouble(
                    30.0, 49.0, scheme.source_color_hct.tone
                )
            if role == _Role.on_primary_fixed:
                return 10.0
            if role == _Role.on_primary_fixed_variant:
                return 30.0
            if (
                role == _Role.secondary_fixed
                or role == _Role.secondary_fixed_dim
            ):
                return MaterialDynamicColors._t_max_c(
                    scheme.secondary_palette, 61.0, 90.0
                )
            if role == _Role.on_secondary_fixed:
                return 10.0
            if role == _Role.on_secondary_fixed_variant:
                return 30.0
            if role == _Role.tertiary_fixed or role == _Role.tertiary_fixed_dim:
                if scheme.secondary_source_color_hct.tone > 55.0:
                    return MathUtils.clampDouble(
                        61.0, 90.0, scheme.secondary_source_color_hct.tone
                    )
                return MathUtils.clampDouble(
                    20.0, 49.0, scheme.secondary_source_color_hct.tone
                )
            if role == _Role.on_tertiary_fixed:
                return 10.0
            if role == _Role.on_tertiary_fixed_variant:
                return 30.0
        var fixed_tone = MaterialDynamicColors._fixed_tone(role, scheme)
        if fixed_tone >= 0.0:
            return fixed_tone
        return 0.0 if scheme.is_dark else 100.0

    @staticmethod
    def _is_background(role: Int) -> Bool:
        return (
            role == _Role.background
            or role == _Role.surface
            or role == _Role.surface_dim
            or role == _Role.surface_bright
            or role == _Role.surface_container_lowest
            or role == _Role.surface_container_low
            or role == _Role.surface_container
            or role == _Role.surface_container_high
            or role == _Role.surface_container_highest
            or role == _Role.surface_variant
            or role == _Role.surface_tint
            or role == _Role.primary
            or role == _Role.primary_container
            or role == _Role.secondary
            or role == _Role.secondary_container
            or role == _Role.tertiary
            or role == _Role.tertiary_container
            or role == _Role.error
            or role == _Role.error_container
            or role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        )

    @staticmethod
    def _background_role(role: Int, scheme: DynamicScheme) -> Int:
        if (
            role == _Role.on_background
            or role == _Role.on_surface
            or role == _Role.on_surface_variant
            or role == _Role.outline
            or role == _Role.outline_variant
            or role == _Role.primary
            or role == _Role.primary_container
            or role == _Role.secondary
            or role == _Role.secondary_container
            or role == _Role.tertiary
            or role == _Role.tertiary_container
            or role == _Role.error
            or role == _Role.error_container
            or role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        ):
            return MaterialDynamicColors._highest_surface_role(scheme)
        if role == _Role.inverse_on_surface or role == _Role.inverse_primary:
            return _Role.inverse_surface
        if role == _Role.on_primary:
            return _Role.primary
        if role == _Role.on_primary_container:
            return _Role.primary_container
        if role == _Role.on_secondary:
            return _Role.secondary
        if role == _Role.on_secondary_container:
            return _Role.secondary_container
        if role == _Role.on_tertiary:
            return _Role.tertiary
        if role == _Role.on_tertiary_container:
            return _Role.tertiary_container
        if role == _Role.on_error:
            return _Role.error
        if role == _Role.on_error_container:
            return _Role.error_container
        if (
            role == _Role.on_primary_fixed
            or role == _Role.on_primary_fixed_variant
        ):
            return _Role.primary_fixed_dim
        if (
            role == _Role.on_secondary_fixed
            or role == _Role.on_secondary_fixed_variant
        ):
            return _Role.secondary_fixed_dim
        if (
            role == _Role.on_tertiary_fixed
            or role == _Role.on_tertiary_fixed_variant
        ):
            return _Role.tertiary_fixed_dim
        return -1

    @staticmethod
    def _second_background_role(role: Int) -> Int:
        if (
            role == _Role.on_primary_fixed
            or role == _Role.on_primary_fixed_variant
        ):
            return _Role.primary_fixed
        if (
            role == _Role.on_secondary_fixed
            or role == _Role.on_secondary_fixed_variant
        ):
            return _Role.secondary_fixed
        if (
            role == _Role.on_tertiary_fixed
            or role == _Role.on_tertiary_fixed_variant
        ):
            return _Role.tertiary_fixed
        return -1

    @staticmethod
    def _contrast_curve(role: Int, scheme: DynamicScheme) -> ContrastCurve:
        if MaterialDynamicColors._is_2025(scheme):
            if (
                role == _Role.on_primary
                or role == _Role.on_secondary
                or role == _Role.on_tertiary
                or role == _Role.on_primary_container
                or role == _Role.on_secondary_container
                or role == _Role.on_tertiary_container
            ):
                if scheme.platform == 0:
                    return ContrastCurve(6.0, 6.0, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if role == _Role.on_error:
                if scheme.platform == 0:
                    return ContrastCurve(6.0, 6.0, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if role == _Role.on_error_container:
                if scheme.platform == 0:
                    return ContrastCurve(4.5, 4.5, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if role == _Role.on_surface:
                if scheme.is_dark and scheme.platform == 0:
                    return ContrastCurve(11.0, 11.0, 21.0, 21.0)
                return ContrastCurve(9.0, 9.0, 11.0, 21.0)
            if role == _Role.on_surface_variant:
                if scheme.platform == 0:
                    if scheme.is_dark:
                        return ContrastCurve(6.0, 6.0, 7.0, 11.0)
                    return ContrastCurve(4.5, 4.5, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if role == _Role.outline:
                if scheme.platform == 0:
                    return ContrastCurve(3.0, 3.0, 4.5, 7.0)
                return ContrastCurve(4.5, 4.5, 7.0, 11.0)
            if role == _Role.outline_variant:
                if scheme.platform == 0:
                    return ContrastCurve(1.5, 1.5, 3.0, 5.5)
                return ContrastCurve(3.0, 3.0, 4.5, 7.0)
            if role == _Role.inverse_on_surface:
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if role == _Role.inverse_primary:
                if scheme.platform == 0:
                    return ContrastCurve(6.0, 6.0, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if (
                role == _Role.primary_dim
                or role == _Role.secondary_dim
                or role == _Role.tertiary_dim
                or role == _Role.error_dim
            ):
                return ContrastCurve(4.5, 4.5, 7.0, 11.0)
            if (
                role == _Role.primary
                or role == _Role.secondary
                or role == _Role.tertiary
                or role == _Role.error
            ):
                if scheme.platform == 0:
                    return ContrastCurve(4.5, 4.5, 7.0, 11.0)
                return ContrastCurve(7.0, 7.0, 11.0, 21.0)
            if (
                role == _Role.primary_container
                or role == _Role.secondary_container
                or role == _Role.tertiary_container
                or role == _Role.error_container
                or role == _Role.primary_fixed
                or role == _Role.secondary_fixed
                or role == _Role.tertiary_fixed
            ):
                if scheme.platform == 0 and scheme.contrast_level > 0.0:
                    return ContrastCurve(1.5, 1.5, 3.0, 5.5)
                return ContrastCurve(1.0, 1.0, 1.0, 1.0)
        if MaterialDynamicColors._is_cmf_2026(scheme):
            if (
                role == _Role.on_primary
                or role == _Role.on_secondary
                or role == _Role.on_tertiary
                or role == _Role.on_primary_container
                or role == _Role.on_secondary_container
                or role == _Role.on_tertiary_container
                or role == _Role.on_error
                or role == _Role.on_error_container
            ):
                return ContrastCurve(6.0, 6.0, 7.0, 11.0)
            if role == _Role.on_surface:
                if scheme.is_dark:
                    return ContrastCurve(11.0, 11.0, 21.0, 21.0)
                return ContrastCurve(9.0, 9.0, 11.0, 21.0)
            if role == _Role.on_surface_variant:
                if scheme.is_dark:
                    return ContrastCurve(6.0, 6.0, 7.0, 11.0)
                return ContrastCurve(4.5, 4.5, 7.0, 11.0)
            if role == _Role.outline:
                return ContrastCurve(3.0, 3.0, 4.5, 7.0)
            if role == _Role.outline_variant:
                return ContrastCurve(1.5, 1.5, 3.0, 5.5)
        if (
            role == _Role.on_background
            or role == _Role.on_primary_container
            or role == _Role.on_secondary_container
            or role == _Role.on_tertiary_container
            or role == _Role.on_error_container
            or role == _Role.on_primary_fixed_variant
            or role == _Role.on_secondary_fixed_variant
            or role == _Role.on_tertiary_fixed_variant
        ):
            return ContrastCurve(3.0, 4.5, 7.0, 11.0)
        if (
            role == _Role.on_surface
            or role == _Role.inverse_on_surface
            or role == _Role.on_primary
            or role == _Role.on_secondary
            or role == _Role.on_tertiary
            or role == _Role.on_error
            or role == _Role.on_primary_fixed
            or role == _Role.on_secondary_fixed
            or role == _Role.on_tertiary_fixed
        ):
            return ContrastCurve(4.5, 7.0, 11.0, 21.0)
        if role == _Role.on_surface_variant:
            return ContrastCurve(3.0, 4.5, 7.0, 11.0)
        if role == _Role.outline:
            return ContrastCurve(1.5, 3.0, 4.5, 7.0)
        if role == _Role.outline_variant:
            return ContrastCurve(1.0, 1.0, 3.0, 4.5)
        if (
            role == _Role.primary
            or role == _Role.secondary
            or role == _Role.tertiary
            or role == _Role.error
            or role == _Role.inverse_primary
        ):
            return ContrastCurve(3.0, 4.5, 7.0, 7.0)
        if (
            role == _Role.primary_container
            or role == _Role.secondary_container
            or role == _Role.tertiary_container
            or role == _Role.error_container
            or role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        ):
            return ContrastCurve(1.0, 1.0, 3.0, 4.5)
        return ContrastCurve(1.0, 1.0, 1.0, 1.0)

    @staticmethod
    def _has_tone_delta_pair(role: Int) -> Bool:
        return (
            role == _Role.primary
            or role == _Role.primary_container
            or role == _Role.secondary
            or role == _Role.secondary_container
            or role == _Role.tertiary
            or role == _Role.tertiary_container
            or role == _Role.error
            or role == _Role.error_container
            or role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        )

    @staticmethod
    def _role_a(role: Int) -> Int:
        if role == _Role.primary or role == _Role.primary_container:
            return _Role.primary_container
        if role == _Role.secondary or role == _Role.secondary_container:
            return _Role.secondary_container
        if role == _Role.tertiary or role == _Role.tertiary_container:
            return _Role.tertiary_container
        if role == _Role.error or role == _Role.error_container:
            return _Role.error_container
        if role == _Role.primary_fixed or role == _Role.primary_fixed_dim:
            return _Role.primary_fixed
        if role == _Role.secondary_fixed or role == _Role.secondary_fixed_dim:
            return _Role.secondary_fixed
        return _Role.tertiary_fixed

    @staticmethod
    def _role_b(role: Int) -> Int:
        if role == _Role.primary or role == _Role.primary_container:
            return _Role.primary
        if role == _Role.secondary or role == _Role.secondary_container:
            return _Role.secondary
        if role == _Role.tertiary or role == _Role.tertiary_container:
            return _Role.tertiary
        if role == _Role.error or role == _Role.error_container:
            return _Role.error
        if role == _Role.primary_fixed or role == _Role.primary_fixed_dim:
            return _Role.primary_fixed_dim
        if role == _Role.secondary_fixed or role == _Role.secondary_fixed_dim:
            return _Role.secondary_fixed_dim
        return _Role.tertiary_fixed_dim

    @staticmethod
    def _pair_polarity(role: Int) -> Int:
        if (
            role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        ):
            return TonePolarity.lighter
        return TonePolarity.nearer

    @staticmethod
    def _pair_delta(role: Int, scheme: DynamicScheme) -> Float64:
        if MaterialDynamicColors._is_cmf_2026(
            scheme
        ) or MaterialDynamicColors._is_2025(scheme):
            if scheme.platform == 1 and (
                role == _Role.primary_container
                or role == _Role.secondary_container
                or role == _Role.tertiary_container
                or role == _Role.error_container
            ):
                return 10.0
            return 5.0
        return 10.0

    @staticmethod
    def _modern_role_a(role: Int) -> Int:
        if role == _Role.primary_dim:
            return _Role.primary_dim
        if role == _Role.secondary_dim:
            return _Role.secondary_dim
        if role == _Role.tertiary_dim:
            return _Role.tertiary_dim
        if role == _Role.error_dim:
            return _Role.error_dim
        if role == _Role.primary or role == _Role.primary_container:
            return _Role.primary_container
        if role == _Role.secondary or role == _Role.secondary_container:
            return _Role.secondary_container
        if role == _Role.tertiary or role == _Role.tertiary_container:
            return _Role.tertiary_container
        if role == _Role.error or role == _Role.error_container:
            return _Role.error_container
        if role == _Role.primary_fixed or role == _Role.primary_fixed_dim:
            return _Role.primary_fixed_dim
        if role == _Role.secondary_fixed or role == _Role.secondary_fixed_dim:
            return _Role.secondary_fixed_dim
        return _Role.tertiary_fixed_dim

    @staticmethod
    def _modern_role_b(role: Int) -> Int:
        if role == _Role.primary_dim:
            return _Role.primary
        if role == _Role.secondary_dim:
            return _Role.secondary
        if role == _Role.tertiary_dim:
            return _Role.tertiary
        if role == _Role.error_dim:
            return _Role.error
        if role == _Role.primary or role == _Role.primary_container:
            return _Role.primary
        if role == _Role.secondary or role == _Role.secondary_container:
            return _Role.secondary
        if role == _Role.tertiary or role == _Role.tertiary_container:
            return _Role.tertiary
        if role == _Role.error or role == _Role.error_container:
            return _Role.error
        if role == _Role.primary_fixed or role == _Role.primary_fixed_dim:
            return _Role.primary_fixed
        if role == _Role.secondary_fixed or role == _Role.secondary_fixed_dim:
            return _Role.secondary_fixed
        return _Role.tertiary_fixed

    @staticmethod
    def _modern_pair_is_fixed(role: Int) -> Bool:
        return (
            role == _Role.primary_fixed
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed
            or role == _Role.tertiary_fixed_dim
        )

    @staticmethod
    def _modern_pair_is_darker(role: Int, scheme: DynamicScheme) -> Bool:
        if (
            role == _Role.primary_dim
            or role == _Role.secondary_dim
            or role == _Role.tertiary_dim
            or role == _Role.error_dim
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed_dim
        ):
            return True
        if scheme.platform == 1:
            return (
                role == _Role.primary_container
                or role == _Role.secondary_container
                or role == _Role.tertiary_container
                or role == _Role.error_container
            )
        return False

    @staticmethod
    def _modern_has_tone_delta_pair(role: Int, scheme: DynamicScheme) -> Bool:
        if (
            role == _Role.primary
            or role == _Role.secondary
            or role == _Role.tertiary
            or role == _Role.error
        ):
            return scheme.platform == 0
        if (
            role == _Role.primary_dim
            or role == _Role.secondary_dim
            or role == _Role.tertiary_dim
            or role == _Role.error_dim
            or role == _Role.primary_fixed_dim
            or role == _Role.secondary_fixed_dim
            or role == _Role.tertiary_fixed_dim
        ):
            return True
        if scheme.platform == 1:
            return (
                role == _Role.primary_container
                or role == _Role.secondary_container
                or role == _Role.tertiary_container
                or role == _Role.error_container
            )
        return False

    @staticmethod
    def _modern_background_role(role: Int, scheme: DynamicScheme) -> Int:
        if scheme.platform == 1:
            if (
                role == _Role.primary_container
                or role == _Role.secondary_container
                or role == _Role.tertiary_container
                or role == _Role.error_container
            ):
                return -1
            if (
                role == _Role.on_surface
                or role == _Role.on_surface_variant
                or role == _Role.outline
                or role == _Role.outline_variant
            ):
                return _Role.surface_container_high
            if (
                role == _Role.primary
                or role == _Role.secondary
                or role == _Role.tertiary
                or role == _Role.error
                or role == _Role.primary_dim
                or role == _Role.secondary_dim
                or role == _Role.tertiary_dim
                or role == _Role.error_dim
            ):
                return _Role.surface_container_high
            if role == _Role.on_primary:
                return _Role.primary_dim
            if role == _Role.on_secondary:
                return _Role.secondary_dim
            if role == _Role.on_tertiary:
                return _Role.tertiary_dim
            if role == _Role.on_error:
                return _Role.error_dim
        return MaterialDynamicColors._background_role(role, scheme)

    @staticmethod
    def _modern_has_contrast_curve(role: Int, scheme: DynamicScheme) -> Bool:
        if (
            role == _Role.primary_container
            or role == _Role.secondary_container
            or role == _Role.tertiary_container
            or role == _Role.error_container
            or role == _Role.primary_fixed
            or role == _Role.secondary_fixed
            or role == _Role.tertiary_fixed
        ):
            return scheme.platform == 0 and scheme.contrast_level > 0.0
        return True

    @staticmethod
    def _pair_stay_together(role: Int) -> Bool:
        return (
            MaterialDynamicColors._pair_polarity(role) == TonePolarity.lighter
        )

    @staticmethod
    def get_tone(role: Int, scheme: DynamicScheme) -> Float64:
        var decreasing_contrast = scheme.contrast_level < 0.0

        if MaterialDynamicColors._is_2025(
            scheme
        ) or MaterialDynamicColors._is_cmf_2026(scheme):
            if MaterialDynamicColors._modern_has_tone_delta_pair(role, scheme):
                var role_a = MaterialDynamicColors._modern_role_a(role)
                var role_b = MaterialDynamicColors._modern_role_b(role)
                if scheme.platform == 1:
                    if role == _Role.primary_container:
                        role_b = _Role.primary_dim
                    elif role == _Role.secondary_container:
                        role_b = _Role.secondary_dim
                    elif role == _Role.tertiary_container:
                        role_b = _Role.tertiary_dim
                    elif role == _Role.error_container:
                        role_b = _Role.error_dim
                var am_role_a = role == role_a
                var self_role = role_a if am_role_a else role_b
                var ref_role = role_b if am_role_a else role_a
                var self_tone = MaterialDynamicColors._base_tone(
                    self_role, scheme
                )
                var ref_tone = MaterialDynamicColors._base_tone(
                    ref_role, scheme
                )
                if scheme.platform == 1 and (
                    role == _Role.primary_container
                    or role == _Role.secondary_container
                    or role == _Role.tertiary_container
                    or role == _Role.error_container
                ):
                    ref_tone = MaterialDynamicColors.get_tone(ref_role, scheme)
                elif (
                    role == _Role.primary_dim
                    or role == _Role.secondary_dim
                    or role == _Role.tertiary_dim
                    or role == _Role.error_dim
                ):
                    ref_tone = MaterialDynamicColors.get_tone(ref_role, scheme)
                var absolute_delta = MaterialDynamicColors._pair_delta(
                    role, scheme
                )
                if MaterialDynamicColors._modern_pair_is_darker(role, scheme):
                    absolute_delta = -absolute_delta
                else:
                    if scheme.is_dark:
                        absolute_delta = -absolute_delta
                var relative_delta = (
                    absolute_delta if am_role_a else -absolute_delta
                )

                if MaterialDynamicColors._modern_pair_is_fixed(role):
                    self_tone = MathUtils.clampDouble(
                        0.0, 100.0, ref_tone + relative_delta
                    )
                elif relative_delta > 0.0:
                    self_tone = MathUtils.clampDouble(
                        ref_tone + relative_delta, 100.0, self_tone
                    )
                else:
                    self_tone = MathUtils.clampDouble(
                        0.0, ref_tone + relative_delta, self_tone
                    )

                var bg_role = MaterialDynamicColors._modern_background_role(
                    role, scheme
                )
                if bg_role >= 0:
                    if not MaterialDynamicColors._modern_has_contrast_curve(
                        role, scheme
                    ):
                        return self_tone
                    var bg_tone = MaterialDynamicColors.get_tone(
                        bg_role, scheme
                    )
                    var desired_ratio = MaterialDynamicColors._contrast_curve(
                        role, scheme
                    ).getContrast(scheme.contrast_level)
                    if (
                        Contrast.ratio_of_tones(bg_tone, self_tone)
                        < desired_ratio
                        or decreasing_contrast
                    ):
                        self_tone = MaterialDynamicColors.foreground_tone(
                            bg_tone, desired_ratio
                        )

                if MaterialDynamicColors._is_background(role) and not (
                    role == _Role.primary_fixed_dim
                    or role == _Role.secondary_fixed_dim
                    or role == _Role.tertiary_fixed_dim
                ):
                    if self_tone >= 57.0:
                        self_tone = MathUtils.clampDouble(
                            65.0, 100.0, self_tone
                        )
                    else:
                        self_tone = MathUtils.clampDouble(0.0, 49.0, self_tone)
                return self_tone

            var answer = MaterialDynamicColors._base_tone(role, scheme)
            var bg_role = MaterialDynamicColors._modern_background_role(
                role, scheme
            )
            if bg_role < 0:
                return answer
            if not MaterialDynamicColors._modern_has_contrast_curve(
                role, scheme
            ):
                return answer
            var bg_tone = MaterialDynamicColors.get_tone(bg_role, scheme)
            var desired_ratio = MaterialDynamicColors._contrast_curve(
                role, scheme
            ).getContrast(scheme.contrast_level)
            if (
                Contrast.ratio_of_tones(bg_tone, answer) < desired_ratio
                or decreasing_contrast
            ):
                answer = MaterialDynamicColors.foreground_tone(
                    bg_tone, desired_ratio
                )
            if MaterialDynamicColors._is_background(role) and not (
                role == _Role.primary_fixed_dim
                or role == _Role.secondary_fixed_dim
                or role == _Role.tertiary_fixed_dim
            ):
                if answer >= 57.0:
                    answer = MathUtils.clampDouble(65.0, 100.0, answer)
                else:
                    answer = MathUtils.clampDouble(0.0, 49.0, answer)
            return answer

        if MaterialDynamicColors._has_tone_delta_pair(role):
            var role_a = MaterialDynamicColors._role_a(role)
            var role_b = MaterialDynamicColors._role_b(role)
            var delta = MaterialDynamicColors._pair_delta(role, scheme)
            var polarity = MaterialDynamicColors._pair_polarity(role)
            var stay_together = MaterialDynamicColors._pair_stay_together(role)

            var bg_role = MaterialDynamicColors._background_role(role, scheme)
            var bg_tone = MaterialDynamicColors.get_tone(bg_role, scheme)

            var a_is_nearer = (
                polarity == TonePolarity.nearer
                or (polarity == TonePolarity.lighter and not scheme.is_dark)
                or (polarity == TonePolarity.darker and scheme.is_dark)
            )
            var nearer = role_a if a_is_nearer else role_b
            var farther = role_b if a_is_nearer else role_a
            var am_nearer = role == nearer
            var expansion_dir = 1.0 if scheme.is_dark else -1.0

            var n_contrast = MaterialDynamicColors._contrast_curve(
                nearer, scheme
            ).getContrast(scheme.contrast_level)
            var f_contrast = MaterialDynamicColors._contrast_curve(
                farther, scheme
            ).getContrast(scheme.contrast_level)

            var n_initial_tone = MaterialDynamicColors._base_tone(
                nearer, scheme
            )
            var n_tone = n_initial_tone if Contrast.ratio_of_tones(
                bg_tone, n_initial_tone
            ) >= n_contrast else MaterialDynamicColors.foreground_tone(
                bg_tone, n_contrast
            )

            var f_initial_tone = MaterialDynamicColors._base_tone(
                farther, scheme
            )
            var f_tone = f_initial_tone if Contrast.ratio_of_tones(
                bg_tone, f_initial_tone
            ) >= f_contrast else MaterialDynamicColors.foreground_tone(
                bg_tone, f_contrast
            )

            if decreasing_contrast:
                n_tone = MaterialDynamicColors.foreground_tone(
                    bg_tone, n_contrast
                )
                f_tone = MaterialDynamicColors.foreground_tone(
                    bg_tone, f_contrast
                )

            if (f_tone - n_tone) * expansion_dir < delta:
                f_tone = MathUtils.clampDouble(
                    0.0, 100.0, n_tone + delta * expansion_dir
                )
                if (f_tone - n_tone) * expansion_dir < delta:
                    n_tone = MathUtils.clampDouble(
                        0.0, 100.0, f_tone - delta * expansion_dir
                    )

            if 50.0 <= n_tone and n_tone < 60.0:
                if expansion_dir > 0.0:
                    n_tone = 60.0
                    f_tone = math.max(f_tone, n_tone + delta * expansion_dir)
                else:
                    n_tone = 49.0
                    f_tone = math.min(f_tone, n_tone + delta * expansion_dir)
            elif 50.0 <= f_tone and f_tone < 60.0:
                if stay_together:
                    if expansion_dir > 0.0:
                        n_tone = 60.0
                        f_tone = math.max(
                            f_tone, n_tone + delta * expansion_dir
                        )
                    else:
                        n_tone = 49.0
                        f_tone = math.min(
                            f_tone, n_tone + delta * expansion_dir
                        )
                else:
                    f_tone = 60.0 if expansion_dir > 0.0 else 49.0

            return n_tone if am_nearer else f_tone

        var answer = MaterialDynamicColors._base_tone(role, scheme)
        var bg_role = MaterialDynamicColors._background_role(role, scheme)
        if bg_role < 0:
            return answer

        var bg_tone = MaterialDynamicColors.get_tone(bg_role, scheme)
        var desired_ratio = MaterialDynamicColors._contrast_curve(
            role, scheme
        ).getContrast(scheme.contrast_level)

        if Contrast.ratio_of_tones(bg_tone, answer) < desired_ratio:
            answer = MaterialDynamicColors.foreground_tone(
                bg_tone, desired_ratio
            )

        if decreasing_contrast:
            answer = MaterialDynamicColors.foreground_tone(
                bg_tone, desired_ratio
            )

        if (
            MaterialDynamicColors._is_background(role)
            and 50.0 <= answer
            and answer < 60.0
        ):
            if Contrast.ratio_of_tones(49.0, bg_tone) >= desired_ratio:
                answer = 49.0
            else:
                answer = 60.0

        var second_bg_role = MaterialDynamicColors._second_background_role(role)
        if second_bg_role >= 0:
            var bg_tone_1 = MaterialDynamicColors.get_tone(bg_role, scheme)
            var bg_tone_2 = MaterialDynamicColors.get_tone(
                second_bg_role, scheme
            )
            var upper = math.max(bg_tone_1, bg_tone_2)
            var lower = math.min(bg_tone_1, bg_tone_2)

            if (
                Contrast.ratio_of_tones(upper, answer) >= desired_ratio
                and Contrast.ratio_of_tones(lower, answer) >= desired_ratio
            ):
                return answer

            var light_option = Contrast.lighter_tone(upper, desired_ratio)
            var dark_option = Contrast.darker_tone(lower, desired_ratio)
            var prefers_light = (
                MaterialDynamicColors.tone_prefers_light_foreground(bg_tone_1)
                or MaterialDynamicColors.tone_prefers_light_foreground(
                    bg_tone_2
                )
            )
            if prefers_light:
                return 100.0 if light_option < 0.0 else light_option
            if light_option >= 0.0 and dark_option < 0.0:
                return light_option
            return 0.0 if dark_option < 0.0 else dark_option

        return answer

    @staticmethod
    def get_hct(role: Int, scheme: DynamicScheme) -> Hct:
        if role == _Role.shadow or role == _Role.scrim:
            return Hct.from_int(ColorUtils.argbFromLstar(0.0))
        var palette = MaterialDynamicColors.palette_for(role, scheme)
        var multiplier = MaterialDynamicColors._chroma_multiplier(role, scheme)
        var tone = MaterialDynamicColors.get_tone(role, scheme)
        if multiplier != 1.0:
            var chroma = palette.chroma * multiplier
            if tone == 99.0 and Hct.is_yellow(palette.hue):
                return TonalPalette.of(palette.hue, chroma).get_hct(tone)
            return Hct.from_hct(palette.hue, chroma, tone)
        return palette.get_hct(tone)

    @staticmethod
    def get_argb(role: Int, scheme: DynamicScheme) -> Int:
        if role == _Role.shadow or role == _Role.scrim:
            return 0xFF000000
        return MaterialDynamicColors.get_hct(role, scheme).to_int()
