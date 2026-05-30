import std.math as math
from lib.hct.hct import Hct


struct DislikeAnalyzer:
    @staticmethod
    def is_disliked(hct: Hct) -> Bool:
        var hue_passes = (math.round(hct.hue) > 90) and (
            math.round(hct.hue) <= 111.0
        )
        var chroma_passes = math.round(hct.chroma) > 16.0
        var tone_passes = math.round(hct.tone) < 65.0
        return hue_passes and chroma_passes and tone_passes

    @staticmethod
    def fix_if_disliked(hct: Hct) -> Hct:
        if DislikeAnalyzer.is_disliked(hct):
            return Hct.from_hct(hct.hue, hct.chroma, 70.0)
        return hct.copy()
