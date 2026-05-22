# Split an image into its individual channels

Split an image into its individual channels

## Usage

``` r
split_channels(img)
```

## Arguments

- img:

  An `Image` object.

## Value

A named list of single-channel `Image` objects. Names are derived from
the colorspace (e.g. `c("B", "G", "R")` for BGR). Unknown colorspaces
use `"ch1"`, `"ch2"`, etc.

## Examples

``` r
# \donttest{
img <- Image$new(system.file("img", "flower.jpg", package = "Retina"))
channels <- split_channels(img)
channels$B$plot()

# }
```
