# Image class

Image class

Image class

## Details

An R6 class representing a single image, backed by an OpenCV `cv::Mat`
(CPU) or `cv::UMat` (GPU).

## Active bindings

- `nrow`:

  Number of rows (height in pixels).

- `ncol`:

  Number of columns (width in pixels).

- `nchan`:

  Number of channels.

- `depth`:

  Bit depth code (0=CV_8U, 1=CV_8S, 2=CV_16U, ...).

- `depth_name`:

  Human-readable depth string (e.g. `"CV_8U"`).

- `gpu`:

  Logical; TRUE if the image is currently on the GPU.

- `colorspace`:

  Character string describing the color space (e.g. "BGR", "GRAY").

## Methods

### Public methods

- [`Image$new()`](#method-Image-new)

- [`Image$to_array()`](#method-Image-to_array)

- [`Image$to_native_raster()`](#method-Image-to_native_raster)

- [`Image$plot()`](#method-Image-plot)

- [`Image$write()`](#method-Image-write)

- [`Image$to_gpu()`](#method-Image-to_gpu)

- [`Image$to_cpu()`](#method-Image-to_cpu)

- [`Image$copy()`](#method-Image-copy)

- [`Image$convert_color()`](#method-Image-convert_color)

- [`Image$convert_color_()`](#method-Image-convert_color_)

- [`Image$convert_depth()`](#method-Image-convert_depth)

- [`Image$convert_depth_()`](#method-Image-convert_depth_)

- [`Image$to_gray()`](#method-Image-to_gray)

- [`Image$to_gray_()`](#method-Image-to_gray_)

- [`Image$to_bgr()`](#method-Image-to_bgr)

- [`Image$to_bgr_()`](#method-Image-to_bgr_)

- [`Image$to_hsv()`](#method-Image-to_hsv)

- [`Image$to_hsv_()`](#method-Image-to_hsv_)

- [`Image$to_lab()`](#method-Image-to_lab)

- [`Image$to_lab_()`](#method-Image-to_lab_)

- [`Image$mean()`](#method-Image-mean)

- [`Image$min()`](#method-Image-min)

- [`Image$max()`](#method-Image-max)

- [`Image$sd()`](#method-Image-sd)

- [`Image$var()`](#method-Image-var)

- [`Image$sum()`](#method-Image-sum)

- [`Image$median()`](#method-Image-median)

- [`Image$quantile()`](#method-Image-quantile)

- [`Image$add()`](#method-Image-add)

- [`Image$add_()`](#method-Image-add_)

- [`Image$subtract()`](#method-Image-subtract)

- [`Image$subtract_()`](#method-Image-subtract_)

- [`Image$multiply()`](#method-Image-multiply)

- [`Image$multiply_()`](#method-Image-multiply_)

- [`Image$divide()`](#method-Image-divide)

- [`Image$divide_()`](#method-Image-divide_)

- [`Image$absdiff()`](#method-Image-absdiff)

- [`Image$absdiff_()`](#method-Image-absdiff_)

- [`Image$add_weighted()`](#method-Image-add_weighted)

- [`Image$add_weighted_()`](#method-Image-add_weighted_)

- [`Image$bitwise_and()`](#method-Image-bitwise_and)

- [`Image$bitwise_and_()`](#method-Image-bitwise_and_)

- [`Image$bitwise_or()`](#method-Image-bitwise_or)

- [`Image$bitwise_or_()`](#method-Image-bitwise_or_)

- [`Image$bitwise_xor()`](#method-Image-bitwise_xor)

- [`Image$bitwise_xor_()`](#method-Image-bitwise_xor_)

- [`Image$bitwise_not()`](#method-Image-bitwise_not)

- [`Image$bitwise_not_()`](#method-Image-bitwise_not_)

- [`Image$blur()`](#method-Image-blur)

- [`Image$blur_()`](#method-Image-blur_)

- [`Image$gaussian_blur()`](#method-Image-gaussian_blur)

- [`Image$gaussian_blur_()`](#method-Image-gaussian_blur_)

- [`Image$median_blur()`](#method-Image-median_blur)

- [`Image$median_blur_()`](#method-Image-median_blur_)

- [`Image$bilateral_filter()`](#method-Image-bilateral_filter)

- [`Image$bilateral_filter_()`](#method-Image-bilateral_filter_)

- [`Image$sobel()`](#method-Image-sobel)

- [`Image$sobel_()`](#method-Image-sobel_)

- [`Image$laplacian()`](#method-Image-laplacian)

- [`Image$laplacian_()`](#method-Image-laplacian_)

- [`Image$canny()`](#method-Image-canny)

- [`Image$canny_()`](#method-Image-canny_)

- [`Image$scharr()`](#method-Image-scharr)

- [`Image$scharr_()`](#method-Image-scharr_)

- [`Image$filter2D()`](#method-Image-filter2D)

- [`Image$filter2D_()`](#method-Image-filter2D_)

- [`Image$sep_filter2D()`](#method-Image-sep_filter2D)

- [`Image$sep_filter2D_()`](#method-Image-sep_filter2D_)

- [`Image$morph()`](#method-Image-morph)

- [`Image$morph_()`](#method-Image-morph_)

- [`Image$resize()`](#method-Image-resize)

- [`Image$resize_()`](#method-Image-resize_)

- [`Image$rotate()`](#method-Image-rotate)

- [`Image$rotate_()`](#method-Image-rotate_)

- [`Image$flip()`](#method-Image-flip)

- [`Image$flip_()`](#method-Image-flip_)

- [`Image$crop()`](#method-Image-crop)

- [`Image$crop_()`](#method-Image-crop_)

- [`Image$warp_affine()`](#method-Image-warp_affine)

- [`Image$warp_affine_()`](#method-Image-warp_affine_)

- [`Image$warp_perspective()`](#method-Image-warp_perspective)

- [`Image$warp_perspective_()`](#method-Image-warp_perspective_)

- [`Image$border()`](#method-Image-border)

- [`Image$border_()`](#method-Image-border_)

- [`Image$tile()`](#method-Image-tile)

- [`Image$tile_()`](#method-Image-tile_)

- [`Image$set_to()`](#method-Image-set_to)

- [`Image$set_to_()`](#method-Image-set_to_)

- [`Image$threshold()`](#method-Image-threshold)

- [`Image$threshold_()`](#method-Image-threshold_)

- [`Image$adaptive_threshold()`](#method-Image-adaptive_threshold)

- [`Image$adaptive_threshold_()`](#method-Image-adaptive_threshold_)

- [`Image$in_range()`](#method-Image-in_range)

- [`Image$in_range_()`](#method-Image-in_range_)

- [`Image$draw_line()`](#method-Image-draw_line)

- [`Image$draw_line_()`](#method-Image-draw_line_)

- [`Image$draw_arrow()`](#method-Image-draw_arrow)

- [`Image$draw_arrow_()`](#method-Image-draw_arrow_)

- [`Image$draw_rectangle()`](#method-Image-draw_rectangle)

- [`Image$draw_rectangle_()`](#method-Image-draw_rectangle_)

- [`Image$draw_circle()`](#method-Image-draw_circle)

- [`Image$draw_circle_()`](#method-Image-draw_circle_)

- [`Image$draw_ellipse()`](#method-Image-draw_ellipse)

- [`Image$draw_ellipse_()`](#method-Image-draw_ellipse_)

- [`Image$draw_arc()`](#method-Image-draw_arc)

- [`Image$draw_arc_()`](#method-Image-draw_arc_)

- [`Image$draw_polyline()`](#method-Image-draw_polyline)

- [`Image$draw_polyline_()`](#method-Image-draw_polyline_)

- [`Image$fill_poly()`](#method-Image-fill_poly)

- [`Image$fill_poly_()`](#method-Image-fill_poly_)

- [`Image$draw_text()`](#method-Image-draw_text)

- [`Image$draw_text_()`](#method-Image-draw_text_)

- [`Image$hist()`](#method-Image-hist)

- [`Image$hist_eq()`](#method-Image-hist_eq)

- [`Image$hist_eq_()`](#method-Image-hist_eq_)

- [`Image$hist_match()`](#method-Image-hist_match)

- [`Image$hist_match_()`](#method-Image-hist_match_)

- [`Image$CLAHE()`](#method-Image-CLAHE)

- [`Image$CLAHE_()`](#method-Image-CLAHE_)

- [`Image$minmax_loc()`](#method-Image-minmax_loc)

- [`Image$count_nonzero()`](#method-Image-count_nonzero)

- [`Image$find_nonzero()`](#method-Image-find_nonzero)

- [`Image$pow()`](#method-Image-pow)

- [`Image$pow_()`](#method-Image-pow_)

- [`Image$exp()`](#method-Image-exp)

- [`Image$exp_()`](#method-Image-exp_)

- [`Image$log()`](#method-Image-log)

- [`Image$log_()`](#method-Image-log_)

- [`Image$sqrt()`](#method-Image-sqrt)

- [`Image$sqrt_()`](#method-Image-sqrt_)

- [`Image$extract_channel()`](#method-Image-extract_channel)

- [`Image$insert_channel()`](#method-Image-insert_channel)

- [`Image$insert_channel_()`](#method-Image-insert_channel_)

- [`Image$LUT()`](#method-Image-LUT)

- [`Image$LUT_()`](#method-Image-LUT_)

- [`Image$print()`](#method-Image-print)

------------------------------------------------------------------------

### Method `new()`

Create a new Image.

#### Usage

    Image$new(x, colorspace = "BGR", depth = NULL)

#### Arguments

- `x`:

  A file path (character), a 3D array (nrow x ncol x nchan), or a 2D
  matrix. Use an integer array for integer depths (`CV_8U`, `CV_16U`,
  `CV_16S`) and a double array for float depths (`CV_32F`, `CV_64F`).

- `colorspace`:

  Color space label string. Ignored when reading from file (OpenCV
  assumes BGR for color images).

- `depth`:

  Character. Bit depth of the image. One of `"CV_8U"`, `"CV_16U"`,
  `"CV_16S"`, `"CV_32F"`, `"CV_64F"`. If `NULL` (default), inferred from
  the array type: integer arrays default to `"CV_8U"`, double arrays to
  `"CV_32F"`, and a message is emitted. Ignored when `x` is a file path
  or external pointer.

------------------------------------------------------------------------

### Method `to_array()`

Convert the image to an array (nrow x ncol x nchan). Returns an integer
array for `CV_8U`, `CV_16U`, and `CV_16S` images; a double array for
`CV_32F` and `CV_64F` images.

#### Usage

    Image$to_array()

#### Returns

An array with dimensions `[nrow, ncol, nchan]`.

------------------------------------------------------------------------

### Method `to_native_raster()`

Convert the image to a `nativeRaster` object.

#### Usage

    Image$to_native_raster()

#### Returns

A `nativeRaster` matrix suitable for use with `grid` or other graphics
systems.

------------------------------------------------------------------------

### Method [`plot()`](https://rdrr.io/r/graphics/plot.default.html)

Display the image using R's graphics device.

#### Usage

    Image$plot(newpage = TRUE, ...)

#### Arguments

- `newpage`:

  Logical. If `TRUE` (default), clears the graphics device before
  drawing. Set to `FALSE` when composing multiple images in a layout
  using `grid` viewports.

- `...`:

  Additional arguments passed to
  [`grid::grid.raster()`](https://rdrr.io/r/grid/grid.raster.html).

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`write()`](https://rdrr.io/r/base/write.html)

Write the image to a file. Format is inferred from the file extension.

#### Usage

    Image$write(path)

#### Arguments

- `path`:

  Character. Output file path (e.g. `"output.png"`, `"output.jpg"`).

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_gpu()`

Upload the image to GPU memory (cv::UMat). No-op if already on GPU.

#### Usage

    Image$to_gpu()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_cpu()`

Download the image from GPU to CPU memory (cv::Mat). No-op if already on
CPU.

#### Usage

    Image$to_cpu()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `copy()`

Create a deep copy of this image.

#### Usage

    Image$copy()

#### Returns

A new `Image` with independent C++ storage.

------------------------------------------------------------------------

### Method `convert_color()`

Convert to a new color space. Returns a new Image.

#### Usage

    Image$convert_color(to)

#### Arguments

- `to`:

  Character. Target color space (e.g. `"GRAY"`, `"HSV"`).

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `convert_color_()`

Convert to a new color space in place.

#### Usage

    Image$convert_color_(to)

#### Arguments

- `to`:

  Character. Target color space.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `convert_depth()`

Convert to a new bit depth. Returns a new Image. Values are cast
directly with no scaling: a CV_8U pixel with value 100 becomes 100.0 in
CV_32F, not 0.392. Use `convert_depth` followed by arithmetic if you
need normalized floating-point values.

#### Usage

    Image$convert_depth(to)

#### Arguments

- `to`:

  Character. Target depth, one of `"CV_8U"`, `"CV_16U"`, `"CV_16S"`,
  `"CV_32F"`, `"CV_64F"`.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `convert_depth_()`

Convert to a new bit depth in place. Values are cast directly with no
scaling (see `convert_depth`).

#### Usage

    Image$convert_depth_(to)

#### Arguments

- `to`:

  Character. Target depth, one of `"CV_8U"`, `"CV_16U"`, `"CV_16S"`,
  `"CV_32F"`, `"CV_64F"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_gray()`

Convert to grayscale. Returns a new Image.

#### Usage

    Image$to_gray()

#### Returns

A new `Image` with colorspace `"GRAY"`.

------------------------------------------------------------------------

### Method `to_gray_()`

Convert to grayscale in place.

#### Usage

    Image$to_gray_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_bgr()`

Convert to BGR. Returns a new Image.

#### Usage

    Image$to_bgr()

#### Returns

A new `Image` with colorspace `"BGR"`.

------------------------------------------------------------------------

### Method `to_bgr_()`

Convert to BGR in place.

#### Usage

    Image$to_bgr_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_hsv()`

Convert to HSV. Returns a new Image.

#### Usage

    Image$to_hsv()

#### Returns

A new `Image` with colorspace `"HSV"`.

------------------------------------------------------------------------

### Method `to_hsv_()`

Convert to HSV in place.

#### Usage

    Image$to_hsv_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `to_lab()`

Convert to LAB color space. Returns a new Image.

#### Usage

    Image$to_lab()

#### Returns

A new `Image` with colorspace `"LAB"`.

------------------------------------------------------------------------

### Method `to_lab_()`

Convert to LAB color space in place.

#### Usage

    Image$to_lab_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`mean()`](https://rdrr.io/r/base/mean.html)

Per-channel mean pixel value.

#### Usage

    Image$mean()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`min()`](https://rdrr.io/r/base/Extremes.html)

Per-channel minimum pixel value.

#### Usage

    Image$min()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`max()`](https://rdrr.io/r/base/Extremes.html)

Per-channel maximum pixel value.

#### Usage

    Image$max()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`sd()`](https://swarm-lab.github.io/Retina/reference/sd.md)

Per-channel standard deviation (population).

#### Usage

    Image$sd()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`var()`](https://swarm-lab.github.io/Retina/reference/var.md)

Per-channel variance (population).

#### Usage

    Image$var()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`sum()`](https://rdrr.io/r/base/sum.html)

Per-channel pixel sum.

#### Usage

    Image$sum()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`median()`](https://rdrr.io/r/stats/median.html)

Per-channel median pixel value.

#### Usage

    Image$median()

#### Returns

Named numeric vector of length `nchan`.

------------------------------------------------------------------------

### Method [`quantile()`](https://rdrr.io/r/stats/quantile.html)

Per-channel quantiles.

#### Usage

    Image$quantile(probs = 0.5)

#### Arguments

- `probs`:

  Numeric vector of probabilities in `[0, 1]`. Defaults to `0.5`
  (median).

#### Returns

A matrix with `length(probs)` rows and `nchan` columns. Row names are
percentages (e.g. `"25%"`); column names are channel names.

------------------------------------------------------------------------

### Method `add()`

Add another image or a scalar to this image.

#### Usage

    Image$add(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask. Only pixels where mask is
  non-zero are updated; others retain `self`'s values.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `add_()`

Add in place.

#### Usage

    Image$add_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `subtract()`

Subtract another image or a scalar from this image.

#### Usage

    Image$subtract(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `subtract_()`

Subtract in place.

#### Usage

    Image$subtract_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `multiply()`

Multiply this image element-wise by another image or a scalar.

#### Usage

    Image$multiply(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `multiply_()`

Multiply in place.

#### Usage

    Image$multiply_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `divide()`

Divide this image element-wise by another image or a scalar.

#### Usage

    Image$divide(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `divide_()`

Divide in place.

#### Usage

    Image$divide_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `absdiff()`

Compute the absolute difference with another image or a scalar.

#### Usage

    Image$absdiff(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `absdiff_()`

Absolute difference in place.

#### Usage

    Image$absdiff_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `add_weighted()`

Weighted addition of two images: `w1*self + w2*other + gamma`.

#### Usage

    Image$add_weighted(other, w1, w2, gamma = 0, mask = NULL)

#### Arguments

- `other`:

  An `Image`.

- `w1`:

  Numeric scalar. Weight for this image.

- `w2`:

  Numeric scalar. Weight for `other`.

- `gamma`:

  Numeric scalar. Brightness offset added after blending. Default 0.

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `add_weighted_()`

Weighted addition in place.

#### Usage

    Image$add_weighted_(other, w1, w2, gamma = 0, mask = NULL)

#### Arguments

- `other`:

  An `Image`.

- `w1`:

  Numeric scalar. Weight for this image.

- `w2`:

  Numeric scalar. Weight for `other`.

- `gamma`:

  Numeric scalar. Brightness offset. Default 0.

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `bitwise_and()`

Bitwise AND with another image or a scalar.

#### Usage

    Image$bitwise_and(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `bitwise_and_()`

Bitwise AND in place.

#### Usage

    Image$bitwise_and_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `bitwise_or()`

Bitwise OR with another image or a scalar.

#### Usage

    Image$bitwise_or(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `bitwise_or_()`

Bitwise OR in place.

#### Usage

    Image$bitwise_or_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `bitwise_xor()`

Bitwise XOR with another image or a scalar.

#### Usage

    Image$bitwise_xor(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `bitwise_xor_()`

Bitwise XOR in place.

#### Usage

    Image$bitwise_xor_(other, mask = NULL)

#### Arguments

- `other`:

  An `Image` or a numeric vector (length 1 or `nchan`).

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `bitwise_not()`

Bitwise NOT (invert all bits).

#### Usage

    Image$bitwise_not(mask = NULL)

#### Arguments

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `bitwise_not_()`

Bitwise NOT in place.

#### Usage

    Image$bitwise_not_(mask = NULL)

#### Arguments

- `mask`:

  Optional single-channel CV_8U `Image` mask.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `blur()`

Apply a normalised box filter (simple average blur).

#### Usage

    Image$blur(ksize)

#### Arguments

- `ksize`:

  Length-2 integer vector `c(width, height)` of positive integers
  specifying the kernel size.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `blur_()`

Box blur in place.

#### Usage

    Image$blur_(ksize)

#### Arguments

- `ksize`:

  Length-2 integer vector `c(width, height)` of positive integers
  specifying the kernel size.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `gaussian_blur()`

Apply a Gaussian blur.

#### Usage

    Image$gaussian_blur(ksize, sigma)

#### Arguments

- `ksize`:

  Length-2 vector. Each element must be a positive odd integer or `0`.
  When `0`, the kernel size is inferred from `sigma` automatically.

- `sigma`:

  Length-1 or length-2 positive numeric. Gaussian standard deviation in
  the X (and optionally Y) direction. A single value is applied to both
  axes.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `gaussian_blur_()`

Gaussian blur in place.

#### Usage

    Image$gaussian_blur_(ksize, sigma)

#### Arguments

- `ksize`:

  Length-2 vector. Each element must be a positive odd integer or `0`.
  When `0`, the kernel size is inferred from `sigma` automatically.

- `sigma`:

  Length-1 or length-2 positive numeric. A single value is applied to
  both axes.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `median_blur()`

Apply a median blur.

#### Usage

    Image$median_blur(ksize)

#### Arguments

- `ksize`:

  Single positive odd integer. The kernel is always square (OpenCV
  constraint).

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `median_blur_()`

Median blur in place.

#### Usage

    Image$median_blur_(ksize)

#### Arguments

- `ksize`:

  Single positive odd integer. The kernel is always square (OpenCV
  constraint).

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `bilateral_filter()`

Apply a bilateral filter (edge-preserving smoothing).

#### Usage

    Image$bilateral_filter(d, sigma_color, sigma_space)

#### Arguments

- `d`:

  Single integer. Diameter of the pixel neighbourhood. When `d <= 0`,
  the diameter is computed from `sigma_space`.

- `sigma_color`:

  Single positive numeric. Filter sigma in colour space.

- `sigma_space`:

  Single positive numeric. Filter sigma in coordinate space.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `bilateral_filter_()`

Bilateral filter in place.

#### Usage

    Image$bilateral_filter_(d, sigma_color, sigma_space)

#### Arguments

- `d`:

  Single integer. Diameter of the pixel neighbourhood. When `d <= 0`,
  the diameter is computed from `sigma_space`.

- `sigma_color`:

  Single positive numeric. Filter sigma in colour space.

- `sigma_space`:

  Single positive numeric. Filter sigma in coordinate space.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `sobel()`

Apply the Sobel operator to compute image gradients. Returns a new
Image.

#### Usage

    Image$sobel(
      dx,
      dy,
      ksize = 3,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `dx`:

  Non-negative integer. Order of x derivative.

- `dy`:

  Non-negative integer. Order of y derivative. `dx + dy` must be \>= 1.

- `ksize`:

  Integer. Sobel kernel aperture size: 1, 3, 5, or 7. The limit of 7 is
  an OpenCV requirement.

- `ddepth`:

  Character. Output depth: `"CV_16S"`, `"CV_32F"`, or `"CV_64F"`.
  Default `NULL` (depth inferred from input; a message is emitted).

- `scale`:

  Single positive numeric. Optional scale factor for the computed
  derivatives. Must be positive (use `convert_depth` + arithmetic to
  invert gradient sign). Default 1.

- `delta`:

  Single numeric. Optional delta added to results before storing.
  Default 0.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for these operations.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)
    grad_x <- img$sobel(1, 0)
    grad_x$plot()
    }

------------------------------------------------------------------------

### Method `sobel_()`

Sobel operator in place.

#### Usage

    Image$sobel_(
      dx,
      dy,
      ksize = 3,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `dx`:

  Non-negative integer. Order of x derivative.

- `dy`:

  Non-negative integer. Order of y derivative. `dx + dy` must be \>= 1.

- `ksize`:

  Integer. Sobel kernel aperture size: 1, 3, 5, or 7.

- `ddepth`:

  Character. Output depth: `"CV_16S"`, `"CV_32F"`, or `"CV_64F"`.
  Default `NULL` (depth inferred from input; a message is emitted).

- `scale`:

  Single positive numeric. Optional scale factor for the computed
  derivatives. Must be positive (use `convert_depth` + arithmetic to
  invert gradient sign). Default 1.

- `delta`:

  Single numeric. Delta added to results. Default 0.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for these operations.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$sobel_(1, 0)
    img$plot()
    }

------------------------------------------------------------------------

### Method `laplacian()`

Apply the Laplacian operator to detect edges. Returns a new Image.

#### Usage

    Image$laplacian(
      ksize = 1,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `ksize`:

  Integer. Aperture size for the Laplacian kernel: 1, 3, 5, or 7.
  `ksize = 1` uses the 3-point central-difference stencil. Default 1.

- `ddepth`:

  Character. Output depth: `"CV_16S"`, `"CV_32F"`, or `"CV_64F"`.
  Default `NULL` (depth inferred from input; a message is emitted).

- `scale`:

  Single positive numeric. Optional scale factor. Must be positive.
  Default 1.

- `delta`:

  Single numeric. Optional delta added to results. Default 0.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for these operations.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    edges <- img$laplacian()
    edges$plot()
    }

------------------------------------------------------------------------

### Method `laplacian_()`

Laplacian operator in place.

#### Usage

    Image$laplacian_(
      ksize = 1,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `ksize`:

  Integer. Aperture size: 1, 3, 5, or 7. Default 1.

- `ddepth`:

  Character. Output depth: `"CV_16S"`, `"CV_32F"`, or `"CV_64F"`.
  Default `NULL` (depth inferred from input; a message is emitted).

- `scale`:

  Single positive numeric. Optional scale factor. Must be positive.
  Default 1.

- `delta`:

  Single numeric. Delta added to results. Default 0.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for these operations.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$laplacian_()
    img$plot()
    }

------------------------------------------------------------------------

### Method `canny()`

Detect edges using the Canny algorithm. Returns a new single-channel
CV_8U Image with pixel values 0 (no edge) or 255 (edge). Input must be a
single-channel grayscale image.

#### Usage

    Image$canny(
      low_threshold,
      high_threshold,
      aperture_size = 3,
      L2_gradient = FALSE
    )

#### Arguments

- `low_threshold`:

  Single non-negative numeric. Lower hysteresis threshold.

- `high_threshold`:

  Single positive numeric. Upper hysteresis threshold. Must be \>=
  `low_threshold`.

- `aperture_size`:

  Integer. Size of the Sobel kernel used internally: 3, 5, or 7. Default
  3.

- `L2_gradient`:

  Logical scalar. If `TRUE`, use the L2 norm for gradient magnitude
  (more accurate but slower). Default `FALSE`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "staircase.jpg", package = "Retina")
    img <- Image$new(img_path)$convert_color("GRAY")
    edges <- img$canny(50, 150)
    edges$plot()
    }

------------------------------------------------------------------------

### Method `canny_()`

Canny edge detection in place.

#### Usage

    Image$canny_(
      low_threshold,
      high_threshold,
      aperture_size = 3,
      L2_gradient = FALSE
    )

#### Arguments

- `low_threshold`:

  Single non-negative numeric. Lower hysteresis threshold.

- `high_threshold`:

  Single positive numeric. Upper hysteresis threshold. Must be \>=
  `low_threshold`.

- `aperture_size`:

  Integer. Size of the Sobel kernel: 3, 5, or 7. Default 3.

- `L2_gradient`:

  Logical scalar. Use L2 norm for gradient magnitude. Default `FALSE`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "staircase.jpg", package = "Retina")
    img <- Image$new(img_path)$convert_color("GRAY")
    img$canny_(50, 150)
    img$plot()
    }

------------------------------------------------------------------------

### Method `scharr()`

Apply the Scharr operator to compute image gradients. Returns a new
Image. Scharr uses a fixed 3x3 kernel with better rotational symmetry
than Sobel. Exactly one of `dx` or `dy` must be 1.

#### Usage

    Image$scharr(
      dx,
      dy,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `dx`:

  Integer. Order of x derivative: `0` or `1`.

- `dy`:

  Integer. Order of y derivative: `0` or `1`. Exactly one of `dx`, `dy`
  must be `1`.

- `ddepth`:

  Character or `NULL`. Output depth: `"CV_16S"`, `"CV_32F"`, or
  `"CV_64F"`. When `NULL` (default), the output depth is inferred from
  the input depth and a message is emitted.

- `scale`:

  Single positive numeric. Scale factor for computed derivatives.
  Default `1`.

- `delta`:

  Single numeric. Constant added to output pixels. Default `0`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for Scharr.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)
    grad_x <- img$scharr(1, 0)
    grad_x$plot()
    }

------------------------------------------------------------------------

### Method `scharr_()`

Scharr operator in place.

#### Usage

    Image$scharr_(
      dx,
      dy,
      ddepth = NULL,
      scale = 1,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `dx`:

  Integer. Order of x derivative: `0` or `1`.

- `dy`:

  Integer. Order of y derivative: `0` or `1`. Exactly one of `dx`, `dy`
  must be `1`.

- `ddepth`:

  Character or `NULL`. Output depth: `"CV_16S"`, `"CV_32F"`, or
  `"CV_64F"`. Default `NULL` (depth inferred from input; a message is
  emitted).

- `scale`:

  Single positive numeric. Default `1`.

- `delta`:

  Single numeric. Default `0`.

- `border_type`:

  Character. Border handling mode. `"wrap"` is not supported. Default
  `"reflect_101"`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$scharr_(1, 0)
    img$plot()
    }

------------------------------------------------------------------------

### Method `filter2D()`

Apply an arbitrary 2D convolution kernel. Returns a new Image.

#### Usage

    Image$filter2D(
      kernel,
      ddepth = NULL,
      anchor = NULL,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `kernel`:

  Numeric matrix. The convolution kernel. Values are coerced to double.

- `ddepth`:

  Character or `NULL`. Output depth. One of `"CV_8U"`, `"CV_16U"`,
  `"CV_16S"`, `"CV_32F"`, `"CV_64F"`. When `NULL` (default), the output
  depth matches the input depth (OpenCV `-1`).

- `anchor`:

  `NULL` (default, kernel centre) or a length-2 integer vector
  `c(col, row)` specifying the anchor pixel within the kernel (0-based).

- `delta`:

  Single numeric. Constant added to every output pixel after
  convolution. Default `0`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black); `"wrap"`
  tiles the image at the boundary.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
    sharpened <- img$filter2D(sharpen)
    sharpened$plot()
    }

------------------------------------------------------------------------

### Method `filter2D_()`

Apply an arbitrary 2D convolution kernel in place.

#### Usage

    Image$filter2D_(
      kernel,
      ddepth = NULL,
      anchor = NULL,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `kernel`:

  Numeric matrix. The convolution kernel.

- `ddepth`:

  Character or `NULL`. Output depth. Default `NULL` (preserves input
  depth).

- `anchor`:

  `NULL` (kernel centre) or `c(col, row)` (0-based).

- `delta`:

  Single numeric. Additive offset. Default `0`.

- `border_type`:

  Character. Border handling mode. Default `"reflect_101"`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
    img$filter2D_(sharpen)
    img$plot()
    }

------------------------------------------------------------------------

### Method `sep_filter2D()`

Apply a separable filter using two 1D kernels (one horizontal, one
vertical). Returns a new Image. Equivalent to applying `kernel_x` along
columns then `kernel_y` along rows, but computed more efficiently.

#### Usage

    Image$sep_filter2D(
      kernel_x,
      kernel_y,
      ddepth = NULL,
      anchor = NULL,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `kernel_x`:

  Numeric vector. Horizontal (column-direction) 1D kernel.

- `kernel_y`:

  Numeric vector. Vertical (row-direction) 1D kernel.

- `ddepth`:

  Character or `NULL`. Output depth. One of `"CV_8U"`, `"CV_16U"`,
  `"CV_16S"`, `"CV_32F"`, `"CV_64F"`. When `NULL` (default), the output
  depth matches the input depth.

- `anchor`:

  `NULL` (default, kernel centres) or a length-2 integer vector
  `c(pos_in_kernel_x, pos_in_kernel_y)` (0-based).

- `delta`:

  Single numeric. Constant added to every output pixel. Default `0`.

- `border_type`:

  Character. Border handling mode. Default `"reflect_101"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    blurred <- img$sep_filter2D(rep(1/3, 3), rep(1/3, 3))
    blurred$plot()
    }

------------------------------------------------------------------------

### Method `sep_filter2D_()`

Separable filter in place.

#### Usage

    Image$sep_filter2D_(
      kernel_x,
      kernel_y,
      ddepth = NULL,
      anchor = NULL,
      delta = 0,
      border_type = "reflect_101"
    )

#### Arguments

- `kernel_x`:

  Numeric vector. Horizontal 1D kernel.

- `kernel_y`:

  Numeric vector. Vertical 1D kernel.

- `ddepth`:

  Character or `NULL`. Output depth. Default `NULL`.

- `anchor`:

  `NULL` or `c(pos_x, pos_y)` (0-based). Default `NULL` (kernel
  centres).

- `delta`:

  Single numeric. Default `0`.

- `border_type`:

  Character. Default `"reflect_101"`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$sep_filter2D_(rep(1/3, 3), rep(1/3, 3))
    img$plot()
    }

------------------------------------------------------------------------

### Method `morph()`

Apply a morphological operation. Returns a new Image.

#### Usage

    Image$morph(
      operation,
      shape = "rect",
      size = 3L,
      kernel = NULL,
      iterations = 1L,
      border_type = "reflect_101"
    )

#### Arguments

- `operation`:

  Character. One of `"erode"` (shrinks bright regions), `"dilate"`
  (expands bright regions), `"open"` (erode then dilate — removes small
  bright spots), `"close"` (dilate then erode — fills small dark holes),
  `"gradient"` (dilate minus erode — highlights edges), `"tophat"`
  (image minus open — isolates bright features smaller than the kernel),
  `"blackhat"` (close minus image — isolates dark features smaller than
  the kernel).

- `shape`:

  Character. Structuring element shape: `"rect"`, `"cross"`, or
  `"ellipse"`. Ignored when `kernel` is supplied. Default `"rect"`.

- `size`:

  Positive odd integer. Side length of the structuring element. Ignored
  when `kernel` is supplied. Default `3L`.

- `kernel`:

  Optional numeric matrix used as the structuring element. Values are
  coerced to integers. Overrides `shape` and `size` when supplied.

- `iterations`:

  Positive integer. For primitive operations (`"erode"`, `"dilate"`),
  the number of times the operation is applied. For compound operations
  (`"open"`, `"close"`, `"gradient"`, `"tophat"`, `"blackhat"`), each
  internal erosion or dilation step is repeated `iterations` times
  independently (e.g., `iterations = 2` with `"open"` erodes twice then
  dilates twice, not opens twice). Default `1L`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for morphological operations.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)$convert_color("GRAY")
    eroded <- img$morph("erode")
    eroded$plot()
    }

------------------------------------------------------------------------

### Method `morph_()`

Apply a morphological operation in place.

#### Usage

    Image$morph_(
      operation,
      shape = "rect",
      size = 3L,
      kernel = NULL,
      iterations = 1L,
      border_type = "reflect_101"
    )

#### Arguments

- `operation`:

  Character. One of `"erode"` (shrinks bright regions), `"dilate"`
  (expands bright regions), `"open"` (erode then dilate — removes small
  bright spots), `"close"` (dilate then erode — fills small dark holes),
  `"gradient"` (dilate minus erode — highlights edges), `"tophat"`
  (image minus open — isolates bright features smaller than the kernel),
  `"blackhat"` (close minus image — isolates dark features smaller than
  the kernel).

- `shape`:

  Character. Structuring element shape: `"rect"`, `"cross"`, or
  `"ellipse"`. Ignored when `kernel` is supplied. Default `"rect"`.

- `size`:

  Positive odd integer. Side length of the structuring element. Ignored
  when `kernel` is supplied. Default `3L`.

- `kernel`:

  Optional numeric matrix used as the structuring element. Values are
  coerced to integers. Overrides `shape` and `size` when supplied.

- `iterations`:

  Positive integer. For primitive operations (`"erode"`, `"dilate"`),
  the number of times the operation is applied. For compound operations
  (`"open"`, `"close"`, `"gradient"`, `"tophat"`, `"blackhat"`), each
  internal erosion or dilation step is repeated `iterations` times
  independently (e.g., `iterations = 2` with `"open"` erodes twice then
  dilates twice, not opens twice). Default `1L`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"constant"` fills with a fixed value (0, i.e. black). `"wrap"`
  is not supported by OpenCV for morphological operations.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)$convert_color("GRAY")
    img$morph_("erode")
    img$plot()
    }

------------------------------------------------------------------------

### Method `resize()`

Resize the image. Returns a new Image.

#### Usage

    Image$resize(
      width = NULL,
      height = NULL,
      fx = NULL,
      fy = NULL,
      interpolation = "linear"
    )

#### Arguments

- `width`:

  Positive integer. Output width in pixels. Supply with `height`;
  mutually exclusive with `fx`/`fy`.

- `height`:

  Positive integer. Output height in pixels.

- `fx`:

  Positive numeric. Horizontal scale factor. Supply with `fy`; mutually
  exclusive with `width`/`height`.

- `fy`:

  Positive numeric. Vertical scale factor.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$resize(width = 320L, height = 240L)$plot()
    img$resize(fx = 0.5, fy = 0.5)$plot()
    }

------------------------------------------------------------------------

### Method `resize_()`

Resize the image in place.

#### Usage

    Image$resize_(
      width = NULL,
      height = NULL,
      fx = NULL,
      fy = NULL,
      interpolation = "linear"
    )

#### Arguments

- `width`:

  Positive integer. Output width in pixels.

- `height`:

  Positive integer. Output height in pixels.

- `fx`:

  Positive numeric. Horizontal scale factor.

- `fy`:

  Positive numeric. Vertical scale factor.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$resize_(fx = 0.5, fy = 0.5)
    img$plot()
    }

------------------------------------------------------------------------

### Method `rotate()`

Rotate the image. Returns a new Image. Output retains original
dimensions; content outside the canvas is clipped.

#### Usage

    Image$rotate(
      angle,
      cx = NULL,
      cy = NULL,
      scale = 1,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `angle`:

  Single numeric. Rotation angle in degrees, counter-clockwise.

- `cx`:

  Single positive numeric. X coordinate of the rotation centre
  (1-based). Defaults to image centre.

- `cy`:

  Single positive numeric. Y coordinate of the rotation centre
  (1-based). Defaults to image centre.

- `scale`:

  Single positive numeric. Isotropic scale factor applied during
  rotation. Default `1`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. Pixel extrapolation method. One of `"reflect_101"`,
  `"reflect"`, `"replicate"`, `"constant"`, `"wrap"`. Default
  `"reflect_101"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$rotate(45)$plot()
    }

------------------------------------------------------------------------

### Method `rotate_()`

Rotate the image in place.

#### Usage

    Image$rotate_(
      angle,
      cx = NULL,
      cy = NULL,
      scale = 1,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `angle`:

  Single numeric. Rotation angle in degrees, counter-clockwise.

- `cx`:

  Single positive numeric. X coordinate of the rotation centre
  (1-based). Defaults to image centre.

- `cy`:

  Single positive numeric. Y coordinate of the rotation centre
  (1-based). Defaults to image centre.

- `scale`:

  Single positive numeric. Isotropic scale factor. Default `1`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. Pixel extrapolation method. One of `"reflect_101"`,
  `"reflect"`, `"replicate"`, `"constant"`, `"wrap"`. Default
  `"reflect_101"`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$rotate_(45)
    img$plot()
    }

------------------------------------------------------------------------

### Method `flip()`

Flip the image horizontally, vertically, or both. Returns a new Image.

#### Usage

    Image$flip(flip_h = FALSE, flip_v = FALSE)

#### Arguments

- `flip_h`:

  Logical scalar. If `TRUE`, flip left-right. Default `FALSE`.

- `flip_v`:

  Logical scalar. If `TRUE`, flip top-bottom. Default `FALSE`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$flip(flip_h = TRUE)$plot()
    }

------------------------------------------------------------------------

### Method `flip_()`

Flip the image in place.

#### Usage

    Image$flip_(flip_h = FALSE, flip_v = FALSE)

#### Arguments

- `flip_h`:

  Logical scalar. If `TRUE`, flip left-right. Default `FALSE`.

- `flip_v`:

  Logical scalar. If `TRUE`, flip top-bottom. Default `FALSE`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$flip_(flip_v = TRUE)
    img$plot()
    }

------------------------------------------------------------------------

### Method `crop()`

Crop the image to a rectangular region. Returns a new Image. Coordinates
are 1-based.

#### Usage

    Image$crop(x1, y1, x2, y2)

#### Arguments

- `x1`:

  Single positive integer. Left column (inclusive, 1-based).

- `y1`:

  Single positive integer. Top row (inclusive, 1-based).

- `x2`:

  Single positive integer. Right column (inclusive, 1-based). Must be
  greater than `x1` and `<= ncol`.

- `y2`:

  Single positive integer. Bottom row (inclusive, 1-based). Must be
  greater than `y1` and `<= nrow`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$crop(1L, 1L, 100L, 100L)$plot()
    }

------------------------------------------------------------------------

### Method `crop_()`

Crop the image in place.

#### Usage

    Image$crop_(x1, y1, x2, y2)

#### Arguments

- `x1`:

  Single positive integer. Left column (inclusive, 1-based).

- `y1`:

  Single positive integer. Top row (inclusive, 1-based).

- `x2`:

  Single positive integer. Right column (inclusive, 1-based).

- `y2`:

  Single positive integer. Bottom row (inclusive, 1-based).

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$crop_(1L, 1L, 100L, 100L)
    img$plot()
    }

------------------------------------------------------------------------

### Method `warp_affine()`

Apply an affine transformation to the image. Returns a new Image. Output
defaults to the same dimensions as the input; content outside the canvas
is clipped.

#### Usage

    Image$warp_affine(
      m,
      width = NULL,
      height = NULL,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `m`:

  A 2x3 numeric matrix representing the affine transformation. Build one
  with
  [`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
  [`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
  [`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
  [`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
  or
  [`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md).
  Compose multiple transforms by embedding into 3x3 with
  `rbind(m, c(0, 0, 1))` then multiplying with `%*%`.

- `width`:

  Positive integer. Output width in pixels. Default: `self$ncol`.

- `height`:

  Positive integer. Output height in pixels. Default: `self$nrow`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"wrap"` tiles the image; `"constant"` fills with a fixed value
  (0, i.e. black).

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    m <- affine_translate(50, 30)
    img$warp_affine(m)$plot()
    }

------------------------------------------------------------------------

### Method `warp_affine_()`

Apply an affine transformation to the image in place.

#### Usage

    Image$warp_affine_(
      m,
      width = NULL,
      height = NULL,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `m`:

  A 2x3 numeric matrix representing the affine transformation. Build one
  with
  [`affine_translate`](https://swarm-lab.github.io/Retina/reference/affine_translate.md),
  [`affine_scale`](https://swarm-lab.github.io/Retina/reference/affine_scale.md),
  [`affine_shear`](https://swarm-lab.github.io/Retina/reference/affine_shear.md),
  [`affine_rotate`](https://swarm-lab.github.io/Retina/reference/affine_rotate.md),
  or
  [`affine_from_points`](https://swarm-lab.github.io/Retina/reference/affine_from_points.md).
  Compose multiple transforms by embedding into 3x3 with
  `rbind(m, c(0, 0, 1))` then multiplying with `%*%`.

- `width`:

  Positive integer. Output width in pixels. Default: `self$ncol`.

- `height`:

  Positive integer. Output height in pixels. Default: `self$nrow`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"wrap"` tiles the image; `"constant"` fills with a fixed value
  (0, i.e. black).

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$warp_affine_(affine_translate(50, 30))
    img$plot()
    }

------------------------------------------------------------------------

### Method `warp_perspective()`

Apply a perspective transformation to the image. Returns a new Image.
Output defaults to the same dimensions as the input; content outside the
canvas is clipped.

#### Usage

    Image$warp_perspective(
      m,
      width = NULL,
      height = NULL,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `m`:

  A 3x3 numeric matrix representing the perspective transformation.
  Build one with
  [`perspective_from_points`](https://swarm-lab.github.io/Retina/reference/perspective_from_points.md).

- `width`:

  Positive integer. Output width in pixels. Default: `self$ncol`.

- `height`:

  Positive integer. Output height in pixels. Default: `self$nrow`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"wrap"` tiles the image; `"constant"` fills with a fixed value
  (0, i.e. black).

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    w <- img$ncol; h <- img$nrow
    src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    m <- perspective_from_points(src, dst)
    img$warp_perspective(m)$plot()
    }

------------------------------------------------------------------------

### Method `warp_perspective_()`

Apply a perspective transformation to the image in place.

#### Usage

    Image$warp_perspective_(
      m,
      width = NULL,
      height = NULL,
      interpolation = "linear",
      border_type = "reflect_101"
    )

#### Arguments

- `m`:

  A 3x3 numeric matrix representing the perspective transformation.
  Build one with
  [`perspective_from_points`](https://swarm-lab.github.io/Retina/reference/perspective_from_points.md).

- `width`:

  Positive integer. Output width in pixels. Default: `self$ncol`.

- `height`:

  Positive integer. Output height in pixels. Default: `self$nrow`.

- `interpolation`:

  Character. One of `"nearest"`, `"linear"`, `"cubic"`, `"area"`,
  `"lanczos4"`. Default `"linear"`.

- `border_type`:

  Character. How to fill pixels outside the image boundary.
  `"reflect_101"` (default) mirrors the image excluding the edge pixel
  (e.g. dcb\|abcde\|dcb); `"reflect"` mirrors including the edge pixel
  (e.g. edcb\|abcde\|edcb); `"replicate"` repeats the nearest edge
  pixel; `"wrap"` tiles the image; `"constant"` fills with a fixed value
  (0, i.e. black).

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    w <- img$ncol; h <- img$nrow
    src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    img$warp_perspective_(perspective_from_points(src, dst))
    img$plot()
    }

------------------------------------------------------------------------

### Method `border()`

Add a border around the image.

The argument order \`(top, left, bottom, right)\` is deliberately
different from the CSS shorthand (\`top, right, bottom, left\`) and from
OpenCV's \`copyMakeBorder\` (\`top, bottom, left, right\`). With this
order, the two-argument form \`\$border(v, h)\` adds \`v\` pixels
vertically (top and bottom) and \`h\` pixels horizontally (left and
right) — the most natural two-argument case for symmetric borders.

#### Usage

    Image$border(
      top,
      left = top,
      bottom = top,
      right = left,
      type = "constant",
      value = 0
    )

#### Arguments

- `top`:

  Integer. Border width in pixels on the top edge.

- `left`:

  Integer. Border width on the left edge. Defaults to \`top\`.

- `bottom`:

  Integer. Border width on the bottom edge. Defaults to \`top\`.

- `right`:

  Integer. Border width on the right edge. Defaults to \`left\`.

- `type`:

  Character. Border fill mode. \`"constant"\` (default) fills with a
  fixed colour (see \`value\`); \`"reflect"\` mirrors the image
  including the edge pixel; \`"reflect_101"\` mirrors excluding the edge
  pixel; \`"replicate"\` repeats the nearest edge pixel; \`"wrap"\`
  tiles the image.

- `value`:

  Numeric vector of length 1 or \`nchan\`. Fill colour used when \`type
  = "constant"\`. Recycled to \`nchan\` values. Default 0 (black).

#### Returns

A new \`Image\`.

------------------------------------------------------------------------

### Method `border_()`

Add a border around the image, in place.

See \`\$border()\` for the rationale behind the argument order \`(top,
left, bottom, right)\`.

#### Usage

    Image$border_(
      top,
      left = top,
      bottom = top,
      right = left,
      type = "constant",
      value = 0
    )

#### Arguments

- `top`:

  Integer. Border width on the top edge.

- `left`:

  Integer. Defaults to \`top\`.

- `bottom`:

  Integer. Defaults to \`top\`.

- `right`:

  Integer. Defaults to \`left\`.

- `type`:

  Character. Border fill mode. \`"constant"\` (default) fills with a
  fixed colour (see \`value\`); \`"reflect"\` mirrors the image
  including the edge pixel; \`"reflect_101"\` mirrors excluding the edge
  pixel; \`"replicate"\` repeats the nearest edge pixel; \`"wrap"\`
  tiles the image.

- `value`:

  Numeric vector of length 1 or \`nchan\`. Fill colour used when \`type
  = "constant"\`. Recycled to \`nchan\` values. Default 0 (black).

#### Returns

\`self\` invisibly.

------------------------------------------------------------------------

### Method `tile()`

Tile (repeat) the image in a grid.

#### Usage

    Image$tile(nrow, ncol = nrow)

#### Arguments

- `nrow`:

  Integer. Number of vertical repetitions.

- `ncol`:

  Integer. Number of horizontal repetitions. Defaults to \`nrow\`.

#### Returns

A new \`Image\` with dimensions \`nrow \* self\$nrow\` x \`ncol \*
self\$ncol\`.

------------------------------------------------------------------------

### Method `tile_()`

Tile (repeat) the image in a grid, in place.

#### Usage

    Image$tile_(nrow, ncol = nrow)

#### Arguments

- `nrow`:

  Integer. Number of vertical repetitions.

- `ncol`:

  Integer. Number of horizontal repetitions. Defaults to \`nrow\`.

#### Returns

\`self\` invisibly.

------------------------------------------------------------------------

### Method `set_to()`

Set all pixels — or only masked pixels — to a constant value.

#### Usage

    Image$set_to(value, mask = NULL)

#### Arguments

- `value`:

  Numeric scalar or vector of length `nchan`. Recycled to `nchan`
  channels. No `NA`s.

- `mask`:

  `NULL` (apply to all pixels) or a single-channel `CV_8U` `Image` with
  the same `nrow` and `ncol`. Non-zero pixels mark where `value` is
  written.

#### Returns

A new `Image`.

------------------------------------------------------------------------

### Method `set_to_()`

Set all pixels — or only masked pixels — to a constant value, in place.

#### Usage

    Image$set_to_(value, mask = NULL)

#### Arguments

- `value`:

  Numeric scalar or vector of length `nchan`. Recycled to `nchan`
  channels. No `NA`s.

- `mask`:

  `NULL` or a single-channel `CV_8U` `Image` same size as `self`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `threshold()`

Apply a threshold to the image.

#### Usage

    Image$threshold(thresh, maxval = 255, type = "binary", bins = 256L)

#### Arguments

- `thresh`:

  Single finite numeric or one of 17 lowercase auto-threshold method
  strings. When numeric, passed directly to OpenCV. When a string, the
  threshold is auto-computed from the image histogram.

- `maxval`:

  Single finite numeric. Value assigned to above-threshold pixels in
  \`"binary"\` and \`"binary_inv"\` modes. Default \`255\`.

- `type`:

  Character. How pixel values are mapped relative to the threshold
  \`T\`. \`"binary"\` (default): above \`T\` → \`maxval\`, at or below
  → 0. \`"binary_inv"\`: above \`T\` → 0, at or below → \`maxval\`.
  \`"trunc"\`: above \`T\` → \`T\`, at or below → unchanged (acts as a
  ceiling). \`"tozero"\`: at or below \`T\` → 0, above → unchanged.
  \`"tozero_inv"\`: above \`T\` → 0, at or below → unchanged. \`maxval\`
  is only used by \`"binary"\` and \`"binary_inv"\`.

- `bins`:

  Single integer \>= 2. Histogram bins for auto-threshold on
  non-\`CV_8U\` images. Ignored when \`thresh\` is numeric or for
  \`CV_8U\`. Default \`256\`.

#### Returns

A new \`Image\`.

------------------------------------------------------------------------

### Method `threshold_()`

Apply a threshold to the image, in place.

#### Usage

    Image$threshold_(thresh, maxval = 255, type = "binary", bins = 256L)

#### Arguments

- `thresh`:

  See \`\$threshold()\`.

- `maxval`:

  See \`\$threshold()\`.

- `type`:

  See \`\$threshold()\` for a description of all five modes.

- `bins`:

  See \`\$threshold()\`.

#### Returns

\`self\` invisibly.

------------------------------------------------------------------------

### Method `adaptive_threshold()`

Apply an adaptive threshold to the image.

#### Usage

    Image$adaptive_threshold(
      maxval = 255,
      method = "mean",
      type = "binary",
      block_size = 11L,
      offset = 2
    )

#### Arguments

- `maxval`:

  Single finite numeric. Value for above-threshold pixels. Default
  \`255\`.

- `method`:

  \`"mean"\` (local neighbourhood mean) or \`"gaussian"\`
  (Gaussian-weighted neighbourhood). Default \`"mean"\`.

- `type`:

  \`"binary"\` (default): pixels above the local threshold → \`maxval\`,
  others → 0. \`"binary_inv"\`: inverted — pixels above → 0, others →
  \`maxval\`.

- `block_size`:

  Single odd integer \>= 3. Neighbourhood size. Default \`11\`.

- `offset`:

  Single finite numeric. Constant subtracted from the local mean
  (OpenCV's \`C\` parameter). May be negative. Default \`2\`.

#### Returns

A new single-channel \`CV_8U\` \`Image\` with colorspace \`"GRAY"\`.

------------------------------------------------------------------------

### Method `adaptive_threshold_()`

Apply an adaptive threshold to the image, in place.

#### Usage

    Image$adaptive_threshold_(
      maxval = 255,
      method = "mean",
      type = "binary",
      block_size = 11L,
      offset = 2
    )

#### Arguments

- `maxval`:

  See \`\$adaptive_threshold()\`.

- `method`:

  See \`\$adaptive_threshold()\`.

- `type`:

  See \`\$adaptive_threshold()\` for a description of both modes.

- `block_size`:

  See \`\$adaptive_threshold()\`.

- `offset`:

  See \`\$adaptive_threshold()\`.

#### Returns

\`self\` invisibly.

------------------------------------------------------------------------

### Method `in_range()`

Create a binary mask where each pixel is 255 if all channels fall within
\`\[lower\[k\], upper\[k\]\]\`, and 0 otherwise.

#### Usage

    Image$in_range(lower, upper)

#### Arguments

- `lower`:

  Numeric vector of length 1 or \`nchan\`. Lower bound per channel.
  Recycled to \`nchan\`. No NAs; all finite.

- `upper`:

  Numeric vector of length 1 or \`nchan\`. Upper bound per channel.
  Recycled to \`nchan\`. No NAs; all finite.

#### Returns

A new single-channel \`CV_8U\` \`Image\` with colorspace \`"GRAY"\`.

------------------------------------------------------------------------

### Method `in_range_()`

Create a binary mask in place. See \`\$in_range()\`.

#### Usage

    Image$in_range_(lower, upper)

#### Arguments

- `lower`:

  See \`\$in_range()\`.

- `upper`:

  See \`\$in_range()\`.

#### Returns

\`self\` invisibly.

------------------------------------------------------------------------

### Method `draw_line()`

Draw a line segment on the image. Returns a new Image.

#### Usage

    Image$draw_line(x1, y1, x2, y2, color, thickness = 1L, line_type = "line_8")

#### Arguments

- `x1`:

  Positive integer. X (column) coordinate of the start point.

- `y1`:

  Positive integer. Y (row) coordinate of the start point.

- `x2`:

  Positive integer. X (column) coordinate of the end point.

- `y2`:

  Positive integer. Y (row) coordinate of the end point.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"` (4-connected), `"line_8"` (8-connected,
  default), `"aa"` (anti-aliased; 8-bit images only).

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_line(1, 1, 100, 100, color = "red")$plot()
    }

------------------------------------------------------------------------

### Method `draw_line_()`

Draw a line segment on the image in place.

#### Usage

    Image$draw_line_(x1, y1, x2, y2, color, thickness = 1L, line_type = "line_8")

#### Arguments

- `x1`:

  Positive integer. X (column) coordinate of the start point.

- `y1`:

  Positive integer. Y (row) coordinate of the start point.

- `x2`:

  Positive integer. X (column) coordinate of the end point.

- `y2`:

  Positive integer. Y (row) coordinate of the end point.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_arrow()`

Draw an arrowed line on the image. Returns a new Image.

#### Usage

    Image$draw_arrow(
      x1,
      y1,
      x2,
      y2,
      color,
      thickness = 1L,
      line_type = "line_8",
      tip_length = 0.1
    )

#### Arguments

- `x1`:

  Positive integer. X coordinate of the arrow tail.

- `y1`:

  Positive integer. Y coordinate of the arrow tail.

- `x2`:

  Positive integer. X coordinate of the arrowhead tip.

- `y2`:

  Positive integer. Y coordinate of the arrowhead tip.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `tip_length`:

  Numeric. Arrowhead length as a proportion of total arrow length.
  Negative values produce a reversed arrowhead. Default `0.1`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_arrow(10, 10, 100, 100, color = "blue")$plot()
    }

------------------------------------------------------------------------

### Method `draw_arrow_()`

Draw an arrowed line on the image in place.

#### Usage

    Image$draw_arrow_(
      x1,
      y1,
      x2,
      y2,
      color,
      thickness = 1L,
      line_type = "line_8",
      tip_length = 0.1
    )

#### Arguments

- `x1`:

  Positive integer. X coordinate of the arrow tail.

- `y1`:

  Positive integer. Y coordinate of the arrow tail.

- `x2`:

  Positive integer. X coordinate of the arrowhead tip.

- `y2`:

  Positive integer. Y coordinate of the arrowhead tip.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `tip_length`:

  Numeric. Arrowhead length as a proportion of total arrow length.
  Default `0.1`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_rectangle()`

Draw a rectangle outline (or filled rectangle) on the image. Returns a
new Image.

#### Usage

    Image$draw_rectangle(
      x1,
      y1,
      x2,
      y2,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x1`:

  Integer. X coordinate of one corner.

- `y1`:

  Integer. Y coordinate of one corner.

- `x2`:

  Integer. X coordinate of the opposite corner.

- `y2`:

  Integer. Y coordinate of the opposite corner.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width in pixels. Ignored when
  `filled = TRUE`. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, draw a filled rectangle. Default `FALSE`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_rectangle(10, 10, 100, 100, color = "blue", filled = TRUE)$plot()
    }

------------------------------------------------------------------------

### Method `draw_rectangle_()`

Draw a rectangle on the image in place.

#### Usage

    Image$draw_rectangle_(
      x1,
      y1,
      x2,
      y2,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x1`:

  Integer. X coordinate of one corner.

- `y1`:

  Integer. Y coordinate of one corner.

- `x2`:

  Integer. X coordinate of the opposite corner.

- `y2`:

  Integer. Y coordinate of the opposite corner.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width. Ignored when `filled = TRUE`. Default
  `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, fill the rectangle. Default `FALSE`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_circle()`

Draw a circle outline (or filled circle) on the image. Returns a new
Image.

#### Usage

    Image$draw_circle(
      x,
      y,
      radius,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x`:

  Integer. X coordinate of the center.

- `y`:

  Integer. Y coordinate of the center.

- `radius`:

  Non-negative integer. Circle radius in pixels.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width. Ignored when `filled = TRUE`. Default
  `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, draw a filled circle. Default `FALSE`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_circle(100, 100, 50, color = "green", filled = TRUE)$plot()
    }

------------------------------------------------------------------------

### Method `draw_circle_()`

Draw a circle on the image in place.

#### Usage

    Image$draw_circle_(
      x,
      y,
      radius,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x`:

  Integer. X coordinate of the center.

- `y`:

  Integer. Y coordinate of the center.

- `radius`:

  Non-negative integer. Circle radius in pixels.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width. Ignored when `filled = TRUE`. Default
  `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, fill the circle. Default `FALSE`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_ellipse()`

Draw an ellipse outline (or filled ellipse) on the image. Returns a new
Image.

#### Usage

    Image$draw_ellipse(
      x,
      y,
      rx,
      ry,
      angle = 0,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x`:

  Integer. X coordinate of the ellipse center.

- `y`:

  Integer. Y coordinate of the ellipse center.

- `rx`:

  Positive integer. Horizontal semi-axis length in pixels (before
  rotation).

- `ry`:

  Positive integer. Vertical semi-axis length in pixels (before
  rotation).

- `angle`:

  Numeric. Rotation of the ellipse in degrees (clockwise). Default `0`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width. Ignored when `filled = TRUE`. Default
  `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, draw a filled ellipse. Default `FALSE`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_ellipse(100, 100, 80L, 40L, angle = 30, color = "red")$plot()
    }

------------------------------------------------------------------------

### Method `draw_ellipse_()`

Draw an ellipse on the image in place.

#### Usage

    Image$draw_ellipse_(
      x,
      y,
      rx,
      ry,
      angle = 0,
      color,
      thickness = 1L,
      line_type = "line_8",
      filled = FALSE
    )

#### Arguments

- `x`:

  Integer. X coordinate of the ellipse center.

- `y`:

  Integer. Y coordinate of the ellipse center.

- `rx`:

  Positive integer. Horizontal semi-axis length in pixels.

- `ry`:

  Positive integer. Vertical semi-axis length in pixels.

- `angle`:

  Numeric. Rotation in degrees. Default `0`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Outline width. Ignored when `filled = TRUE`. Default
  `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

- `filled`:

  Logical. If `TRUE`, fill the ellipse. Default `FALSE`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_arc()`

Draw a partial ellipse arc on the image. Returns a new Image.

#### Usage

    Image$draw_arc(
      x,
      y,
      rx,
      ry,
      angle = 0,
      start_angle,
      end_angle,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `x`:

  Integer. X coordinate of the ellipse center.

- `y`:

  Integer. Y coordinate of the ellipse center.

- `rx`:

  Positive integer. Horizontal semi-axis length in pixels.

- `ry`:

  Positive integer. Vertical semi-axis length in pixels.

- `angle`:

  Numeric. Rotation of the ellipse in degrees. Default `0`.

- `start_angle`:

  Numeric. Start angle of the arc in degrees.

- `end_angle`:

  Numeric. End angle of the arc in degrees. If
  `start_angle > end_angle`, OpenCV swaps them automatically.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_arc(100, 100, 80L, 40L, start_angle = 0, end_angle = 180,
                 color = "red")$plot()
    }

------------------------------------------------------------------------

### Method `draw_arc_()`

Draw a partial ellipse arc on the image in place.

#### Usage

    Image$draw_arc_(
      x,
      y,
      rx,
      ry,
      angle = 0,
      start_angle,
      end_angle,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `x`:

  Integer. X coordinate of the ellipse center.

- `y`:

  Integer. Y coordinate of the ellipse center.

- `rx`:

  Positive integer. Horizontal semi-axis length in pixels.

- `ry`:

  Positive integer. Vertical semi-axis length in pixels.

- `angle`:

  Numeric. Rotation in degrees. Default `0`.

- `start_angle`:

  Numeric. Start angle of the arc in degrees.

- `end_angle`:

  Numeric. End angle of the arc in degrees.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_polyline()`

Draw a polyline (open or closed polygon outline) on the image. Returns a
new Image.

#### Usage

    Image$draw_polyline(
      pts,
      closed = FALSE,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `pts`:

  A numeric matrix with exactly 2 columns (x, y) and at least 2 rows.
  Each row is a vertex.

- `closed`:

  Logical. If `TRUE`, connect the last vertex back to the first. Default
  `FALSE`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width in pixels. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
    img$draw_polyline(pts, closed = TRUE, color = "yellow")$plot()
    }

------------------------------------------------------------------------

### Method `draw_polyline_()`

Draw a polyline on the image in place.

#### Usage

    Image$draw_polyline_(
      pts,
      closed = FALSE,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `pts`:

  A numeric matrix with exactly 2 columns and at least 2 rows.

- `closed`:

  Logical. If `TRUE`, close the polygon. Default `FALSE`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Line width. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `fill_poly()`

Draw a filled polygon on the image. Returns a new Image.

#### Usage

    Image$fill_poly(pts, color, line_type = "line_8")

#### Arguments

- `pts`:

  A numeric matrix with exactly 2 columns (x, y) and at least 3 rows.
  Each row is a vertex.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
    img$fill_poly(pts, color = "cyan")$plot()
    }

------------------------------------------------------------------------

### Method `fill_poly_()`

Draw a filled polygon on the image in place.

#### Usage

    Image$fill_poly_(pts, color, line_type = "line_8")

#### Arguments

- `pts`:

  A numeric matrix with exactly 2 columns and at least 3 rows.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `draw_text()`

Draw text on the image. Returns a new Image.

#### Usage

    Image$draw_text(
      text,
      x,
      y,
      font = "simplex",
      font_size = 1,
      italic = FALSE,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `text`:

  Character. The string to draw.

- `x`:

  Integer. X coordinate of the bottom-left corner of the text bounding
  box.

- `y`:

  Integer. Y coordinate of the bottom-left corner of the text bounding
  box.

- `font`:

  Character. One of `"simplex"` (default), `"plain"`, `"duplex"`,
  `"complex"`, `"triplex"`, `"complex_small"`, `"script_simplex"`,
  `"script_complex"`.

- `font_size`:

  Numeric. Scale factor applied to the base font size. Negative values
  mirror/reverse the text. Default `1`.

- `italic`:

  Logical. If `TRUE`, use the italic variant of the font. Default
  `FALSE`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Character stroke width. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)
    img$draw_text("Hello", 10, 50, font = "duplex", font_size = 1.5,
                  color = "white")$plot()
    }

------------------------------------------------------------------------

### Method `draw_text_()`

Draw text on the image in place.

#### Usage

    Image$draw_text_(
      text,
      x,
      y,
      font = "simplex",
      font_size = 1,
      italic = FALSE,
      color,
      thickness = 1L,
      line_type = "line_8"
    )

#### Arguments

- `text`:

  Character. The string to draw.

- `x`:

  Integer. X coordinate of the bottom-left corner of the text.

- `y`:

  Integer. Y coordinate of the bottom-left corner of the text.

- `font`:

  Character. Font face name. Default `"simplex"`.

- `font_size`:

  Numeric. Scale factor. Negative mirrors the text. Default `1`.

- `italic`:

  Logical. Italic variant. Default `FALSE`.

- `color`:

  An R color name, hex string, or numeric BGR(A) vector.

- `thickness`:

  Positive integer. Stroke width. Default `1L`.

- `line_type`:

  Character. One of `"line_4"`, `"line_8"` (default), `"aa"`.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`hist()`](https://rdrr.io/r/graphics/hist.html)

Compute a per-channel histogram of pixel values.

#### Usage

    Image$hist(bins = 256L, range = NULL, freq = TRUE)

#### Arguments

- `bins`:

  Single positive integer. Number of histogram bins. Default `256`.

- `range`:

  Length-2 numeric vector `c(lo, hi)` giving the pixel-value range to
  histogram. `NULL` (default) applies a depth-appropriate default and
  emits a message.

- `freq`:

  Logical. `TRUE` (default): `count` column contains raw pixel counts
  (consistent with base R `hist(freq = TRUE)`). `FALSE`: `count` column
  contains probability densities (counts / (total_pixels \* bin_width)).

#### Returns

A tidy data frame with columns `bin_center` (double), `channel`
(character), and `count` (double). One row per bin per channel, ordered
by channel then ascending `bin_center`.

#### Examples

    \donttest{
    img_path <- system.file("img", "flower.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    h <- img$hist(bins = 256L, range = c(0, 256))
    # plot with ggplot2:
    # ggplot2::ggplot(h, ggplot2::aes(x = bin_center, y = count)) +
    #   ggplot2::geom_col()
    }

------------------------------------------------------------------------

### Method `hist_eq()`

Apply global histogram equalization. Returns a new Image. Requires a
single-channel `CV_8U` image. For multi-channel images, use
[`split_channels()`](https://swarm-lab.github.io/Retina/reference/split_channels.md)
then apply per channel.

#### Usage

    Image$hist_eq()

#### Returns

A new `CV_8U` single-channel `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    eq  <- img$hist_eq()
    eq$plot()
    }

------------------------------------------------------------------------

### Method `hist_eq_()`

Apply global histogram equalization in place. Requires a single-channel
`CV_8U` image.

#### Usage

    Image$hist_eq_()

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    img$hist_eq_()
    img$plot()
    }

------------------------------------------------------------------------

### Method `hist_match()`

Match the histogram of this image to a reference histogram. Returns a
new Image. Requires a single-channel `CV_8U` image.

#### Usage

    Image$hist_match(ref)

#### Arguments

- `ref`:

  A data frame as produced by `$hist(bins = 256L)` with columns
  `bin_center`, `channel`, and `count`. Must have exactly 256 rows (one
  per 8-bit value).

#### Returns

A new `CV_8U` single-channel `Image`.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    ref_path <- system.file("img", "flower.jpg",     package = "Retina")
    src <- Image$new(img_path)$to_gray()
    ref <- Image$new(ref_path)$to_gray()
    ref_hist <- ref$hist(bins = 256L, range = c(0, 255))
    out <- src$hist_match(ref_hist)
    out$plot()
    }

------------------------------------------------------------------------

### Method `hist_match_()`

Match the histogram of this image to a reference, in place.

#### Usage

    Image$hist_match_(ref)

#### Arguments

- `ref`:

  See `$hist_match()`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    ref_path <- system.file("img", "flower.jpg",     package = "Retina")
    src <- Image$new(img_path)$to_gray()
    ref <- Image$new(ref_path)$to_gray()
    ref_hist <- ref$hist(bins = 256L, range = c(0, 256))
    src$hist_match_(ref_hist)
    src$plot()
    }

------------------------------------------------------------------------

### Method `CLAHE()`

Apply Contrast Limited Adaptive Histogram Equalization (CLAHE). Returns
a new Image. Requires a single-channel `CV_8U` or `CV_16U` image.

#### Usage

    Image$CLAHE(clip_limit = 40, tile_grid_size = c(8L, 8L))

#### Arguments

- `clip_limit`:

  Single positive numeric. Threshold for contrast limiting — higher
  values allow more contrast enhancement, lower values reduce noise
  amplification. Default `40.0`.

- `tile_grid_size`:

  Length-1 or length-2 positive integer vector `c(width, height)`.
  Number of tiles in each direction. A scalar `n` is recycled to
  `c(n, n)` for square tiles. Default `c(8L, 8L)`.

#### Returns

A new `Image` of the same depth as the input.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    out <- img$CLAHE(clip_limit = 2.0, tile_grid_size = c(8L, 8L))
    out$plot()
    }

------------------------------------------------------------------------

### Method `CLAHE_()`

Apply CLAHE in place. See `$CLAHE()` for details.

#### Usage

    Image$CLAHE_(clip_limit = 40, tile_grid_size = c(8L, 8L))

#### Arguments

- `clip_limit`:

  See `$CLAHE()`.

- `tile_grid_size`:

  See `$CLAHE()`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    img$CLAHE_(clip_limit = 2.0, tile_grid_size = c(8L, 8L))
    img$plot()
    }

------------------------------------------------------------------------

### Method `minmax_loc()`

Find the minimum and maximum pixel values and their locations in a
single-channel image.

#### Usage

    Image$minmax_loc()

#### Returns

A named list with six elements: `min_val` (double), `min_row` (integer),
`min_col` (integer), `max_val` (double), `max_row` (integer), `max_col`
(integer). All coordinates are 1-based. When multiple pixels share the
minimum or maximum value, the first occurrence in row-major order is
returned. For multi-channel images, use
[`split_channels()`](https://swarm-lab.github.io/Retina/reference/split_channels.md)
first.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()
    loc <- img$minmax_loc()
    cat("Max pixel:", loc$max_val, "at row", loc$max_row, "col", loc$max_col)
    }

------------------------------------------------------------------------

### Method `count_nonzero()`

Count non-zero pixels in a single-channel image.

#### Usage

    Image$count_nonzero()

#### Returns

A single integer.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()$threshold(128)
    n <- img$count_nonzero()
    # Multi-channel: split then apply
    color_img <- Image$new(img_path)
    counts <- lapply(split_channels(color_img), \(ch) ch$count_nonzero())
    }

------------------------------------------------------------------------

### Method `find_nonzero()`

Find the coordinates of all non-zero pixels in a single-channel image.

#### Usage

    Image$find_nonzero()

#### Returns

A data frame with integer columns `row` and `col` (1-based, R matrix
convention), ordered in row-major order. Returns a zero-row data frame
when no non-zero pixels exist.

#### Examples

    \donttest{
    img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    img <- Image$new(img_path)$to_gray()$threshold(128)
    coords <- img$find_nonzero()
    head(coords)
    # Multi-channel: split then apply
    color_img <- Image$new(img_path)
    all_coords <- lapply(split_channels(color_img), \(ch) ch$find_nonzero())
    }

------------------------------------------------------------------------

### Method `pow()`

Raise every pixel to a power element-wise. The image must be `CV_32F` or
`CV_64F` — use `$convert_depth("CV_32F")` first for integer images. A
negative pixel raised to a fractional exponent produces `NaN`.

#### Usage

    Image$pow(power)

#### Arguments

- `power`:

  Single finite numeric. The exponent. Negative, zero, and fractional
  values are accepted.

#### Returns

A new `Image` with the same depth and colorspace.

#### Examples

    \donttest{
    img32 <- Image$new(array(4.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
    img32$pow(2.0)
    }

------------------------------------------------------------------------

### Method `pow_()`

Raise every pixel to a power, in place.

#### Usage

    Image$pow_(power)

#### Arguments

- `power`:

  Single finite numeric. The exponent.

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`exp()`](https://rdrr.io/r/base/Log.html)

Apply element-wise natural exponential (\\e^x\\) to every pixel. The
image must be `CV_32F` or `CV_64F`.

#### Usage

    Image$exp()

#### Returns

A new `Image` with the same depth and colorspace.

#### Examples

    \donttest{
    img32 <- Image$new(array(1.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
    img32$exp()
    }

------------------------------------------------------------------------

### Method `exp_()`

Apply element-wise natural exponential in place.

#### Usage

    Image$exp_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`log()`](https://rdrr.io/r/base/Log.html)

Apply element-wise natural logarithm (\\\ln(x)\\) to every pixel. The
image must be `CV_32F` or `CV_64F`. Pixels \\\le 0\\ produce `-Inf` or
`NaN` — sanitise the image first if this may occur.

#### Usage

    Image$log()

#### Returns

A new `Image` with the same depth and colorspace.

#### Examples

    \donttest{
    img32 <- Image$new(array(exp(1), dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
    img32$log()
    }

------------------------------------------------------------------------

### Method `log_()`

Apply element-wise natural logarithm in place.

#### Usage

    Image$log_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method [`sqrt()`](https://rdrr.io/r/base/MathFun.html)

Apply element-wise square root to every pixel. The image must be
`CV_32F` or `CV_64F`. Pixels `< 0` produce `NaN` — sanitise the image
first if this may occur.

#### Usage

    Image$sqrt()

#### Returns

A new `Image` with the same depth and colorspace.

#### Examples

    \donttest{
    img32 <- Image$new(array(9.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
    img32$sqrt()
    }

------------------------------------------------------------------------

### Method `sqrt_()`

Apply element-wise square root in place.

#### Usage

    Image$sqrt_()

#### Returns

`self` invisibly.

------------------------------------------------------------------------

### Method `extract_channel()`

Extract a single channel as a new single-channel `Image`.

#### Usage

    Image$extract_channel(k)

#### Arguments

- `k`:

  Single integer (1-based). Channel index between 1 and `nchan`.

#### Returns

A new single-channel `Image` with colorspace `"GRAY"`.

#### Examples

    \donttest{
    img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                           dim = c(10L, 10L, 3L)), "BGR")
    img$extract_channel(2L)  # green channel
    }

------------------------------------------------------------------------

### Method `insert_channel()`

Insert a single-channel `Image` into channel `k`, returning a new
`Image`.

#### Usage

    Image$insert_channel(ch, k)

#### Arguments

- `ch`:

  A single-channel `Image` with the same depth, `nrow`, and `ncol` as
  `self`.

- `k`:

  Single integer (1-based). Channel index between 1 and `nchan`.

#### Returns

A new `Image` with the same colorspace as `self`.

#### Examples

    \donttest{
    img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                           dim = c(10L, 10L, 3L)), "BGR")
    new_ch <- Image$new(array(99L, dim = c(10L, 10L, 1L)), "GRAY")
    img$insert_channel(new_ch, 2L)
    }

------------------------------------------------------------------------

### Method `insert_channel_()`

Insert a single-channel `Image` into channel `k`, in place.

#### Usage

    Image$insert_channel_(ch, k)

#### Arguments

- `ch`:

  A single-channel `Image` with the same depth, `nrow`, and `ncol` as
  `self`.

- `k`:

  Single integer (1-based). Channel index between 1 and `nchan`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                           dim = c(10L, 10L, 3L)), "BGR")
    new_ch <- Image$new(array(99L, dim = c(10L, 10L, 1L)), "GRAY")
    img$insert_channel_(new_ch, 2L)
    }

------------------------------------------------------------------------

### Method `LUT()`

Apply a lookup table (LUT) to remap pixel values.

#### Usage

    Image$LUT(lut)

#### Arguments

- `lut`:

  A numeric vector of length 256 (`CV_8U`) or 65536 (`CV_16U`/`CV_16S`),
  applied identically to all channels; or a numeric matrix with the same
  row count and `nchan` columns — one column per channel applied in
  channel order. Values must be non-`NA`, finite, and coercible to
  integer. Only integer-depth images are supported (`CV_8U`, `CV_16U`,
  `CV_16S`). For `CV_16S` sources the LUT index is `pixel + 32768`:
  pixel `-32768` maps to row 1 (index 0); pixel `0` maps to row 32769.

#### Returns

A new `Image`.

#### Examples

    \donttest{
    img <- Image$new(array(100L, dim = c(5L, 5L, 1L)), "GRAY")
    img$LUT(as.integer(255:0))  # invert
    }

------------------------------------------------------------------------

### Method `LUT_()`

Apply a lookup table in place.

#### Usage

    Image$LUT_(lut)

#### Arguments

- `lut`:

  See `$LUT()`.

#### Returns

`self` invisibly.

#### Examples

    \donttest{
    img <- Image$new(array(100L, dim = c(5L, 5L, 1L)), "GRAY")
    img$LUT_(as.integer(255:0))  # invert in place
    }

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the image.

#### Usage

    Image$print(...)

#### Arguments

- `...`:

  Ignored.

#### Returns

`self` invisibly.

## Examples

``` r

## ------------------------------------------------
## Method `Image$sobel`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)
grad_x <- img$sobel(1, 0)
#> ddepth not specified; using "CV_16S" for a CV_8U image.
grad_x$plot()

# }

## ------------------------------------------------
## Method `Image$sobel_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)
img$sobel_(1, 0)
#> ddepth not specified; using "CV_16S" for a CV_8U image.
img$plot()

# }

## ------------------------------------------------
## Method `Image$laplacian`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
edges <- img$laplacian()
#> ddepth not specified; using "CV_16S" for a CV_8U image.
edges$plot()

# }

## ------------------------------------------------
## Method `Image$laplacian_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$laplacian_()
#> ddepth not specified; using "CV_16S" for a CV_8U image.
img$plot()

# }

## ------------------------------------------------
## Method `Image$canny`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "staircase.jpg", package = "Retina")
img <- Image$new(img_path)$convert_color("GRAY")
edges <- img$canny(50, 150)
edges$plot()

# }

## ------------------------------------------------
## Method `Image$canny_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "staircase.jpg", package = "Retina")
img <- Image$new(img_path)$convert_color("GRAY")
img$canny_(50, 150)
img$plot()

# }

## ------------------------------------------------
## Method `Image$scharr`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)
grad_x <- img$scharr(1, 0)
#> ddepth not specified; using "CV_16S" for a CV_8U image.
grad_x$plot()

# }

## ------------------------------------------------
## Method `Image$scharr_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)
img$scharr_(1, 0)
#> ddepth not specified; using "CV_16S" for a CV_8U image.
img$plot()

# }

## ------------------------------------------------
## Method `Image$filter2D`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
sharpened <- img$filter2D(sharpen)
sharpened$plot()

# }

## ------------------------------------------------
## Method `Image$filter2D_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
img$filter2D_(sharpen)
img$plot()

# }

## ------------------------------------------------
## Method `Image$sep_filter2D`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
blurred <- img$sep_filter2D(rep(1/3, 3), rep(1/3, 3))
blurred$plot()

# }

## ------------------------------------------------
## Method `Image$sep_filter2D_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$sep_filter2D_(rep(1/3, 3), rep(1/3, 3))
img$plot()

# }

## ------------------------------------------------
## Method `Image$morph`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)$convert_color("GRAY")
eroded <- img$morph("erode")
eroded$plot()

# }

## ------------------------------------------------
## Method `Image$morph_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)$convert_color("GRAY")
img$morph_("erode")
img$plot()

# }

## ------------------------------------------------
## Method `Image$resize`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$resize(width = 320L, height = 240L)$plot()

img$resize(fx = 0.5, fy = 0.5)$plot()

# }

## ------------------------------------------------
## Method `Image$resize_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$resize_(fx = 0.5, fy = 0.5)
img$plot()

# }

## ------------------------------------------------
## Method `Image$rotate`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$rotate(45)$plot()

# }

## ------------------------------------------------
## Method `Image$rotate_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$rotate_(45)
img$plot()

# }

## ------------------------------------------------
## Method `Image$flip`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$flip(flip_h = TRUE)$plot()

# }

## ------------------------------------------------
## Method `Image$flip_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$flip_(flip_v = TRUE)
img$plot()

# }

## ------------------------------------------------
## Method `Image$crop`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$crop(1L, 1L, 100L, 100L)$plot()

# }

## ------------------------------------------------
## Method `Image$crop_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$crop_(1L, 1L, 100L, 100L)
img$plot()

# }

## ------------------------------------------------
## Method `Image$warp_affine`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
m <- affine_translate(50, 30)
img$warp_affine(m)$plot()

# }

## ------------------------------------------------
## Method `Image$warp_affine_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$warp_affine_(affine_translate(50, 30))
img$plot()

# }

## ------------------------------------------------
## Method `Image$warp_perspective`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
w <- img$ncol; h <- img$nrow
src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
m <- perspective_from_points(src, dst)
img$warp_perspective(m)$plot()

# }

## ------------------------------------------------
## Method `Image$warp_perspective_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
w <- img$ncol; h <- img$nrow
src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
img$warp_perspective_(perspective_from_points(src, dst))
img$plot()

# }

## ------------------------------------------------
## Method `Image$draw_line`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_line(1, 1, 100, 100, color = "red")$plot()

# }

## ------------------------------------------------
## Method `Image$draw_arrow`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_arrow(10, 10, 100, 100, color = "blue")$plot()

# }

## ------------------------------------------------
## Method `Image$draw_rectangle`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_rectangle(10, 10, 100, 100, color = "blue", filled = TRUE)$plot()

# }

## ------------------------------------------------
## Method `Image$draw_circle`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_circle(100, 100, 50, color = "green", filled = TRUE)$plot()

# }

## ------------------------------------------------
## Method `Image$draw_ellipse`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_ellipse(100, 100, 80L, 40L, angle = 30, color = "red")$plot()

# }

## ------------------------------------------------
## Method `Image$draw_arc`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_arc(100, 100, 80L, 40L, start_angle = 0, end_angle = 180,
             color = "red")$plot()

# }

## ------------------------------------------------
## Method `Image$draw_polyline`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
img$draw_polyline(pts, closed = TRUE, color = "yellow")$plot()

# }

## ------------------------------------------------
## Method `Image$fill_poly`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
img$fill_poly(pts, color = "cyan")$plot()

# }

## ------------------------------------------------
## Method `Image$draw_text`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)
img$draw_text("Hello", 10, 50, font = "duplex", font_size = 1.5,
              color = "white")$plot()

# }

## ------------------------------------------------
## Method `Image$hist`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "flower.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
h <- img$hist(bins = 256L, range = c(0, 256))
# plot with ggplot2:
# ggplot2::ggplot(h, ggplot2::aes(x = bin_center, y = count)) +
#   ggplot2::geom_col()
# }

## ------------------------------------------------
## Method `Image$hist_eq`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
eq  <- img$hist_eq()
eq$plot()

# }

## ------------------------------------------------
## Method `Image$hist_eq_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
img$hist_eq_()
img$plot()

# }

## ------------------------------------------------
## Method `Image$hist_match`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
ref_path <- system.file("img", "flower.jpg",     package = "Retina")
src <- Image$new(img_path)$to_gray()
ref <- Image$new(ref_path)$to_gray()
ref_hist <- ref$hist(bins = 256L, range = c(0, 255))
out <- src$hist_match(ref_hist)
out$plot()

# }

## ------------------------------------------------
## Method `Image$hist_match_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
ref_path <- system.file("img", "flower.jpg",     package = "Retina")
src <- Image$new(img_path)$to_gray()
ref <- Image$new(ref_path)$to_gray()
ref_hist <- ref$hist(bins = 256L, range = c(0, 256))
src$hist_match_(ref_hist)
src$plot()

# }

## ------------------------------------------------
## Method `Image$CLAHE`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
out <- img$CLAHE(clip_limit = 2.0, tile_grid_size = c(8L, 8L))
out$plot()

# }

## ------------------------------------------------
## Method `Image$CLAHE_`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
img$CLAHE_(clip_limit = 2.0, tile_grid_size = c(8L, 8L))
img$plot()

# }

## ------------------------------------------------
## Method `Image$minmax_loc`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()
loc <- img$minmax_loc()
cat("Max pixel:", loc$max_val, "at row", loc$max_row, "col", loc$max_col)
#> Max pixel: 255 at row 10 col 350
# }

## ------------------------------------------------
## Method `Image$count_nonzero`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()$threshold(128)
n <- img$count_nonzero()
# Multi-channel: split then apply
color_img <- Image$new(img_path)
counts <- lapply(split_channels(color_img), \(ch) ch$count_nonzero())
# }

## ------------------------------------------------
## Method `Image$find_nonzero`
## ------------------------------------------------

# \donttest{
img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
img <- Image$new(img_path)$to_gray()$threshold(128)
coords <- img$find_nonzero()
head(coords)
#>   row col
#> 1   1   1
#> 2   1   2
#> 3   1   3
#> 4   1   4
#> 5   1   5
#> 6   1   6
# Multi-channel: split then apply
color_img <- Image$new(img_path)
all_coords <- lapply(split_channels(color_img), \(ch) ch$find_nonzero())
# }

## ------------------------------------------------
## Method `Image$pow`
## ------------------------------------------------

# \donttest{
img32 <- Image$new(array(4.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
img32$pow(2.0)
#> <Image>
#>   Size      : 5 x 5 
#>   Channels  : 1 
#>   Depth     : CV_32F 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$exp`
## ------------------------------------------------

# \donttest{
img32 <- Image$new(array(1.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
img32$exp()
#> <Image>
#>   Size      : 5 x 5 
#>   Channels  : 1 
#>   Depth     : CV_32F 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$log`
## ------------------------------------------------

# \donttest{
img32 <- Image$new(array(exp(1), dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
img32$log()
#> <Image>
#>   Size      : 5 x 5 
#>   Channels  : 1 
#>   Depth     : CV_32F 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$sqrt`
## ------------------------------------------------

# \donttest{
img32 <- Image$new(array(9.0, dim = c(5L, 5L, 1L)), "GRAY", depth = "CV_32F")
img32$sqrt()
#> <Image>
#>   Size      : 5 x 5 
#>   Channels  : 1 
#>   Depth     : CV_32F 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$extract_channel`
## ------------------------------------------------

# \donttest{
img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                       dim = c(10L, 10L, 3L)), "BGR")
#> Depth not specified. Defaulting to CV_8U.
img$extract_channel(2L)  # green channel
#> <Image>
#>   Size      : 10 x 10 
#>   Channels  : 1 
#>   Depth     : CV_8U 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$insert_channel`
## ------------------------------------------------

# \donttest{
img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                       dim = c(10L, 10L, 3L)), "BGR")
#> Depth not specified. Defaulting to CV_8U.
new_ch <- Image$new(array(99L, dim = c(10L, 10L, 1L)), "GRAY")
#> Depth not specified. Defaulting to CV_8U.
img$insert_channel(new_ch, 2L)
#> <Image>
#>   Size      : 10 x 10 
#>   Channels  : 3 
#>   Depth     : CV_8U 
#>   Colorspace: BGR 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$insert_channel_`
## ------------------------------------------------

# \donttest{
img <- Image$new(array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
                       dim = c(10L, 10L, 3L)), "BGR")
#> Depth not specified. Defaulting to CV_8U.
new_ch <- Image$new(array(99L, dim = c(10L, 10L, 1L)), "GRAY")
#> Depth not specified. Defaulting to CV_8U.
img$insert_channel_(new_ch, 2L)
# }

## ------------------------------------------------
## Method `Image$LUT`
## ------------------------------------------------

# \donttest{
img <- Image$new(array(100L, dim = c(5L, 5L, 1L)), "GRAY")
#> Depth not specified. Defaulting to CV_8U.
img$LUT(as.integer(255:0))  # invert
#> <Image>
#>   Size      : 5 x 5 
#>   Channels  : 1 
#>   Depth     : CV_8U 
#>   Colorspace: GRAY 
#>   GPU       : FALSE 
# }

## ------------------------------------------------
## Method `Image$LUT_`
## ------------------------------------------------

# \donttest{
img <- Image$new(array(100L, dim = c(5L, 5L, 1L)), "GRAY")
#> Depth not specified. Defaulting to CV_8U.
img$LUT_(as.integer(255:0))  # invert in place
# }
```
