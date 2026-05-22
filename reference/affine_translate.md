# Build an affine translation matrix

Returns a 2x3 affine transformation matrix that translates by `(dx, dy)`
pixels. To compose transforms, embed into a 3x3 matrix with
`rbind(m, c(0, 0, 1))` before multiplying with `%*%`.

## Usage

``` r
affine_translate(dx, dy)
```

## Arguments

- dx:

  Numeric. Horizontal shift in pixels (positive = rightward).

- dy:

  Numeric. Vertical shift in pixels (positive = downward).

## Value

A 2x3 numeric matrix.

## See also

[`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
[`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
[`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
[`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
