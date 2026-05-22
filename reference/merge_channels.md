# Merge a list of single-channel images into a multi-channel image

Merge a list of single-channel images into a multi-channel image

## Usage

``` r
merge_channels(channels)
```

## Arguments

- channels:

  A named list of single-channel `Image` objects with equal dimensions
  and depth. Names are used to infer the output colorspace.

## Value

A new `Image`. Colorspace is inferred from `names(channels)`; if
unrecognised, colorspace is set to `"UNKNOWN"` with a warning.

## Examples

``` r
# \donttest{
img <- Image$new(system.file("img", "flower.jpg", package = "Retina"))
channels <- split_channels(img)
reconstructed <- merge_channels(channels)
reconstructed$plot()

# }
```
