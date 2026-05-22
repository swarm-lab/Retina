# Measure the bounding box of a text string

Returns the pixel dimensions of the bounding box that would be drawn by
`$draw_text()`, without modifying any image.

## Usage

``` r
get_text_size(
  text,
  font = "simplex",
  font_size = 1,
  italic = FALSE,
  thickness = 1L
)
```

## Arguments

- text:

  Character. The string to measure.

- font:

  Character. Font face name. One of `"simplex"` (default), `"plain"`,
  `"duplex"`, `"complex"`, `"triplex"`, `"complex_small"`,
  `"script_simplex"`, `"script_complex"`.

- font_size:

  Numeric. Scale factor. Use the same value as in `$draw_text()`.
  Default `1`.

- italic:

  Logical. Use the italic variant. Default `FALSE`.

- thickness:

  Positive integer. Character stroke width. Must match the value used in
  `$draw_text()` to get accurate results. Default `1L`.

## Value

A named list: `list(width = ..., height = ..., baseline = ...)`. All
values are non-negative integers. `baseline` is the y-offset of the
baseline below the bottom of the bounding box.
