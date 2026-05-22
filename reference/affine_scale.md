# Build an affine scaling matrix

Returns a 2x3 affine transformation matrix that scales by `(fx, fy)`
around centre `(cx, cy)` (1-based pixel coordinates).

## Usage

``` r
affine_scale(fx, fy, cx = 1, cy = 1)
```

## Arguments

- fx:

  Numeric. Horizontal scale factor.

- fy:

  Numeric. Vertical scale factor.

- cx:

  Numeric. X coordinate of the scale centre (1-based). Default `1`
  (top-left; produces a pure scale with no translation).

- cy:

  Numeric. Y coordinate of the scale centre (1-based). Default `1`.

## Value

A 2x3 numeric matrix.

## See also

[`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
[`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
[`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
[`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
