# Compute an affine transformation matrix from point correspondences

Computes the 2x3 affine transformation matrix that maps `src` points to
`dst` points. Requires exactly 3 point pairs.

## Usage

``` r
affine_from_points(src, dst)
```

## Arguments

- src:

  A 3x2 numeric matrix of source points. Column 1 = x, column 2 = y
  (1-based pixel coordinates).

- dst:

  A 3x2 numeric matrix of destination points. Same convention as `src`.

## Value

A 2x3 numeric matrix.

## See also

[`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
[`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
[`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
[`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
