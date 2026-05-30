from lib.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.hct.hct import Hct


struct DynamicColorRole:
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


struct DynamicColor(Copyable, Movable):
    var role: Int

    def __init__(out self, role: Int):
        self.role = role

    def get_tone(self, scheme: DynamicScheme) -> Float64:
        return MaterialDynamicColors.get_tone(self.role, scheme)

    def get_hct(self, scheme: DynamicScheme) -> Hct:
        return MaterialDynamicColors.get_hct(self.role, scheme)

    def get_argb(self, scheme: DynamicScheme) -> Int:
        return MaterialDynamicColors.get_argb(self.role, scheme)

    @staticmethod
    def foreground_tone(bg_tone: Float64, ratio: Float64) -> Float64:
        return MaterialDynamicColors.foreground_tone(bg_tone, ratio)

    @staticmethod
    def enable_light_foreground(tone: Float64) -> Float64:
        return MaterialDynamicColors.enable_light_foreground(tone)

    @staticmethod
    def tone_prefers_light_foreground(tone: Float64) -> Bool:
        return MaterialDynamicColors.tone_prefers_light_foreground(tone)

    @staticmethod
    def tone_allows_light_foreground(tone: Float64) -> Bool:
        return MaterialDynamicColors.tone_allows_light_foreground(tone)
