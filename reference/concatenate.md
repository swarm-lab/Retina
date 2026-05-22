# Concatenate images side-by-side or top-to-bottom

Combines a list of images using `cv::hconcat` or `cv::vconcat`. All
images must share the same `depth`, `colorspace`, and `nchan`. For
horizontal concatenation all must have the same `nrow`; for vertical,
the same `ncol`.

## Usage

``` r
concatenate(imgs, axis = "h")
```

## Arguments

- imgs:

  A list of at least 2 `Image` objects.

- axis:

  `"h"` or `"horizontal"` for side-by-side; `"v"` or `"vertical"` for
  top-to-bottom. Default `"h"`.

## Value

A new `Image` with the colorspace of the first input image.

## Examples

``` r
# \donttest{
a <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
b <- Image$fill(128, 3L, 3L, 1L, "CV_8U", "GRAY")
concatenate(list(a, b), "h")$plot()

# }
```
