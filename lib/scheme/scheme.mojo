from lib.palettes.core_palette import CorePalette


struct Scheme(Copyable, Movable):
    var primary: Int
    var on_primary: Int
    var primary_container: Int
    var on_primary_container: Int
    var secondary: Int
    var on_secondary: Int
    var secondary_container: Int
    var on_secondary_container: Int
    var tertiary: Int
    var on_tertiary: Int
    var tertiary_container: Int
    var on_tertiary_container: Int
    var error: Int
    var on_error: Int
    var error_container: Int
    var on_error_container: Int
    var background: Int
    var on_background: Int
    var surface: Int
    var on_surface: Int
    var surface_variant: Int
    var on_surface_variant: Int
    var outline: Int
    var outline_variant: Int
    var shadow: Int
    var scrim: Int
    var inverse_surface: Int
    var inverse_on_surface: Int
    var inverse_primary: Int

    def __init__(
        out self,
        primary: Int,
        on_primary: Int,
        primary_container: Int,
        on_primary_container: Int,
        secondary: Int,
        on_secondary: Int,
        secondary_container: Int,
        on_secondary_container: Int,
        tertiary: Int,
        on_tertiary: Int,
        tertiary_container: Int,
        on_tertiary_container: Int,
        error: Int,
        on_error: Int,
        error_container: Int,
        on_error_container: Int,
        background: Int,
        on_background: Int,
        surface: Int,
        on_surface: Int,
        surface_variant: Int,
        on_surface_variant: Int,
        outline: Int,
        outline_variant: Int,
        shadow: Int,
        scrim: Int,
        inverse_surface: Int,
        inverse_on_surface: Int,
        inverse_primary: Int,
    ):
        self.primary = primary
        self.on_primary = on_primary
        self.primary_container = primary_container
        self.on_primary_container = on_primary_container
        self.secondary = secondary
        self.on_secondary = on_secondary
        self.secondary_container = secondary_container
        self.on_secondary_container = on_secondary_container
        self.tertiary = tertiary
        self.on_tertiary = on_tertiary
        self.tertiary_container = tertiary_container
        self.on_tertiary_container = on_tertiary_container
        self.error = error
        self.on_error = on_error
        self.error_container = error_container
        self.on_error_container = on_error_container
        self.background = background
        self.on_background = on_background
        self.surface = surface
        self.on_surface = on_surface
        self.surface_variant = surface_variant
        self.on_surface_variant = on_surface_variant
        self.outline = outline
        self.outline_variant = outline_variant
        self.shadow = shadow
        self.scrim = scrim
        self.inverse_surface = inverse_surface
        self.inverse_on_surface = inverse_on_surface
        self.inverse_primary = inverse_primary

    @staticmethod
    def light(color: Int) -> Scheme:
        return Scheme.light_from_core_palette(CorePalette.of(color))

    @staticmethod
    def dark(color: Int) -> Scheme:
        return Scheme.dark_from_core_palette(CorePalette.of(color))

    @staticmethod
    def light_content(color: Int) -> Scheme:
        return Scheme.light_from_core_palette(CorePalette.content_of(color))

    @staticmethod
    def dark_content(color: Int) -> Scheme:
        return Scheme.dark_from_core_palette(CorePalette.content_of(color))

    @staticmethod
    def light_from_core_palette(palette: CorePalette) -> Scheme:
        return Scheme(
            palette.primary.get(40),
            palette.primary.get(100),
            palette.primary.get(90),
            palette.primary.get(10),
            palette.secondary.get(40),
            palette.secondary.get(100),
            palette.secondary.get(90),
            palette.secondary.get(10),
            palette.tertiary.get(40),
            palette.tertiary.get(100),
            palette.tertiary.get(90),
            palette.tertiary.get(10),
            palette.error.get(40),
            palette.error.get(100),
            palette.error.get(90),
            palette.error.get(10),
            palette.neutral.get(99),
            palette.neutral.get(10),
            palette.neutral.get(99),
            palette.neutral.get(10),
            palette.neutral_variant.get(90),
            palette.neutral_variant.get(30),
            palette.neutral_variant.get(50),
            palette.neutral_variant.get(80),
            palette.neutral.get(0),
            palette.neutral.get(0),
            palette.neutral.get(20),
            palette.neutral.get(95),
            palette.primary.get(80),
        )

    @staticmethod
    def dark_from_core_palette(palette: CorePalette) -> Scheme:
        return Scheme(
            palette.primary.get(80),
            palette.primary.get(20),
            palette.primary.get(30),
            palette.primary.get(90),
            palette.secondary.get(80),
            palette.secondary.get(20),
            palette.secondary.get(30),
            palette.secondary.get(90),
            palette.tertiary.get(80),
            palette.tertiary.get(20),
            palette.tertiary.get(30),
            palette.tertiary.get(90),
            palette.error.get(80),
            palette.error.get(20),
            palette.error.get(30),
            palette.error.get(80),
            palette.neutral.get(10),
            palette.neutral.get(90),
            palette.neutral.get(10),
            palette.neutral.get(90),
            palette.neutral_variant.get(30),
            palette.neutral_variant.get(80),
            palette.neutral_variant.get(60),
            palette.neutral_variant.get(30),
            palette.neutral.get(0),
            palette.neutral.get(0),
            palette.neutral.get(90),
            palette.neutral.get(20),
            palette.primary.get(40),
        )
