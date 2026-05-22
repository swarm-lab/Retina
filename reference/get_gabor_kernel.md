# Generate a Gabor filter kernel

Returns a numeric matrix containing Gabor filter coefficients, suitable
for use as `kernel` in `$filter2D()`.

## Usage

``` r
get_gabor_kernel(
  ksize,
  sigma,
  theta,
  lambda,
  gamma,
  psi = pi/2,
  kdepth = "CV_64F"
)
```

## Arguments

- ksize:

  Length-2 integer vector `c(width, height)`. Both must be positive odd
  integers.

- sigma:

  Single positive numeric. Standard deviation of the Gaussian envelope.

- theta:

  Single numeric. Orientation of the filter normal in **degrees**
  (converted to radians internally).

- lambda:

  Single positive numeric. Wavelength of the sinusoidal component, in
  pixels.

- gamma:

  Single positive numeric. Spatial aspect ratio. Values less than 1
  produce elongated filters; `1` gives a circular envelope.

- psi:

  Single numeric. Phase offset in radians. Default `pi / 2`.

- kdepth:

  Character. Precision of the returned kernel matrix: `"CV_32F"`
  (single-precision float) or `"CV_64F"` (double-precision, default).

## Value

A numeric matrix of dimensions `height x width`.

## Examples

``` r
k <- get_gabor_kernel(c(9L, 9L), sigma = 2, theta = 0, lambda = 5, gamma = 0.5)
dim(k)
#> [1] 9 9
```
