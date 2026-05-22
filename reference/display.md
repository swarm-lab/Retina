# Display an image using R's graphics device

Wraps [`dev.hold()`](https://rdrr.io/r/grDevices/dev.flush.html) /
[`dev.flush()`](https://rdrr.io/r/grDevices/dev.flush.html) for use in
capture loops. Typical frame rate is 15–25 fps for moderate image sizes.

## Usage

``` r
display(img, ...)
```

## Arguments

- img:

  An `Image` object.

- ...:

  Additional arguments passed to `img$plot()`.

## Value

`NULL` invisibly.
