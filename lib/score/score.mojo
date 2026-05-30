from std.collections import Dict, List
from std.math import floor, round

from lib.hct.hct import Hct
from lib.utils.math_utils import MathUtils


struct _ScoredHct(Copyable, Movable):
    var hct: Hct
    var score: Float64

    def __init__(out self, var hct: Hct, score: Float64):
        self.hct = hct^
        self.score = score


struct Score:
    comptime _target_chroma = 48.0
    comptime _weight_proportion = 0.7
    comptime _weight_chroma_above = 0.3
    comptime _weight_chroma_below = 0.1
    comptime _cutoff_chroma = 5.0
    comptime _cutoff_excited_proportion = 0.01

    @staticmethod
    def _insert_scored_desc(
        mut scored: List[_ScoredHct], var value: _ScoredHct
    ):
        var index = 0
        while index < len(scored):
            if value.score > scored[index].score:
                break
            index += 1
        scored.insert(index, value^)

    @staticmethod
    def score(
        colors_to_population: Dict[Int, Int],
        desired: Int = 4,
        fallback_color_argb: Int = 0xFF4285F4,
        filter: Bool = True,
    ) -> List[Int]:
        var colors_hct = List[Hct]()
        var hue_population = List[Int]()
        hue_population.resize(360, 0)
        var population_sum = 0

        for item in colors_to_population.items():
            var argb = item.key
            var population = item.value
            var hct = Hct.from_int(argb)
            var hue = Int(floor(hct.hue))
            hue_population[hue] += population
            population_sum += population
            colors_hct.append(hct.copy())

        var hue_excited_proportions = List[Float64]()
        hue_excited_proportions.resize(360, 0.0)
        if population_sum > 0:
            for hue in range(360):
                var proportion = Float64(hue_population[hue]) / Float64(
                    population_sum
                )
                for i in range(hue - 14, hue + 16):
                    var neighbor_hue = MathUtils.sanitizeDegreesInt(i)
                    hue_excited_proportions[neighbor_hue] += proportion

        var scored_hcts = List[_ScoredHct]()
        for hct in colors_hct:
            var hue = MathUtils.sanitizeDegreesInt(Int(round(hct.hue)))
            var proportion = hue_excited_proportions[hue]
            if filter and (
                hct.chroma < Score._cutoff_chroma
                or proportion <= Score._cutoff_excited_proportion
            ):
                continue

            var proportion_score = proportion * 100.0 * Score._weight_proportion
            var chroma_weight = (
                Score._weight_chroma_below if hct.chroma
                < Score._target_chroma else Score._weight_chroma_above
            )
            var chroma_score = (
                hct.chroma - Score._target_chroma
            ) * chroma_weight
            Score._insert_scored_desc(
                scored_hcts,
                _ScoredHct(hct.copy(), proportion_score + chroma_score),
            )

        var chosen_colors = List[Hct]()
        for difference_degrees in range(90, 14, -1):
            chosen_colors.clear()
            for entry in scored_hcts:
                var hct = entry.hct.copy()
                var duplicate_hue = False
                for chosen_hct in chosen_colors:
                    if MathUtils.differenceDegrees(
                        hct.hue, chosen_hct.hue
                    ) < Float64(difference_degrees):
                        duplicate_hue = True
                        break
                if not duplicate_hue:
                    chosen_colors.append(hct.copy())
                if len(chosen_colors) >= desired:
                    break
            if len(chosen_colors) >= desired:
                break

        var colors = List[Int]()
        if len(chosen_colors) == 0:
            colors.append(fallback_color_argb)
            return colors^

        for chosen_hct in chosen_colors:
            colors.append(chosen_hct.to_int())
        return colors^
