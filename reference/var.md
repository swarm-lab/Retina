# Variance for Image objects

S3 generic extending [`var`](https://rdrr.io/r/stats/cor.html) to
support `Image` objects. Non-Image inputs delegate to
[`stats::var`](https://rdrr.io/r/stats/cor.html).

## Usage

``` r
var(x, ...)

# Default S3 method
var(x, y = NULL, na.rm = FALSE, use, ...)

# S3 method for class 'Image'
var(x, ...)
```

## Arguments

- x:

  An `Image` object, or a numeric vector/matrix for the default method.

- ...:

  Additional arguments passed to methods.

- y:

  `NULL` or a numeric vector/matrix; passed to
  [`stats::var`](https://rdrr.io/r/stats/cor.html) for non-Image
  objects.

- na.rm:

  Logical; should missing values be removed? Passed to
  [`stats::var`](https://rdrr.io/r/stats/cor.html) for non-Image objects
  (ignored for `Image`).

- use:

  An optional character string specifying the method for computing
  covariances; passed to
  [`stats::var`](https://rdrr.io/r/stats/cor.html) for non-Image
  objects.

## Value

For `Image` inputs, a numeric vector of per-channel variances. For other
inputs, the result of [`var`](https://rdrr.io/r/stats/cor.html).

## See also

[`var`](https://rdrr.io/r/stats/cor.html),
[`sd`](https://swarm-lab.github.io/Retina/reference/sd.md)
