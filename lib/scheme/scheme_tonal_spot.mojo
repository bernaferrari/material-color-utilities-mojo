from lib.dynamiccolor.dynamic_scheme import DynamicScheme
from lib.dynamiccolor.variant import Variant
from lib.hct.hct import Hct


struct SchemeTonalSpot:
    @staticmethod
    def make(
        source_color_hct: Hct,
        is_dark: Bool,
        contrast_level: Float64,
        spec_version: Int = 2021,
        platform: Int = 0,
    ) -> DynamicScheme:
        return DynamicScheme.from_source(
            source_color_hct.copy(),
            Variant.tonal_spot,
            is_dark,
            contrast_level,
            platform,
            spec_version,
        )
