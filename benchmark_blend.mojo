from lib.utils.color_utils import ColorUtils
from lib.blend.blend import Blend
from std.benchmark import run
from std.benchmark.compiler import keep


def benchmarkFn() raises:
    for x in range(0, 255):
        for y in range(0, 255):
            var colorFrom = ColorUtils.argbFromRgb(x, y, x)
            var colorTo = ColorUtils.argbFromRgb(255 - x, 255 - y, 255 - x)
            var t1 = Blend.harmonize(colorFrom, colorTo)
            keep(t1)


def main() raises:
    var report = run[func1=benchmarkFn]()
    report.print()
