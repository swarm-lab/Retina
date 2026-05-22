# Convert an R color to a BGR(A) numeric vector

Mirrors the interface of
[`col2rgb`](https://rdrr.io/r/grDevices/col2rgb.html): accepts any R
color name or hex string, plus a pre-formed numeric BGR or BGRA vector.

## Usage

``` r
col2bgr(color, alpha = FALSE)
```

## Arguments

- color:

  An R color name (e.g., `"red"`), a hex string (e.g., `"#FF0000"`), or
  a numeric vector of length 3 (BGR) or 4 (BGRA) with values in \[0,
  255\].

- alpha:

  Logical. When `TRUE`, include the alpha channel (output is BGRA).
  Applies only to string/hex input; numeric vectors are returned as-is
  regardless of this flag. Default `FALSE`.

## Value

A named numeric vector `c(B = ..., G = ..., R = ...)` when
`alpha = FALSE`, or `c(B = ..., G = ..., R = ..., A = ...)` when
`alpha = TRUE`.
