# Build an affine rotation matrix

Returns a 2x3 affine transformation matrix for rotating by `angle`
degrees counter-clockwise around `(cx, cy)` (1-based pixel coordinates).
To compose with other transforms, embed into a 3x3 matrix with
`rbind(m, c(0, 0, 1))` before multiplying with `%*%`.

## Usage

``` r
affine_rotate(angle, cx, cy, scale = 1)
```

## Arguments

- angle:

  Numeric. Rotation angle in degrees, counter-clockwise.

- cx:

  Numeric. X coordinate of the rotation centre (1-based).

- cy:

  Numeric. Y coordinate of the rotation centre (1-based).

- scale:

  Numeric. Isotropic scale factor applied during rotation. Default `1`.

## Value

A 2x3 numeric matrix.

## See also

[`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
[`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
[`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
[`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
