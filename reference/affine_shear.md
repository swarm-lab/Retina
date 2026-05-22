# Build an affine shear matrix

Returns a 2x3 affine transformation matrix that applies a simultaneous
horizontal shear (controlled by `sx`) and vertical shear (controlled by
`sy`). `sx` shifts columns in the x direction proportionally to their y
position; `sy` shifts rows in the y direction proportionally to their x
position. Use zero for either to apply a single-axis shear.

## Usage

``` r
affine_shear(sx, sy)
```

## Arguments

- sx:

  Numeric. Horizontal shear factor.

- sy:

  Numeric. Vertical shear factor.

## Value

A 2x3 numeric matrix.

## See also

[`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
[`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
[`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
[`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md),
[`Image`](https://swarm-lab.github.io/Retina/reference/Image.md)
