# Retina (development version)

# Retina 0.1.0

## Core Infrastructure

* Added `Image` R6 class backed by OpenCV `cv::Mat` / `cv::UMat` via cpp11.
* `Image$new()` constructs from a file path or an R array (with colorspace and
  depth arguments).
* `Image$write()` saves to file. `Image$copy()` produces a deep copy.
* `Image$plot()` and `Image$to_native_raster()` render images for display.
* `Image$to_gpu()` / `Image$to_cpu()` transfer between CPU and GPU buffers.
* `dim.Image()` returns `c(nrow, ncol, nchan)`.

## Depth & Color Space

* `Image$convert_depth()` / `Image$convert_depth_()` and `Image$to_array()`
  convert bit depth and export pixel data as R arrays.
* `Image$convert_color()` / `Image$convert_color_()` converts between color
  spaces. Convenience shortcuts: `$to_gray()`, `$to_bgr()`, `$to_hsv()`,
  `$to_lab()`.

## Statistics

* `Image$mean()`, `$sd()`, `$var()`, `$min()`, `$max()`, `$sum()`,
  `$median()`, `$quantile()` compute per-channel statistics.
* S3 methods `mean.Image`, `sd.Image`, `var.Image`, `min.Image`, `max.Image`,
  `sum.Image`, `median.Image`, `quantile.Image` are registered.

## Arithmetic & Bitwise

* `Image$add()` / `$add_()`, `$subtract()` / `$subtract_()`,
  `$multiply()` / `$multiply_()`, `$divide()` / `$divide_()`.
* `Image$absdiff()` / `$absdiff_()`, `$add_weighted()` / `$add_weighted_()`.
* `Image$bitwise_and()` / `$bitwise_and_()`, `$bitwise_or()` / `$bitwise_or_()`,
  `$bitwise_xor()` / `$bitwise_xor_()`, `$bitwise_not()` / `$bitwise_not_()`.
* Operator overloads: `+`, `-`, `*`, `/`, `bitwAnd()`, `bitwOr()`, `bitwXor()`,
  `bitwNot()`.

## Filtering

* `Image$blur()` / `$blur_()` — box filter.
* `Image$gaussian_blur()` / `$gaussian_blur_()` — Gaussian filter.
* `Image$median_blur()` / `$median_blur_()` — median filter.
* `Image$bilateral_filter()` / `$bilateral_filter_()` — edge-preserving smooth.

## Edge Detection

* `Image$sobel()` / `$sobel_()`, `$laplacian()` / `$laplacian_()` — gradient
  operators.
* `Image$canny()` / `$canny_()` — Canny edge detector.

## Morphology

* `Image$morph()` / `$morph_()` — erode, dilate, open, close, gradient,
  tophat, blackhat operations with custom kernel support.

## Geometric Transforms

* `Image$resize()` / `$resize_()`, `$rotate()` / `$rotate_()`,
  `$flip()` / `$flip_()`, `$crop()` / `$crop_()`.
* `Image$warp_affine()` / `$warp_affine_()` — apply a 2×3 affine matrix.
* `Image$warp_perspective()` / `$warp_perspective_()` — apply a 3×3 homography.
* Matrix constructors: `affine_translate()`, `affine_scale()`, `affine_shear()`,
  `affine_rotate()`, `affine_from_points()`, `perspective_from_points()`.

## Channel Operations

* `split_channels()` decomposes a multi-channel image into a named list of
  single-channel images.
* `merge_channels()` reassembles from a named list.

## Pixel Access

* `[.Image` reads a single pixel (named vector), a single channel (scalar),
  or a rectangular region (new `Image`). Uses 1-based `[row, col]` indexing.
* `[<-.Image` writes a single pixel, single channel, or rectangular region.

## Image Construction Utilities

* `Image$fill()`, `Image$zeros()`, `Image$ones()` — filled constructors.
* `Image$randu()`, `Image$randn()` — random image constructors.
* `Image$border()` / `$border_()` — add border padding.
* `Image$tile()` / `$tile_()` — tile image N×M times.
* `Image$set_to()` / `$set_to_()` — set all or masked pixels to a scalar.
* `concatenate()` — horizontal or vertical image stacking.

## Thresholding

* `Image$threshold()` / `$threshold_()` — global threshold with 5 types and
  17 ImageJ auto-threshold methods.
* `Image$adaptive_threshold()` / `$adaptive_threshold_()` — local mean/Gaussian
  threshold (`CV_8U` only).
* `Image$in_range()` / `$in_range_()` — per-channel range mask.
* `autothreshold_value()` — returns computed threshold value without modifying
  the image.

## Drawing

* `Image$draw_line()` / `$draw_line_()`, `$draw_arrow()` / `$draw_arrow_()`.
* `Image$draw_rectangle()` / `$draw_rectangle_()`,
  `$draw_circle()` / `$draw_circle_()`.
* `Image$draw_ellipse()` / `$draw_ellipse_()`, `$draw_arc()` / `$draw_arc_()`.
* `Image$draw_polyline()` / `$draw_polyline_()`,
  `$fill_poly()` / `$fill_poly_()`.
* `Image$draw_text()` / `$draw_text_()`.
* `col2bgr()` converts R color names / hex strings to BGR(A) numeric vectors.
* `get_text_size()` measures text bounding box without drawing.
