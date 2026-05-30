from std.collections import Dict


struct QuantizerResult(Movable):
    var color_to_count: Dict[Int, Int]
    var input_pixel_to_cluster_pixel: Dict[Int, Int]

    def __init__(
        out self,
        var color_to_count: Dict[Int, Int],
        var input_pixel_to_cluster_pixel: Dict[Int, Int] = Dict[Int, Int](),
    ):
        self.color_to_count = color_to_count^
        self.input_pixel_to_cluster_pixel = input_pixel_to_cluster_pixel^
