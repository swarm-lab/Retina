# Generate a structuring element kernel

Returns an integer matrix of 0s and 1s suitable for use as `kernel` in
`$morph()`.

## Usage

``` r
get_structuring_element(shape = "rect", size = 3L)
```

## Arguments

- shape:

  Character. Kernel shape: `"rect"` (all ones), `"cross"` (plus-shaped:
  centre row and column are ones, rest zeros), or `"ellipse"` (ones
  inside the inscribed ellipse, zeros outside).

- size:

  Single positive odd integer for a square kernel, or a length-2 vector
  `c(width, height)` for a non-square kernel. Both width and height must
  be positive odd integers.

## Value

An integer matrix with 0s and 1s, of dimensions `height x width`.

## Examples

``` r
get_structuring_element("cross", 5L)
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    0    0    1    0    0
#> [2,]    0    0    1    0    0
#> [3,]    1    1    1    1    1
#> [4,]    0    0    1    0    0
#> [5,]    0    0    1    0    0
get_structuring_element("ellipse", c(7L, 5L))
#>      [,1] [,2] [,3] [,4] [,5] [,6] [,7]
#> [1,]    0    0    0    1    0    0    0
#> [2,]    1    1    1    1    1    1    1
#> [3,]    1    1    1    1    1    1    1
#> [4,]    1    1    1    1    1    1    1
#> [5,]    0    0    0    1    0    0    0
```
