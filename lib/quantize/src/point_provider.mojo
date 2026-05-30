from std.utils import StaticTuple


trait PointProvider:
    def from_int(self, argb: Int) -> StaticTuple[Float64, 3]:
        ...

    def to_int(self, point: StaticTuple[Float64, 3]) -> Int:
        ...

    def distance(
        self, one: StaticTuple[Float64, 3], two: StaticTuple[Float64, 3]
    ) -> Float64:
        ...
