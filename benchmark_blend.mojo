from testing import assert_equal, assert_true
from lib.utils.color_utils import ColorUtils
from lib.blend.blend import Blend
from lib.hct.hct import Hct
from lib.utils.string_utils import StringUtils
import benchmark
from time import sleep


fn benchmarkFn():
    for x in range(0, 255):
        for y in range(0, 255):
            let colorFrom = ColorUtils.argbFromRgb(x, y, x)
            let colorTo = ColorUtils.argbFromRgb(255 - x, 255 - y, 255 - x)
            let t1 = Blend.harmonize(colorFrom, colorTo)


fn main():
    let report = benchmark.run[benchmarkFn](10)
    report.print()
