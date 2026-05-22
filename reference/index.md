# Package index

## Image class

The core R6 class for image data.

- [`Image`](https://swarm-lab.github.io/Retina/reference/Image.md) :
  Image class

## Color utilities

Convert R color specifications to OpenCV BGR(A) format.

- [`col2bgr()`](https://swarm-lab.github.io/Retina/reference/col2bgr.md)
  : Convert an R color to a BGR(A) numeric vector

## Channel operations

Split and merge image channels.

- [`split_channels()`](https://swarm-lab.github.io/Retina/reference/split_channels.md)
  : Split an image into its individual channels
- [`merge_channels()`](https://swarm-lab.github.io/Retina/reference/merge_channels.md)
  : Merge a list of single-channel images into a multi-channel image

## Image construction

Standalone functions for creating and combining images.

- [`concatenate()`](https://swarm-lab.github.io/Retina/reference/concatenate.md)
  : Concatenate images side-by-side or top-to-bottom

## Geometric transform helpers

Construct affine and perspective transformation matrices for use with
`Image$warp_affine()` and `Image$warp_perspective()`.

- [`affine_translate()`](https://swarm-lab.github.io/Retina/reference/affine_translate.md)
  : Build an affine translation matrix
- [`affine_scale()`](https://swarm-lab.github.io/Retina/reference/affine_scale.md)
  : Build an affine scaling matrix
- [`affine_shear()`](https://swarm-lab.github.io/Retina/reference/affine_shear.md)
  : Build an affine shear matrix
- [`affine_rotate()`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md)
  : Build an affine rotation matrix
- [`affine_from_points()`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md)
  : Compute an affine transformation matrix from point correspondences
- [`perspective_from_points()`](https://swarm-lab.github.io/Retina/reference/perspective_from_points.md)
  : Compute a perspective transformation matrix from point
  correspondences

## Arithmetic and bitwise operators

S3 generics for arithmetic and bitwise operations on images.

- [`bitwAnd()`](https://swarm-lab.github.io/Retina/reference/bitwAnd.md)
  [`bitwOr()`](https://swarm-lab.github.io/Retina/reference/bitwAnd.md)
  [`bitwXor()`](https://swarm-lab.github.io/Retina/reference/bitwAnd.md)
  [`bitwNot()`](https://swarm-lab.github.io/Retina/reference/bitwAnd.md)
  : Bitwise operations for Image objects

## Statistical utilities

S3 generics for image statistics.

- [`sd()`](https://swarm-lab.github.io/Retina/reference/sd.md) :
  Standard deviation for Image objects
- [`var()`](https://swarm-lab.github.io/Retina/reference/var.md) :
  Variance for Image objects

## Filter utilities

Construct kernel matrices for filtering and morphology operations.

- [`get_gabor_kernel()`](https://swarm-lab.github.io/Retina/reference/get_gabor_kernel.md)
  : Generate a Gabor filter kernel
- [`get_structuring_element()`](https://swarm-lab.github.io/Retina/reference/get_structuring_element.md)
  : Generate a structuring element kernel

## Thresholding utilities

Compute threshold values without modifying the image.

- [`autothreshold_value()`](https://swarm-lab.github.io/Retina/reference/autothreshold_value.md)
  : Compute an automatic threshold value from an image

## Drawing utilities

Measure text extents before drawing.

- [`get_text_size()`](https://swarm-lab.github.io/Retina/reference/get_text_size.md)
  : Measure the bounding box of a text string

## Display

Open an interactive display window.

- [`display()`](https://swarm-lab.github.io/Retina/reference/display.md)
  : Display an image using R's graphics device
