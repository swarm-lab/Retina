# Compute a perspective transformation matrix from point correspondences

Computes the 3x3 perspective (homography) matrix that maps `src` points
to `dst` points. Requires exactly 4 point pairs.

## Usage

``` r
perspective_from_points(src, dst)
```

## Arguments

- src:

  A 4x2 numeric matrix of source points. Column 1 = x, column 2 = y
  (1-based pixel coordinates).

- dst:

  A 4x2 numeric matrix of destination points. Same convention as `src`.

## Value

A 3x3 numeric matrix.

## See also

[`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
[`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
