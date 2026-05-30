from lib.palettes.core_palette import CorePalette


struct SchemeAndroid(Copyable, Movable):
    var color_accent_primary: Int
    var color_accent_primary_variant: Int
    var color_accent_secondary: Int
    var color_accent_secondary_variant: Int
    var color_accent_tertiary: Int
    var color_accent_tertiary_variant: Int
    var text_color_primary: Int
    var text_color_secondary: Int
    var text_color_tertiary: Int
    var text_color_primary_inverse: Int
    var text_color_secondary_inverse: Int
    var text_color_tertiary_inverse: Int
    var color_background: Int
    var color_background_floating: Int
    var color_surface: Int
    var color_surface_variant: Int
    var color_surface_highlight: Int
    var surface_header: Int
    var under_surface: Int
    var off_state: Int
    var accent_surface: Int
    var text_primary_on_accent: Int
    var text_secondary_on_accent: Int
    var volume_background: Int
    var scrim: Int

    def __init__(
        out self,
        color_accent_primary: Int,
        color_accent_primary_variant: Int,
        color_accent_secondary: Int,
        color_accent_secondary_variant: Int,
        color_accent_tertiary: Int,
        color_accent_tertiary_variant: Int,
        text_color_primary: Int,
        text_color_secondary: Int,
        text_color_tertiary: Int,
        text_color_primary_inverse: Int,
        text_color_secondary_inverse: Int,
        text_color_tertiary_inverse: Int,
        color_background: Int,
        color_background_floating: Int,
        color_surface: Int,
        color_surface_variant: Int,
        color_surface_highlight: Int,
        surface_header: Int,
        under_surface: Int,
        off_state: Int,
        accent_surface: Int,
        text_primary_on_accent: Int,
        text_secondary_on_accent: Int,
        volume_background: Int,
        scrim: Int,
    ):
        self.color_accent_primary = color_accent_primary
        self.color_accent_primary_variant = color_accent_primary_variant
        self.color_accent_secondary = color_accent_secondary
        self.color_accent_secondary_variant = color_accent_secondary_variant
        self.color_accent_tertiary = color_accent_tertiary
        self.color_accent_tertiary_variant = color_accent_tertiary_variant
        self.text_color_primary = text_color_primary
        self.text_color_secondary = text_color_secondary
        self.text_color_tertiary = text_color_tertiary
        self.text_color_primary_inverse = text_color_primary_inverse
        self.text_color_secondary_inverse = text_color_secondary_inverse
        self.text_color_tertiary_inverse = text_color_tertiary_inverse
        self.color_background = color_background
        self.color_background_floating = color_background_floating
        self.color_surface = color_surface
        self.color_surface_variant = color_surface_variant
        self.color_surface_highlight = color_surface_highlight
        self.surface_header = surface_header
        self.under_surface = under_surface
        self.off_state = off_state
        self.accent_surface = accent_surface
        self.text_primary_on_accent = text_primary_on_accent
        self.text_secondary_on_accent = text_secondary_on_accent
        self.volume_background = volume_background
        self.scrim = scrim

    @staticmethod
    def light(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.light_from_core_palette(CorePalette.of(argb))

    @staticmethod
    def dark(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.dark_from_core_palette(CorePalette.of(argb))

    @staticmethod
    def light_content(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.light_from_core_palette(
            CorePalette.content_of(argb)
        )

    @staticmethod
    def lightContent(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.light_content(argb)

    @staticmethod
    def dark_content(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.dark_from_core_palette(
            CorePalette.content_of(argb)
        )

    @staticmethod
    def darkContent(argb: Int) -> SchemeAndroid:
        return SchemeAndroid.dark_content(argb)

    @staticmethod
    def light_from_core_palette(core: CorePalette) -> SchemeAndroid:
        return SchemeAndroid(
            core.primary.get(90),
            core.primary.get(40),
            core.secondary.get(90),
            core.secondary.get(40),
            core.tertiary.get(90),
            core.tertiary.get(40),
            core.neutral.get(10),
            core.neutral_variant.get(30),
            core.neutral_variant.get(50),
            core.neutral.get(95),
            core.neutral.get(80),
            core.neutral.get(60),
            core.neutral.get(95),
            core.neutral.get(98),
            core.neutral.get(98),
            core.neutral.get(90),
            core.neutral.get(100),
            core.neutral.get(90),
            core.neutral.get(0),
            core.neutral.get(20),
            core.secondary.get(95),
            core.neutral.get(10),
            core.neutral_variant.get(30),
            core.neutral.get(25),
            core.neutral.get(80),
        )

    @staticmethod
    def lightFromCorePalette(core: CorePalette) -> SchemeAndroid:
        return SchemeAndroid.light_from_core_palette(core)

    @staticmethod
    def dark_from_core_palette(core: CorePalette) -> SchemeAndroid:
        return SchemeAndroid(
            core.primary.get(90),
            core.primary.get(70),
            core.secondary.get(90),
            core.secondary.get(70),
            core.tertiary.get(90),
            core.tertiary.get(70),
            core.neutral.get(95),
            core.neutral_variant.get(80),
            core.neutral_variant.get(60),
            core.neutral.get(10),
            core.neutral.get(30),
            core.neutral.get(50),
            core.neutral.get(10),
            core.neutral.get(10),
            core.neutral.get(20),
            core.neutral.get(30),
            core.neutral.get(35),
            core.neutral.get(30),
            core.neutral.get(0),
            core.neutral.get(20),
            core.secondary.get(95),
            core.neutral.get(10),
            core.neutral_variant.get(30),
            core.neutral.get(25),
            core.neutral.get(80),
        )

    @staticmethod
    def darkFromCorePalette(core: CorePalette) -> SchemeAndroid:
        return SchemeAndroid.dark_from_core_palette(core)
