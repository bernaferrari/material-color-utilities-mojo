from lib.utils.math_utils import MathUtils

# A class containing the contrast curve for a dynamic color on its background.
#
# The four values correspond to contrast requirements for contrast levels
# -1.0, 0.0, 0.5, and 1.0, respectively.
struct ContrastCurve:
  var low: Float32
  var normal: Float32
  var medium: Float32
  var high: Float32

  # Creates a `ContrastCurve` object.
  #
  # [low] Contrast requirement for contrast level -1.0
  # [normal] Contrast requirement for contrast level 0.0
  # [medium] Contrast requirement for contrast level 0.5
  # [high] Contrast requirement for contrast level 1.0
  fn __init__(
    inout self,
    low: Float32,
    normal: Float32,
    medium: Float32,
    high: Float32,
  ):
    self.low = low
    self.normal = normal
    self.medium = medium
    self.high = high

  # Returns the contrast ratio at a given contrast level.
  #
  # [contrastLevel] The contrast level. 0.0 is the default (normal);
  # -1.0 is the lowest; 1.0 is the highest.
  # Returns The contrast ratio, a number between 1.0 and 21.0.
  fn getContrast(inout self, contrastLevel: Float32) -> Float32:
    if (contrastLevel <= -1.0):
      return self.low;
    elif (contrastLevel < 0.0):
      return MathUtils.lerp(self.low, self.normal, (contrastLevel - (-1)) / 1)
    elif (contrastLevel < 0.5):
      return MathUtils.lerp(self.normal, self.medium, (contrastLevel - 0) / 0.5)
    elif (contrastLevel < 1.0):
      return MathUtils.lerp(self.medium, self.high, (contrastLevel - 0.5) / 0.5)
    else:
      return self.high
