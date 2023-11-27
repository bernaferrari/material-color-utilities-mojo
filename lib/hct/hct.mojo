from lib.utils.color_utils import ColorUtils
from lib.hct.cam16 import Cam16
from lib.hct.viewing_conditions import ViewingConditions
from lib.hct.hct_solver import HctSolver

@value
struct Hct:
    var hue: Float32
    var chroma: Float32
    var tone: Float32
    var argb: Int
  
  fn __init__(inout self, hue: Float32, chroma: Float32, tone: Float32, argb: Int):
      self.hue = hue
      self.chroma = chroma
      self.tone = tone
      self.argb = argb

  @staticmethod
  fn from_hct(hue: Float32, chroma: Float32, tone: Float32) -> Hct:
      let argb = HctSolver.solve_to_int(hue, chroma, tone)
      return Self.from_int(argb)

  @staticmethod
  fn from_int(argb: Int) -> Hct:
      let cam16 = Cam16.from_int(argb)
      let hue = cam16.hue
      let chroma = cam16.chroma
      let tone = ColorUtils.lstarFromArgb(argb)
      return Hct(hue, chroma, tone, argb)

  fn to_int(hct: Hct) -> Int:
      return hct.argb

  fn get_hue(hct: Hct) -> Float32:
      return hct.hue

  fn get_tone(hct: Hct) -> Float32:
    return hct.tone

  fn set_hue(inout self: Hct, new_hue: Float32):
      self.argb = HctSolver.solve_to_int(new_hue, self.chroma, self.tone)
      let cam16 = Cam16.from_int(self.argb)
      self.hue = cam16.hue
      self.chroma = cam16.chroma
      self.tone = ColorUtils.lstarFromArgb(self.argb)

  fn get_chroma(self: Hct) -> Float32:
      return self.chroma

  fn set_chroma(inout self: Hct, new_chroma: Float32):
      self.argb = HctSolver.solve_to_int(self.hue, new_chroma, self.tone)
      let cam16 = Cam16.from_int(self.argb)
      self.hue = cam16.hue
      self.chroma = cam16.chroma
      self.tone = ColorUtils.lstarFromArgb(self.argb)

  fn set_tone(inout self: Hct, new_tone: Float32):
      self.argb = HctSolver.solve_to_int(self.hue, self.chroma, new_tone)
      let cam16 = Cam16.from_int(self.argb)
      self.hue = cam16.hue
      self.chroma = cam16.chroma
      self.tone = ColorUtils.lstarFromArgb(self.argb)

  fn in_viewing_conditions(inout self: Hct, vc: ViewingConditions) -> Hct:
      let cam16 = Cam16.from_int(self.to_int())

      let viewed_in_vc = cam16.xyz_in_viewing_conditions(vc)
      let recast_in_vc = cam16.from_xyz_in_viewing_conditions(
          viewed_in_vc[0], viewed_in_vc[1], viewed_in_vc[2], ViewingConditions.make_viewing_conditions(ColorUtils.whitePointD65)
      )
      return Self.from_hct(
          recast_in_vc.hue, recast_in_vc.chroma, ColorUtils.lstarFromY(viewed_in_vc[1])
      )
