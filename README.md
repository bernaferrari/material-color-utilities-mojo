# Material Color Utilities for Mojo

![Material Color Utilities Mojo](https://github.com/bernaferrari/material-color-utilities-mojo/raw/main/assets/readme.png)

A Mojo port of Google's [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/), the color science library behind Material Design 3 color extraction, HCT/CAM16, tonal palettes, dynamic schemes, contrast, scoring, and quantization.

This repository tracks the current TypeScript/Kotlin behavior rather than the older Dart snapshot this port originally started from.

## Status

- Uses Mojo `1.0.0` through `uv`.
- Ports the Material Color Utilities components used by the upstream TypeScript/Kotlin libraries.
- Includes modern dynamic color behavior for 2021, Android, 2025, and CMF 2026 schemes.
- Validated against generated TypeScript parity fixtures for the 2025 dynamic color matrix: `0` mismatches across `18,880` role outputs.
- Full local Mojo test suite passes on stable Mojo.

## Setup

Install dependencies:

```sh
uv sync
```

Check the Mojo version:

```sh
uv run mojo --version
```

Expected stable version:

```text
Mojo 1.0.0
```

## Tests

Run the full suite:

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

Format and run the full suite in one pass:

```sh
uv run mojo format $(rg --files -g '*.mojo')
uv run mojo blend_test.mojo && uv run mojo contrast_test.mojo && uv run mojo color_utils_test.mojo && uv run mojo string_utils_test.mojo && uv run mojo image_utils_test.mojo && uv run mojo theme_utils_test.mojo && uv run mojo math_utils_test.mojo && uv run mojo dislike_analyzer_test.mojo && uv run mojo hct_test.mojo && uv run mojo palettes_test.mojo && uv run mojo score_test.mojo && uv run mojo temperature_cache_test.mojo && uv run mojo quantizer_map_test.mojo && uv run mojo quantizer_wu_test.mojo && uv run mojo quantizer_wsmeans_test.mojo && uv run mojo quantizer_celebi_test.mojo && uv run mojo scheme_test.mojo && uv run mojo scheme_android_test.mojo && uv run mojo scheme_2025_test.mojo && uv run mojo scheme_cmf_test.mojo && uv run mojo scheme_dynamic_test.mojo && uv run mojo scheme_correctness_test.mojo && uv run mojo contrast_curve_test.mojo && uv run mojo dynamic_color_test.mojo
```

## Components

| Component | Purpose |
| --- | --- |
| `blend` | Harmonize, interpolate, and blend colors in HCT. |
| `contrast` | Measure contrast and find foreground tones that satisfy contrast requirements. |
| `dislike` | Detect and repair universally disliked colors. |
| `dynamiccolor` | Compute Material dynamic roles for light/dark mode, contrast levels, platforms, and spec versions. |
| `hct` | HCT color space built on CAM16 hue/chroma and Lab L* tone. |
| `palettes` | Tonal palettes and core palettes used by Material schemes. |
| `quantize` | Map, Wu, WSMeans, and Celebi quantizers for extracting representative image colors. |
| `scheme` | Static and dynamic color schemes, including Android, 2025, and CMF variants. |
| `score` | Rank extracted colors for theme suitability. |
| `temperature` | Complementary and analogous colors. |
| `utils` | Color, math, string, image, and theme helpers. |

## Parity Notes

The original Mojo port was several years behind upstream Material Color Utilities. The current codebase has been updated against the upstream TypeScript/Kotlin architecture and behavior, including:

- 2025 dynamic color role definitions.
- Phone and watch platform behavior.
- CMF 2026 dynamic schemes.
- Fixed and fixed-dim role contrast behavior.
- Modern HCT solver boundary behavior.
- TypeScript-compatible yellow T99 tonal palette averaging.

The old tracked Dart source copies are no longer part of the project. Use the upstream TypeScript/Kotlin implementations as references for future parity work.

## Benchmarks

Run the current blend benchmark:

```sh
uv run mojo benchmark_blend.mojo
```

Material Color Utilities is a useful benchmark target for Mojo because it combines scalar color science, matrix operations, iterative solvers, palette generation, quantization, and image-oriented workflows.

## Background

- [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/)
- [Material Design: The Science of Color and Design](https://material.io/blog/science-of-color-design)
- [Material color cheat sheet](https://github.com/material-foundation/material-color-utilities/raw/main/cheat_sheet.png)
