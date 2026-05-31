# Material Color Utilities for Mojo

![Material Color Utilities Mojo](https://github.com/bernaferrari/material-color-utilities-mojo/raw/main/assets/readme.png)

Material Color Utilities for Mojo implements the color science behind Material Design 3: HCT/CAM16, tonal palettes, dynamic color schemes, contrast utilities, color scoring, image quantization, blending, and temperature relationships.

The implementation targets Mojo `1.0.0` and follows the behavior of the upstream [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/) TypeScript and Kotlin libraries.

## Install

```sh
uv sync
```

## Test

Run all tests:

```sh
uv run mojo blend_test.mojo
uv run mojo contrast_test.mojo
uv run mojo color_utils_test.mojo
uv run mojo string_utils_test.mojo
uv run mojo image_utils_test.mojo
uv run mojo theme_utils_test.mojo
uv run mojo math_utils_test.mojo
uv run mojo dislike_analyzer_test.mojo
uv run mojo hct_test.mojo
uv run mojo palettes_test.mojo
uv run mojo score_test.mojo
uv run mojo temperature_cache_test.mojo
uv run mojo quantizer_map_test.mojo
uv run mojo quantizer_wu_test.mojo
uv run mojo quantizer_wsmeans_test.mojo
uv run mojo quantizer_celebi_test.mojo
uv run mojo scheme_test.mojo
uv run mojo scheme_android_test.mojo
uv run mojo scheme_2025_test.mojo
uv run mojo scheme_cmf_test.mojo
uv run mojo scheme_dynamic_test.mojo
uv run mojo scheme_correctness_test.mojo
uv run mojo contrast_curve_test.mojo
uv run mojo dynamic_color_test.mojo
```

Format the code:

```sh
uv run mojo format $(rg --files -g '*.mojo')
```

## Components

| Component | Purpose |
| --- | --- |
| `blend` | Harmonization and interpolation in HCT. |
| `contrast` | Contrast ratios and foreground tone selection. |
| `dislike` | Detection and repair for disliked colors. |
| `dynamiccolor` | Dynamic Material color roles for themes, platforms, contrast levels, and spec versions. |
| `hct` | HCT color space built on CAM16 hue/chroma and Lab L* tone. |
| `palettes` | Tonal palettes and core palettes. |
| `quantize` | Map, Wu, WSMeans, and Celebi quantizers. |
| `scheme` | Static and dynamic color schemes, including Android, 2025, and CMF variants. |
| `score` | Ranking colors for theme suitability. |
| `temperature` | Complementary and analogous colors. |
| `utils` | Color, math, string, image, and theme helpers. |

## Coverage

- Material 2021 dynamic schemes.
- Android dynamic schemes.
- Material 2025 dynamic schemes.
- CMF 2026 dynamic schemes.
- Phone and watch platform behavior.
- Generated TypeScript parity fixtures for the 2025 dynamic color matrix.

## Benchmark

```sh
uv run mojo benchmark_blend.mojo
```

## Links

- [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/)
- [The Science of Color and Design](https://material.io/blog/science-of-color-design)
- [Material Color Utilities cheat sheet](https://github.com/material-foundation/material-color-utilities/raw/main/cheat_sheet.png)
