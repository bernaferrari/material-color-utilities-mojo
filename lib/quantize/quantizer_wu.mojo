from std.collections import Dict, List
from std.math import round

from lib.quantize.quantizer import QuantizerResult
from lib.quantize.quantizer_map import QuantizerMap
from lib.utils.color_utils import ColorUtils


struct _Direction:
    comptime red = 0
    comptime green = 1
    comptime blue = 2


struct Box(Copyable, Movable):
    var r0: Int
    var r1: Int
    var g0: Int
    var g1: Int
    var b0: Int
    var b1: Int
    var vol: Int

    def __init__(
        out self,
        r0: Int = 0,
        r1: Int = 0,
        g0: Int = 0,
        g1: Int = 0,
        b0: Int = 0,
        b1: Int = 0,
        vol: Int = 0,
    ):
        self.r0 = r0
        self.r1 = r1
        self.g0 = g0
        self.g1 = g1
        self.b0 = b0
        self.b1 = b1
        self.vol = vol


struct _MaximizeResult(Copyable, Movable):
    var cut_location: Int
    var maximum: Float64

    def __init__(out self, cut_location: Int, maximum: Float64):
        self.cut_location = cut_location
        self.maximum = maximum


struct _CreateBoxesResult(Copyable, Movable):
    var requested_count: Int
    var result_count: Int

    def __init__(out self, requested_count: Int, result_count: Int):
        self.requested_count = requested_count
        self.result_count = result_count


struct _CutResult(Copyable, Movable):
    var did_cut: Bool
    var one: Box
    var two: Box

    def __init__(out self, did_cut: Bool, one: Box, two: Box):
        self.did_cut = did_cut
        self.one = one.copy()
        self.two = two.copy()


