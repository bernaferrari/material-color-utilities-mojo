import math
from lib.hct.hct import Hct


struct DislikeAnalyzer:
    @staticmethod
    fn is_disliked(hct: Hct) -> Bool:
        let hue_passes = (math.round(hct.hue) > 90) and (math.round(hct.hue) <= 111.0)
        let chroma_passes = math.round(hct.chroma) > 16.0
        let tone_passes = math.round(hct.tone) < 65.0
        return hue_passes and chroma_passes and tone_passes

    @staticmethod
    fn fix_if_disliked(hct: Hct) -> Hct:
        if DislikeAnalyzer.is_disliked(hct):
            return Hct.from_hct(hct.hue, hct.chroma, 70.0)
        return hct
