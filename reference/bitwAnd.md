# Bitwise operations for Image objects

S3 generics extending [`bitwAnd`](https://rdrr.io/r/base/bitwise.html),
[`bitwOr`](https://rdrr.io/r/base/bitwise.html),
[`bitwXor`](https://rdrr.io/r/base/bitwise.html), and
[`bitwNot`](https://rdrr.io/r/base/bitwise.html) to support `Image`
objects. Non-Image inputs delegate to the corresponding `base` function.

## Usage

``` r
bitwAnd(x, y, ...)

# Default S3 method
bitwAnd(x, y, ...)

# S3 method for class 'Image'
bitwAnd(x, y, ...)

bitwOr(x, y, ...)

# Default S3 method
bitwOr(x, y, ...)

# S3 method for class 'Image'
bitwOr(x, y, ...)

bitwXor(x, y, ...)

# Default S3 method
bitwXor(x, y, ...)

# S3 method for class 'Image'
bitwXor(x, y, ...)

bitwNot(x, ...)

# Default S3 method
bitwNot(x, ...)

# S3 method for class 'Image'
bitwNot(x, ...)
```

## Arguments

- x:

  An `Image` object, or an integer vector for the default methods.

- y:

  An `Image` object, scalar, or integer vector (`bitwAnd`, `bitwOr`,
  `bitwXor` only).

- ...:

  Additional arguments (ignored for `Image` objects).

## Value

For `Image` inputs, a new `Image` with the element-wise bitwise result.
For other inputs, delegates to the corresponding
[`bitwAnd`](https://rdrr.io/r/base/bitwise.html) family function.

## See also

[`bitwAnd`](https://rdrr.io/r/base/bitwise.html)