struct QuantizerWu(Movable):
    comptime index_bits = 5
    comptime max_index = 32
    comptime side_length = 33
    comptime total_size = 35937

    var weights: List[Int]
    var moments_r: List[Int]
    var moments_g: List[Int]
    var moments_b: List[Int]
    var moments: List[Float64]
    var cubes: List[Box]

    def __init__(out self):
        self.weights = List[Int]()
        self.moments_r = List[Int]()
        self.moments_g = List[Int]()
        self.moments_b = List[Int]()
        self.moments = List[Float64]()
        self.cubes = List[Box]()

    @staticmethod
    def get_index(r: Int, g: Int, b: Int) -> Int:
        return (
            (r << (QuantizerWu.index_bits * 2))
            + (r << (QuantizerWu.index_bits + 1))
            + (g << QuantizerWu.index_bits)
            + r
            + g
            + b
        )

    @staticmethod
    def quantize(pixels: List[Int], max_colors: Int) -> QuantizerResult:
        var quantizer = QuantizerWu()
        return quantizer._quantize(pixels, max_colors)

    def _quantize(
        mut self, pixels: List[Int], max_colors: Int
    ) -> QuantizerResult:
        if max_colors <= 0:
            return QuantizerResult(Dict[Int, Int]())

        var result = QuantizerMap.quantize(pixels, max_colors)
        self.construct_histogram(result.color_to_count)
        self.compute_moments()
        var create_boxes_result = self.create_boxes(max_colors)
        var colors = self.create_result(create_boxes_result.result_count)

        var color_to_count = Dict[Int, Int]()
        for color in colors:
            color_to_count[color] = 0
        return QuantizerResult(color_to_count^)

    def construct_histogram(mut self, pixels: Dict[Int, Int]):
        self.weights = List[Int]()
        self.moments_r = List[Int]()
        self.moments_g = List[Int]()
        self.moments_b = List[Int]()
        self.moments = List[Float64]()
        self.weights.resize(QuantizerWu.total_size, 0)
        self.moments_r.resize(QuantizerWu.total_size, 0)
        self.moments_g.resize(QuantizerWu.total_size, 0)
        self.moments_b.resize(QuantizerWu.total_size, 0)
        self.moments.resize(QuantizerWu.total_size, 0.0)

        for item in pixels.items():
            var pixel = item.key
            var count = item.value
            var red = ColorUtils.redFromArgb(pixel)
            var green = ColorUtils.greenFromArgb(pixel)
            var blue = ColorUtils.blueFromArgb(pixel)
            var bits_to_remove = 8 - QuantizerWu.index_bits
            var i_r = (red >> bits_to_remove) + 1
            var i_g = (green >> bits_to_remove) + 1
            var i_b = (blue >> bits_to_remove) + 1
            var index = QuantizerWu.get_index(i_r, i_g, i_b)
            self.weights[index] += count
            self.moments_r[index] += red * count
            self.moments_g[index] += green * count
            self.moments_b[index] += blue * count
            self.moments[index] += Float64(
                count * (red * red + green * green + blue * blue)
            )

    def compute_moments(mut self):
        for r in range(1, QuantizerWu.side_length):
            var area = List[Int]()
            var area_r = List[Int]()
            var area_g = List[Int]()
            var area_b = List[Int]()
            var area_2 = List[Float64]()
            area.resize(QuantizerWu.side_length, 0)
            area_r.resize(QuantizerWu.side_length, 0)
            area_g.resize(QuantizerWu.side_length, 0)
            area_b.resize(QuantizerWu.side_length, 0)
            area_2.resize(QuantizerWu.side_length, 0.0)

            for g in range(1, QuantizerWu.side_length):
                var line = 0
                var line_r = 0
                var line_g = 0
                var line_b = 0
                var line_2 = 0.0

                for b in range(1, QuantizerWu.side_length):
                    var index = QuantizerWu.get_index(r, g, b)
                    line += self.weights[index]
                    line_r += self.moments_r[index]
                    line_g += self.moments_g[index]
                    line_b += self.moments_b[index]
                    line_2 += self.moments[index]

                    area[b] += line
                    area_r[b] += line_r
                    area_g[b] += line_g
                    area_b[b] += line_b
                    area_2[b] += line_2

                    var previous_index = QuantizerWu.get_index(r - 1, g, b)
                    self.weights[index] = self.weights[previous_index] + area[b]
                    self.moments_r[index] = (
                        self.moments_r[previous_index] + area_r[b]
                    )
                    self.moments_g[index] = (
                        self.moments_g[previous_index] + area_g[b]
                    )
                    self.moments_b[index] = (
                        self.moments_b[previous_index] + area_b[b]
                    )
                    self.moments[index] = (
                        self.moments[previous_index] + area_2[b]
                    )

    def create_boxes(mut self, max_color_count: Int) -> _CreateBoxesResult:
        self.cubes = List[Box]()
        for _ in range(max_color_count):
            self.cubes.append(Box())
        self.cubes[0] = Box(
            0,
            QuantizerWu.max_index,
            0,
            QuantizerWu.max_index,
            0,
            QuantizerWu.max_index,
            0,
        )

        var volume_variance = List[Float64]()
        volume_variance.resize(max_color_count, 0.0)
        var next = 0
        var generated_color_count = max_color_count
        var i = 1
        while i < max_color_count:
            var cut_result = self.cut(self.cubes[next], self.cubes[i])
            if cut_result.did_cut:
                self.cubes[next] = cut_result.one.copy()
                self.cubes[i] = cut_result.two.copy()
                volume_variance[next] = (
                    self.variance(self.cubes[next]) if self.cubes[next].vol
                    > 1 else 0.0
                )
                volume_variance[i] = (
                    self.variance(self.cubes[i]) if self.cubes[i].vol
                    > 1 else 0.0
                )
            else:
                volume_variance[next] = 0.0
                i -= 1

            next = 0
            var temp = volume_variance[0]
            for j in range(1, i + 1):
                if volume_variance[j] > temp:
                    temp = volume_variance[j]
                    next = j
            if temp <= 0.0:
                generated_color_count = i + 1
                break
            i += 1

        return _CreateBoxesResult(max_color_count, generated_color_count)

    def create_result(self, color_count: Int) -> List[Int]:
        var colors = List[Int]()
        for i in range(color_count):
            var cube = self.cubes[i].copy()
            var weight = QuantizerWu.volume_int(cube, self.weights)
            if weight > 0:
                var r = Int(
                    round(
                        Float64(QuantizerWu.volume_int(cube, self.moments_r))
                        / Float64(weight)
                    )
                )
                var g = Int(
                    round(
                        Float64(QuantizerWu.volume_int(cube, self.moments_g))
                        / Float64(weight)
                    )
                )
                var b = Int(
                    round(
                        Float64(QuantizerWu.volume_int(cube, self.moments_b))
                        / Float64(weight)
                    )
                )
                colors.append(ColorUtils.argbFromRgb(r, g, b))
        return colors^

    def variance(self, cube: Box) -> Float64:
        var d_r = QuantizerWu.volume_int(cube, self.moments_r)
        var d_g = QuantizerWu.volume_int(cube, self.moments_g)
        var d_b = QuantizerWu.volume_int(cube, self.moments_b)
        var xx = QuantizerWu.volume_float(cube, self.moments)
        var hypotenuse = Float64(d_r * d_r + d_g * d_g + d_b * d_b)
        var cube_volume = QuantizerWu.volume_int(cube, self.weights)
        if cube_volume == 0:
            return 0.0
        return xx - hypotenuse / Float64(cube_volume)

    def cut(self, one: Box, two: Box) -> _CutResult:
        var cut_one = one.copy()
        var cut_two = two.copy()
        var whole_r = QuantizerWu.volume_int(cut_one, self.moments_r)
        var whole_g = QuantizerWu.volume_int(cut_one, self.moments_g)
        var whole_b = QuantizerWu.volume_int(cut_one, self.moments_b)
        var whole_w = QuantizerWu.volume_int(cut_one, self.weights)

        var max_r_result = self.maximize(
            cut_one,
            _Direction.red,
            cut_one.r0 + 1,
            cut_one.r1,
            whole_r,
            whole_g,
            whole_b,
            whole_w,
        )
        var max_g_result = self.maximize(
            cut_one,
            _Direction.green,
            cut_one.g0 + 1,
            cut_one.g1,
            whole_r,
            whole_g,
            whole_b,
            whole_w,
        )
        var max_b_result = self.maximize(
            cut_one,
            _Direction.blue,
            cut_one.b0 + 1,
            cut_one.b1,
            whole_r,
            whole_g,
            whole_b,
            whole_w,
        )

        var cut_direction: Int
        var max_r = max_r_result.maximum
        var max_g = max_g_result.maximum
        var max_b = max_b_result.maximum
        if max_r >= max_g and max_r >= max_b:
            cut_direction = _Direction.red
            if max_r_result.cut_location < 0:
                return _CutResult(False, cut_one, cut_two)
        elif max_g >= max_r and max_g >= max_b:
            cut_direction = _Direction.green
            if max_g_result.cut_location < 0:
                return _CutResult(False, cut_one, cut_two)
        else:
            cut_direction = _Direction.blue
            if max_b_result.cut_location < 0:
                return _CutResult(False, cut_one, cut_two)

        cut_two.r1 = cut_one.r1
        cut_two.g1 = cut_one.g1
        cut_two.b1 = cut_one.b1

        if cut_direction == _Direction.red:
            cut_one.r1 = max_r_result.cut_location
            cut_two.r0 = cut_one.r1
            cut_two.g0 = cut_one.g0
            cut_two.b0 = cut_one.b0
        elif cut_direction == _Direction.green:
            cut_one.g1 = max_g_result.cut_location
            cut_two.r0 = cut_one.r0
            cut_two.g0 = cut_one.g1
            cut_two.b0 = cut_one.b0
        else:
            cut_one.b1 = max_b_result.cut_location
            cut_two.r0 = cut_one.r0
            cut_two.g0 = cut_one.g0
            cut_two.b0 = cut_one.b1

        cut_one.vol = (
            (cut_one.r1 - cut_one.r0)
            * (cut_one.g1 - cut_one.g0)
            * (cut_one.b1 - cut_one.b0)
        )
        cut_two.vol = (
            (cut_two.r1 - cut_two.r0)
            * (cut_two.g1 - cut_two.g0)
            * (cut_two.b1 - cut_two.b0)
        )
        return _CutResult(True, cut_one, cut_two)

    def maximize(
        self,
        cube: Box,
        direction: Int,
        first: Int,
        last: Int,
        whole_r: Int,
        whole_g: Int,
        whole_b: Int,
        whole_w: Int,
    ) -> _MaximizeResult:
        var bottom_r = QuantizerWu.bottom(cube, direction, self.moments_r)
        var bottom_g = QuantizerWu.bottom(cube, direction, self.moments_g)
        var bottom_b = QuantizerWu.bottom(cube, direction, self.moments_b)
        var bottom_w = QuantizerWu.bottom(cube, direction, self.weights)

        var maximum = 0.0
        var cut = -1
        for i in range(first, last):
            var half_r = bottom_r + QuantizerWu.top(
                cube, direction, i, self.moments_r
            )
            var half_g = bottom_g + QuantizerWu.top(
                cube, direction, i, self.moments_g
            )
            var half_b = bottom_b + QuantizerWu.top(
                cube, direction, i, self.moments_b
            )
            var half_w = bottom_w + QuantizerWu.top(
                cube, direction, i, self.weights
            )

            if half_w == 0:
                continue

            var temp = Float64(
                half_r * half_r + half_g * half_g + half_b * half_b
            ) / Float64(half_w)

            half_r = whole_r - half_r
            half_g = whole_g - half_g
            half_b = whole_b - half_b
            half_w = whole_w - half_w
            if half_w == 0:
                continue

            temp += Float64(
                half_r * half_r + half_g * half_g + half_b * half_b
            ) / Float64(half_w)
            if temp > maximum:
                maximum = temp
                cut = i

        return _MaximizeResult(cut, maximum)

    @staticmethod
    def volume_int(cube: Box, moment: List[Int]) -> Int:
        return (
            moment[QuantizerWu.get_index(cube.r1, cube.g1, cube.b1)]
            - moment[QuantizerWu.get_index(cube.r1, cube.g1, cube.b0)]
            - moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b1)]
            + moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b0)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b1)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b0)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b1)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b0)]
        )

    @staticmethod
    def volume_float(cube: Box, moment: List[Float64]) -> Float64:
        return (
            moment[QuantizerWu.get_index(cube.r1, cube.g1, cube.b1)]
            - moment[QuantizerWu.get_index(cube.r1, cube.g1, cube.b0)]
            - moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b1)]
            + moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b0)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b1)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b0)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b1)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b0)]
        )

    @staticmethod
    def bottom(cube: Box, direction: Int, moment: List[Int]) -> Int:
        if direction == _Direction.red:
            return (
                -moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b1)]
                + moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b0)]
                + moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b1)]
                - moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b0)]
            )
        if direction == _Direction.green:
            return (
                -moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b1)]
                + moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b0)]
                + moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b1)]
                - moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b0)]
            )
        return (
            -moment[QuantizerWu.get_index(cube.r1, cube.g1, cube.b0)]
            + moment[QuantizerWu.get_index(cube.r1, cube.g0, cube.b0)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g1, cube.b0)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g0, cube.b0)]
        )

    @staticmethod
    def top(cube: Box, direction: Int, position: Int, moment: List[Int]) -> Int:
        if direction == _Direction.red:
            return (
                moment[QuantizerWu.get_index(position, cube.g1, cube.b1)]
                - moment[QuantizerWu.get_index(position, cube.g1, cube.b0)]
                - moment[QuantizerWu.get_index(position, cube.g0, cube.b1)]
                + moment[QuantizerWu.get_index(position, cube.g0, cube.b0)]
            )
        if direction == _Direction.green:
            return (
                moment[QuantizerWu.get_index(cube.r1, position, cube.b1)]
                - moment[QuantizerWu.get_index(cube.r1, position, cube.b0)]
                - moment[QuantizerWu.get_index(cube.r0, position, cube.b1)]
                + moment[QuantizerWu.get_index(cube.r0, position, cube.b0)]
            )
        return (
            moment[QuantizerWu.get_index(cube.r1, cube.g1, position)]
            - moment[QuantizerWu.get_index(cube.r1, cube.g0, position)]
            - moment[QuantizerWu.get_index(cube.r0, cube.g1, position)]
            + moment[QuantizerWu.get_index(cube.r0, cube.g0, position)]
        )
