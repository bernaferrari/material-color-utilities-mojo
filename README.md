# Material Color Utilities Mojo

![Image of Material Color Utilities Mojo](https://github.com/bernaferrari/material-color-utilities-mojo/raw/main/assets/readme.png)

Mojo port of the [Material Color Utilities](https://github.com/material-foundation/material-color-utilities/).

## Setup

This project is pinned to stable Mojo `1.0.0b1` using `uv`, matching the
current stable install path from the Mojo install docs:

```sh
uv sync
uv run mojo blend_test.mojo
uv run mojo contrast_test.mojo
uv run mojo color_utils_test.mojo
uv run mojo string_utils_test.mojo
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
uv run mojo scheme_dynamic_test.mojo
uv run mojo scheme_correctness_test.mojo
uv run mojo contrast_curve_test.mojo
uv run mojo dynamic_color_test.mojo
```

Implemented components:

- ✅ blend

- ✅ contrast

- ✅ dislike

- ✅ dynamic color

- ✅ hct

- ✅ palettes

- ✅ quantize

- ✅ scheme

- ✅ score

- ✅ temperature

- ✅ utilities

- ✅ tests for blend, contrast, utilities, dislike, hct, palettes, score, temperature, quantize, dynamic color, and scheme

The old tracked Dart source copies have been replaced with Mojo modules. As
Mojo evolves, it will be useful to evaluate `Tensor` or SIMD-backed helpers for
the remaining matrix operations and optimize quantization for parallelization.

Material Color Utilities is a fun project. It has implementation in 4 languages (Dart, C++, Swift and TypeScript), they are all tested, and it has periodical usage of matrix operations. It is a great candidate for benchmarking how fast Mojo is.

Use `uv run mojo benchmark_blend.mojo` for the current blend benchmark.

--- Original README:

Algorithms and utilities that power the Material Design 3 (M3) color system,
including choosing theme colors from images and creating tones of colors; all in a new color space.

## Usage

### Cheat sheet

<a href="https://github.com/material-foundation/material-color-utilities/raw/main/cheat_sheet.png">
    <img alt="library cheat sheet" src="https://github.com/material-foundation/material-color-utilities/raw/main/cheat_sheet.png" style="max-width:640px;" />
</a>

### Components

The library is composed of multiple components, each with its own folder and
tests, each as small as possible.

This enables easy merging and updating of subsets into other libraries, such as
Material Design Components, Android System UI, etc. Not all consumers will need
every component — ex. MDC doesn’t need quantization/scoring/image extraction.

| Components       | Purpose                                                                                                                                                                                             |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **blend**        | Interpolate, harmonize, animate, and gradate colors in HCT                                                                                                                                          |
| **contrast**     | Measure contrast, obtain contrastful colors                                                                                                                                                         |
| **dislike**      | Check and fix universally disliked colors                                                                                                                                                           |
| **dynamiccolor** | Obtain colors that adjust based on UI state (dark theme, style, preferences, contrast requirements, etc.)                                                                                           |
| **hct**          | A new color space (hue, chrome, tone) based on CAM16 x L\*, that accounts for viewing conditions                                                                                                    |
| **palettes**     | Tonal palette — range of colors that varies only in tone <br>Core palette — set of tonal palettes needed to create Material color schemes                                                           |
| **quantize**     | Turn an image into N colors; composed of Celebi, which runs Wu, then WSMeans                                                                                                                        |
| **scheme**       | Create static and dynamic color schemes from a single color or a core palette                                                                                                                       |
| **score**        | Rank colors for suitability for theming                                                                                                                                                             |
| **temperature**  | Obtain analogous and complementary colors                                                                                                                                                           |
| **utilities**    | Color — convert between color spaces needed to implement HCT/CAM16 <br>Math — functions for ex. ensuring hue is between 0 and 360, clamping, etc. <br>String - convert between strings and integers |

## Background

[The Science of Color & Design - Material Design](https://material.io/blog/science-of-color-design)
