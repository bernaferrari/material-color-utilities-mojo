from std.collections import Dict, List
from std.utils import StaticTuple

from lib.quantize.quantizer import QuantizerResult
from lib.quantize.src.point_provider_lab import PointProviderLab


struct QuantizerWsmeans:
    @staticmethod
    def _contains_argb(colors: List[Int], argb: Int) -> Bool:
        for color in colors:
            if color == argb:
                return True
        return False

    @staticmethod
    def _contains_index(indices: List[Int], index: Int) -> Bool:
        for item in indices:
            if item == index:
                return True
        return False

    @staticmethod
    def quantize(
        pixels: List[Int], starting_clusters: List[Int], max_colors: Int
    ) -> QuantizerResult:
        var pixel_to_count = Dict[Int, Int]()
        var points = List[StaticTuple[Float64, 3]]()
        var input_pixels = List[Int]()
        var counts = List[Int]()
        for pixel in pixels:
            var previous_count = pixel_to_count.get(pixel, 0)
            pixel_to_count[pixel] = previous_count + 1
            if previous_count == 0:
                input_pixels.append(pixel)
                points.append(PointProviderLab.from_int(pixel))
                counts.append(1)
            else:
                for i in range(len(input_pixels)):
                    if input_pixels[i] == pixel:
                        counts[i] = previous_count + 1
                        break

        var point_count = len(points)
        if point_count == 0 or max_colors <= 0:
            return QuantizerResult(Dict[Int, Int]())

        var cluster_count = max_colors
        if cluster_count > point_count:
            cluster_count = point_count

        var clusters = List[StaticTuple[Float64, 3]]()
        for color in starting_clusters:
            if len(clusters) >= cluster_count:
                break
            clusters.append(PointProviderLab.from_int(color))

        var additional_clusters_needed = cluster_count - len(clusters)
        var additional_indices = List[Int]()
        var point_index = 0
        while (
            len(additional_indices) < additional_clusters_needed
            and point_index < point_count
        ):
            var argb = input_pixels[point_index]
            if not QuantizerWsmeans._contains_argb(
                starting_clusters, argb
            ) and not QuantizerWsmeans._contains_index(
                additional_indices, point_index
            ):
                clusters.append(points[point_index])
                additional_indices.append(point_index)
            point_index += 1

        var cluster_indices = List[Int]()
        for i in range(point_count):
            cluster_indices.append(i % cluster_count)

        var cluster_distances = List[Float64]()
        cluster_distances.resize(cluster_count * cluster_count, 0.0)

        var pixel_count_sums = List[Int]()
        pixel_count_sums.resize(cluster_count, 0)
        var max_iterations = 5
        for iteration in range(max_iterations):
            for i in range(cluster_count):
                for j in range(i + 1, cluster_count):
                    var distance = PointProviderLab.distance(
                        clusters[i], clusters[j]
                    )
                    cluster_distances[i * cluster_count + j] = distance
                    cluster_distances[j * cluster_count + i] = distance

            var points_moved = 0
            for i in range(point_count):
                var previous_cluster_index = cluster_indices[i]
                var previous_distance = PointProviderLab.distance(
                    points[i], clusters[previous_cluster_index]
                )
                var minimum_distance = previous_distance
                var new_cluster_index = -1
                for j in range(cluster_count):
                    if (
                        cluster_distances[
                            previous_cluster_index * cluster_count + j
                        ]
                        >= 4.0 * previous_distance
                    ):
                        continue
                    var distance = PointProviderLab.distance(
                        points[i], clusters[j]
                    )
                    if distance < minimum_distance:
                        minimum_distance = distance
                        new_cluster_index = j
                if new_cluster_index != -1:
                    points_moved += 1
                    cluster_indices[i] = new_cluster_index

            if points_moved == 0 and iteration > 0:
                break

            var component_l_sums = List[Float64]()
            var component_a_sums = List[Float64]()
            var component_b_sums = List[Float64]()
            component_l_sums.resize(cluster_count, 0.0)
            component_a_sums.resize(cluster_count, 0.0)
            component_b_sums.resize(cluster_count, 0.0)
            for i in range(cluster_count):
                pixel_count_sums[i] = 0

            for i in range(point_count):
                var cluster_index = cluster_indices[i]
                var count = counts[i]
                pixel_count_sums[cluster_index] += count
                component_l_sums[cluster_index] += points[i][0] * Float64(count)
                component_a_sums[cluster_index] += points[i][1] * Float64(count)
                component_b_sums[cluster_index] += points[i][2] * Float64(count)

            for i in range(cluster_count):
                var count = pixel_count_sums[i]
                if count == 0:
                    clusters[i] = StaticTuple[Float64, 3](0.0, 0.0, 0.0)
                    continue
                var count_float = Float64(count)
                clusters[i] = StaticTuple[Float64, 3](
                    component_l_sums[i] / count_float,
                    component_a_sums[i] / count_float,
                    component_b_sums[i] / count_float,
                )

        var cluster_argbs = List[Int]()
        var cluster_populations = List[Int]()
        for i in range(cluster_count):
            var count = pixel_count_sums[i]
            if count == 0:
                continue
            var cluster_argb = PointProviderLab.to_int(clusters[i])
            if QuantizerWsmeans._contains_argb(cluster_argbs, cluster_argb):
                continue
            cluster_argbs.append(cluster_argb)
            cluster_populations.append(count)

        var color_to_count = Dict[Int, Int]()
        var input_to_cluster = Dict[Int, Int]()
        for i in range(len(cluster_argbs)):
            color_to_count[cluster_argbs[i]] = cluster_populations[i]

        for i in range(point_count):
            var cluster_index = cluster_indices[i]
            input_to_cluster[input_pixels[i]] = PointProviderLab.to_int(
                clusters[cluster_index]
            )

        return QuantizerResult(color_to_count^, input_to_cluster^)
