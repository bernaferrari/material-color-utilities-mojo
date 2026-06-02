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
for file in $(find test -name '*_test.mojo' | sort); do
  uv run mojo -I . "$file" || exit 1
done
```

Run one test file:

```sh
uv run mojo -I . test/blend/blend_test.mojo
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

The implementation is covered by component-level tests across the public color utility APIs.

## Benchmark

```sh
uv run mojo benchmark_blend.mojo
```

## Links

- [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/)
- [The Science of Color and Design](https://material.io/blog/science-of-color-design)
- [Material Color Utilities cheat sheet](https://github.com/material-foundation/material-color-utilities/raw/main/cheat_sheet.png)
