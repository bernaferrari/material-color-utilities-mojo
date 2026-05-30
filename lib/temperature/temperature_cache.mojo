import std.math as math
from std.collections import List

from lib.hct.hct import Hct
from lib.utils.color_utils import ColorUtils
from lib.utils.math_utils import MathUtils


struct TemperatureCache(Copyable, Movable):
    var input: Hct

    def __init__(out self, var input: Hct):
        self.input = input^

    @staticmethod
    def is_between(angle: Float64, a: Float64, b: Float64) -> Bool:
        if a < b:
            return a <= angle and angle <= b
        return a <= angle or angle <= b

    @staticmethod
    def raw_temperature(color: Hct) -> Float64:
        var lab = ColorUtils.labFromArgb(color.to_int())
        var hue = MathUtils.sanitizeDegreesDouble(
            math.atan2(lab[2], lab[1]) * 180.0 / math.pi
        )
        var chroma = math.sqrt((lab[1] * lab[1]) + (lab[2] * lab[2]))
        return -0.5 + 0.02 * math.pow(chroma, 1.07) * math.cos(
            MathUtils.sanitizeDegreesDouble(hue - 50.0) * math.pi / 180.0
        )

    def _hcts_by_hue(self) -> List[Hct]:
        var hcts = List[Hct]()
        for hue in range(361):
            hcts.append(
                Hct.from_hct(Float64(hue), self.input.chroma, self.input.tone)
            )
        return hcts^

    def _temp_for_hue(self, hue: Int) -> Float64:
        var hct = Hct.from_hct(Float64(hue), self.input.chroma, self.input.tone)
        return TemperatureCache.raw_temperature(hct)

    def coldest(self) -> Hct:
        var hcts = self._hcts_by_hue()
        var answer = hcts[0].copy()
        var answer_temp = TemperatureCache.raw_temperature(answer)
        for hct in hcts:
            var temp = TemperatureCache.raw_temperature(hct)
            if temp < answer_temp:
                answer_temp = temp
                answer = hct.copy()
        var input_temp = TemperatureCache.raw_temperature(self.input)
        if input_temp < answer_temp:
            return self.input.copy()
        return answer^

    def warmest(self) -> Hct:
        var hcts = self._hcts_by_hue()
        var answer = hcts[0].copy()
        var answer_temp = TemperatureCache.raw_temperature(answer)
        for hct in hcts:
            var temp = TemperatureCache.raw_temperature(hct)
            if temp > answer_temp:
                answer_temp = temp
                answer = hct.copy()
        var input_temp = TemperatureCache.raw_temperature(self.input)
        if input_temp > answer_temp:
            return self.input.copy()
        return answer^

    def relative_temperature(self, hct: Hct) -> Float64:
        var warmest_temp = TemperatureCache.raw_temperature(self.warmest())
        var coldest_temp = TemperatureCache.raw_temperature(self.coldest())
        var temp_range = warmest_temp - coldest_temp
        if temp_range == 0.0:
            return 0.5
        return (
            TemperatureCache.raw_temperature(hct) - coldest_temp
        ) / temp_range

    def input_relative_temperature(self) -> Float64:
        return self.relative_temperature(self.input)

    def complement(self) -> Hct:
        var coldest = self.coldest()
        var coldest_hue = coldest.hue
        var coldest_temp = TemperatureCache.raw_temperature(coldest)

        var warmest = self.warmest()
        var warmest_hue = warmest.hue
        var warmest_temp = TemperatureCache.raw_temperature(warmest)
        var temp_range = warmest_temp - coldest_temp
        if temp_range == 0.0:
            return self.input.copy()

        var start_hue_is_coldest_to_warmest = TemperatureCache.is_between(
            self.input.hue, coldest_hue, warmest_hue
        )
        var start_hue = (
            warmest_hue if start_hue_is_coldest_to_warmest else coldest_hue
        )
        var end_hue = (
            coldest_hue if start_hue_is_coldest_to_warmest else warmest_hue
        )

        var smallest_error = 1000.0
        var answer = Hct.from_hct(
            Float64(Int(round(self.input.hue))),
            self.input.chroma,
            self.input.tone,
        )
        var complement_relative_temp = 1.0 - self.input_relative_temperature()

        for hue_addend in range(361):
            var hue = MathUtils.sanitizeDegreesDouble(
                start_hue + Float64(hue_addend)
            )
            if not TemperatureCache.is_between(hue, start_hue, end_hue):
                continue
            var possible_answer = Hct.from_hct(
                hue, self.input.chroma, self.input.tone
            )
            var relative_temp = (
                TemperatureCache.raw_temperature(possible_answer) - coldest_temp
            ) / temp_range
            var error = math.abs(complement_relative_temp - relative_temp)
            if error < smallest_error:
                smallest_error = error
                answer = possible_answer^
        return answer^

    def analogous(self, count: Int = 5, divisions: Int = 12) -> List[Hct]:
        var hcts_by_hue = self._hcts_by_hue()
        var start_hue = Int(round(self.input.hue))
        var start_hct = hcts_by_hue[start_hue].copy()
        var last_temp = self.relative_temperature(start_hct)
        var all_colors = List[Hct]()
        all_colors.append(start_hct.copy())

        var absolute_total_temp_delta = 0.0
        for i in range(360):
            var hue = MathUtils.sanitizeDegreesInt(start_hue + i)
            var hct = hcts_by_hue[hue].copy()
            var temp = self.relative_temperature(hct)
            var temp_delta = math.abs(temp - last_temp)
            last_temp = temp
            absolute_total_temp_delta += temp_delta

        var hue_addend = 1
        var temp_step = absolute_total_temp_delta / Float64(divisions)
        var total_temp_delta = 0.0
        last_temp = self.relative_temperature(start_hct)
        while len(all_colors) < divisions:
            var hue = MathUtils.sanitizeDegreesInt(start_hue + hue_addend)
            var hct = hcts_by_hue[hue].copy()
            var temp = self.relative_temperature(hct)
            var temp_delta = math.abs(temp - last_temp)
            total_temp_delta += temp_delta

            var desired_total_temp_delta_for_index = (
                Float64(len(all_colors)) * temp_step
            )
            var index_satisfied = (
                total_temp_delta >= desired_total_temp_delta_for_index
            )
            var index_addend = 1
            while index_satisfied and len(all_colors) < divisions:
                all_colors.append(hct.copy())
                desired_total_temp_delta_for_index = (
                    Float64(len(all_colors) + index_addend) * temp_step
                )
                index_satisfied = (
                    total_temp_delta >= desired_total_temp_delta_for_index
                )
                index_addend += 1

            last_temp = temp
            hue_addend += 1
            if hue_addend > 360:
                while len(all_colors) < divisions:
                    all_colors.append(hct.copy())
                break

        var answers = List[Hct]()
        answers.append(self.input.copy())

        var increase_hue_count = (count - 1) // 2
        for i in range(1, increase_hue_count + 1):
            var index = 0 - i
            while index < 0:
                index = len(all_colors) + index
            if index >= len(all_colors):
                index = index % len(all_colors)
            answers.insert(0, all_colors[index].copy())

        var decrease_hue_count = count - increase_hue_count - 1
        for i in range(1, decrease_hue_count + 1):
            var index = i
            while index < 0:
                index = len(all_colors) + index
            if index >= len(all_colors):
                index = index % len(all_colors)
            answers.append(all_colors[index].copy())

        return answers^
