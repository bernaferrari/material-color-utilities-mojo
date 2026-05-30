from lib.palettes.tonal_palette import TonalPalette


struct CorePalettes(Copyable, Movable):
    var primary: TonalPalette
    var secondary: TonalPalette
    var tertiary: TonalPalette
    var neutral: TonalPalette
    var neutral_variant: TonalPalette

    def __init__(
        out self,
        var primary: TonalPalette,
        var secondary: TonalPalette,
        var tertiary: TonalPalette,
        var neutral: TonalPalette,
        var neutral_variant: TonalPalette,
    ):
        self.primary = primary^
        self.secondary = secondary^
        self.tertiary = tertiary^
        self.neutral = neutral^
        self.neutral_variant = neutral_variant^
