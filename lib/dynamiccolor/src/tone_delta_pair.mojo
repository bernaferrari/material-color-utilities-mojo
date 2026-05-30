struct TonePolarity:
    comptime darker = 0
    comptime lighter = 1
    comptime nearer = 2
    comptime farther = 3


struct ToneDeltaPair(Copyable, Movable):
    var role_a: Int
    var role_b: Int
    var delta: Float64
    var polarity: Int
    var stay_together: Bool

    def __init__(
        out self,
        role_a: Int,
        role_b: Int,
        delta: Float64,
        polarity: Int,
        stay_together: Bool,
    ):
        self.role_a = role_a
        self.role_b = role_b
        self.delta = delta
        self.polarity = polarity
        self.stay_together = stay_together
