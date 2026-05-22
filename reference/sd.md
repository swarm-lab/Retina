# Standard deviation for Image objects

S3 generic extending [`sd`](https://rdrr.io/r/stats/sd.html) to support
`Image` objects. Non-Image inputs delegate to
[`stats::sd`](https://rdrr.io/r/stats/sd.html).

## Usage

``` r
sd(x, ...)

# Default S3 method
sd(x, na.rm = FALSE, ...)

# S3 method for class 'Image'
sd(x, ...)
```

## Arguments

- x:

  An `Image` object, or a numeric vector for the default method.

- ...:

  Additional arguments passed to methods.

- na.rm:

  Logical; should missing values be removed? Passed to
  [`stats::sd`](https://rdrr.io/r/stats/sd.html) for non-Image objects
  (ignored for `Image`).

## Value

For `Image` inputs, a numeric vector of per-channel standard deviations.
For other inputs, the result of [`sd`](https://rdrr.io/r/stats/sd.html).

## See also

[`sd`](https://rdrr.io/r/stats/sd.html),
[`var`](https://swarm-lab.github.io/Retina/reference/var.md)
