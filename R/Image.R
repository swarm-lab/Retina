#' @export
dim.Image <- function(x) c(x$nrow, x$ncol, x$nchan)

#' Image class
#'
#' An R6 class representing a single image, backed by an OpenCV \code{cv::Mat}
#' (CPU) or \code{cv::UMat} (GPU).
#'
#' @export
Image <- R6::R6Class("Image",
  cloneable = FALSE,
  private = list(
    .ptr = NULL
  ),
  active = list(
    #' @field nrow Number of rows (height in pixels).
    nrow = function() rt_image_nrow(private$.ptr),

    #' @field ncol Number of columns (width in pixels).
    ncol = function() rt_image_ncol(private$.ptr),

    #' @field nchan Number of channels.
    nchan = function() rt_image_nchan(private$.ptr),

    #' @field depth Bit depth code (0=CV_8U, 1=CV_8S, 2=CV_16U, ...).
    depth = function() rt_image_depth(private$.ptr),

    #' @field depth_name Human-readable depth string (e.g. \code{"CV_8U"}).
    depth_name = function() {
      c("CV_8U", "CV_8S", "CV_16U", "CV_16S",
        "CV_32S", "CV_32F", "CV_64F", "CV_16F")[rt_image_depth(private$.ptr) + 1L]
    },

    #' @field gpu Logical; TRUE if the image is currently on the GPU.
    gpu = function() rt_image_is_gpu(private$.ptr),

    #' @field colorspace Character string describing the color space (e.g. "BGR", "GRAY").
    colorspace = function(value) {
      if (missing(value)) {
        rt_image_colorspace(private$.ptr)
      } else {
        rt_image_set_colorspace(private$.ptr, value)
        invisible(self)
      }
    }
  ),
  public = list(
    #' @description Create a new Image.
    #' @param x A file path (character), a 3D array (nrow x ncol x nchan), or a
    #'   2D matrix. Use an integer array for integer depths (\code{CV_8U},
    #'   \code{CV_16U}, \code{CV_16S}) and a double array for float depths
    #'   (\code{CV_32F}, \code{CV_64F}).
    #' @param colorspace Color space label string. Ignored when reading from file
    #'   (OpenCV assumes BGR for color images).
    #' @param depth Character. Bit depth of the image. One of \code{"CV_8U"},
    #'   \code{"CV_16U"}, \code{"CV_16S"}, \code{"CV_32F"}, \code{"CV_64F"}.
    #'   If \code{NULL} (default), inferred from the array type: integer arrays
    #'   default to \code{"CV_8U"}, double arrays to \code{"CV_32F"}, and a
    #'   message is emitted. Ignored when \code{x} is a file path or external
    #'   pointer.
    initialize = function(x, colorspace = "BGR", depth = NULL) {
      .valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")
      .int_depths   <- c("CV_8U", "CV_16U", "CV_16S")
      .dbl_depths   <- c("CV_32F", "CV_64F")
      if (is.character(x)) {
        private$.ptr <- rt_image_read(path.expand(x))
      } else if (is.array(x) || is.matrix(x)) {
        if (is.double(x)) {
          if (is.null(depth)) {
            depth <- "CV_32F"
            message("Depth not specified. Defaulting to CV_32F.")
          }
          if (!depth %in% .valid_depths)
            stop("depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
                 call. = FALSE)
          if (depth %in% .int_depths)
            stop("use an integer array for integer depths (CV_8U, CV_16U, CV_16S)",
                 call. = FALSE)
          private$.ptr <- rt_image_from_double_array(x, colorspace, depth)
        } else {
          if (!is.integer(x)) storage.mode(x) <- "integer"
          if (is.null(depth)) {
            depth <- "CV_8U"
            message("Depth not specified. Defaulting to CV_8U.")
          }
          if (!depth %in% .valid_depths)
            stop("depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
                 call. = FALSE)
          if (depth %in% .dbl_depths)
            stop("use a double array for float depths (CV_32F, CV_64F)",
                 call. = FALSE)
          private$.ptr <- rt_image_from_integer_array(x, colorspace, depth)
        }
      } else if (inherits(x, "externalptr")) {
        private$.ptr <- x
      } else {
        stop("x must be a file path (character), an array/matrix, or an external pointer.",
             call. = FALSE)
      }
    },

    #' @description Convert the image to an array (nrow x ncol x nchan).
    #'   Returns an integer array for \code{CV_8U}, \code{CV_16U}, and
    #'   \code{CV_16S} images; a double array for \code{CV_32F} and
    #'   \code{CV_64F} images.
    #' @return An array with dimensions \code{[nrow, ncol, nchan]}.
    to_array = function() {
      if (self$depth %in% c(0L, 2L, 3L)) {
        rt_image_to_integer_array(private$.ptr)
      } else {
        rt_image_to_double_array(private$.ptr)
      }
    },

    #' @description Convert the image to a \code{nativeRaster} object.
    #' @return A \code{nativeRaster} matrix suitable for use with \code{grid} or other graphics systems.
    to_native_raster = function() {
      rt_image_to_native_raster(private$.ptr)
    },

    #' @description Display the image using R's graphics device.
    #' @param newpage Logical. If \code{TRUE} (default), clears the graphics
    #'   device before drawing. Set to \code{FALSE} when composing multiple
    #'   images in a layout using \code{grid} viewports.
    #' @param ... Additional arguments passed to \code{grid::grid.raster()}.
    #' @return \code{self} invisibly.
    plot = function(newpage = TRUE, ...) {
      nr <- self$to_native_raster()
      if (newpage) grid::grid.newpage()
      grid::grid.raster(nr, ...)
      invisible(self)
    },

    #' @description Write the image to a file. Format is inferred from the file extension.
    #' @param path Character. Output file path (e.g. \code{"output.png"}, \code{"output.jpg"}).
    #' @return \code{self} invisibly.
    write = function(path) {
      rt_image_write(private$.ptr, path.expand(path))
      invisible(self)
    },

    #' @description Upload the image to GPU memory (cv::UMat). No-op if already on GPU.
    #' @return \code{self} invisibly.
    to_gpu = function() {
      rt_image_to_gpu(private$.ptr)
      invisible(self)
    },

    #' @description Download the image from GPU to CPU memory (cv::Mat). No-op if already on CPU.
    #' @return \code{self} invisibly.
    to_cpu = function() {
      rt_image_to_cpu(private$.ptr)
      invisible(self)
    },

    #' @description Create a deep copy of this image.
    #' @return A new \code{Image} with independent C++ storage.
    copy = function() {
      Image$new(rt_image_clone(private$.ptr))
    },

    #' @description Convert to a new color space. Returns a new Image.
    #' @param to Character. Target color space (e.g. \code{"GRAY"}, \code{"HSV"}).
    #' @return A new \code{Image}.
    convert_color = function(to) {
      Image$new(rt_image_convert_color(private$.ptr, self$colorspace, to))
    },

    #' @description Convert to a new color space in place.
    #' @param to Character. Target color space.
    #' @return \code{self} invisibly.
    convert_color_ = function(to) {
      private$.ptr <- rt_image_convert_color(private$.ptr, self$colorspace, to)
      invisible(self)
    },

    #' @description Convert to a new bit depth. Returns a new Image.
    #'   Values are cast directly with no scaling: a CV_8U pixel with value 100
    #'   becomes 100.0 in CV_32F, not 0.392. Use \code{convert_depth} followed
    #'   by arithmetic if you need normalized floating-point values.
    #' @param to Character. Target depth, one of \code{"CV_8U"}, \code{"CV_16U"},
    #'   \code{"CV_16S"}, \code{"CV_32F"}, \code{"CV_64F"}.
    #' @return A new \code{Image}.
    convert_depth = function(to) {
      if (!to %in% c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F"))
        stop("depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
             call. = FALSE)
      Image$new(rt_image_convert_depth(private$.ptr, to))
    },

    #' @description Convert to a new bit depth in place.
    #'   Values are cast directly with no scaling (see \code{convert_depth}).
    #' @param to Character. Target depth, one of \code{"CV_8U"}, \code{"CV_16U"},
    #'   \code{"CV_16S"}, \code{"CV_32F"}, \code{"CV_64F"}.
    #' @return \code{self} invisibly.
    convert_depth_ = function(to) {
      if (!to %in% c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F"))
        stop("depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
             call. = FALSE)
      private$.ptr <- rt_image_convert_depth(private$.ptr, to)
      invisible(self)
    },

    #' @description Convert to grayscale. Returns a new Image.
    #' @return A new \code{Image} with colorspace \code{"GRAY"}.
    to_gray = function() Image$new(rt_image_convert_color(private$.ptr, self$colorspace, "GRAY")),

    #' @description Convert to grayscale in place.
    #' @return \code{self} invisibly.
    to_gray_ = function() {
      private$.ptr <- rt_image_convert_color(private$.ptr, self$colorspace, "GRAY")
      invisible(self)
    },

    #' @description Convert to BGR. Returns a new Image.
    #' @return A new \code{Image} with colorspace \code{"BGR"}.
    to_bgr = function() Image$new(rt_image_convert_color(private$.ptr, self$colorspace, "BGR")),

    #' @description Convert to BGR in place.
    #' @return \code{self} invisibly.
    to_bgr_ = function() {
      private$.ptr <- rt_image_convert_color(private$.ptr, self$colorspace, "BGR")
      invisible(self)
    },

    #' @description Convert to HSV. Returns a new Image.
    #' @return A new \code{Image} with colorspace \code{"HSV"}.
    to_hsv = function() Image$new(rt_image_convert_color(private$.ptr, self$colorspace, "HSV")),

    #' @description Convert to HSV in place.
    #' @return \code{self} invisibly.
    to_hsv_ = function() {
      private$.ptr <- rt_image_convert_color(private$.ptr, self$colorspace, "HSV")
      invisible(self)
    },

    #' @description Convert to LAB color space. Returns a new Image.
    #' @return A new \code{Image} with colorspace \code{"LAB"}.
    to_lab = function() Image$new(rt_image_convert_color(private$.ptr, self$colorspace, "LAB")),

    #' @description Convert to LAB color space in place.
    #' @return \code{self} invisibly.
    to_lab_ = function() {
      private$.ptr <- rt_image_convert_color(private$.ptr, self$colorspace, "LAB")
      invisible(self)
    },

    #' @description Per-channel mean pixel value.
    #' @return Named numeric vector of length \code{nchan}.
    mean = function() {
      setNames(rt_image_mean(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel minimum pixel value.
    #' @return Named numeric vector of length \code{nchan}.
    min = function() {
      setNames(rt_image_min(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel maximum pixel value.
    #' @return Named numeric vector of length \code{nchan}.
    max = function() {
      setNames(rt_image_max(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel standard deviation (population).
    #' @return Named numeric vector of length \code{nchan}.
    sd = function() {
      setNames(rt_image_sd(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel variance (population).
    #' @return Named numeric vector of length \code{nchan}.
    var = function() {
      setNames(rt_image_var(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel pixel sum.
    #' @return Named numeric vector of length \code{nchan}.
    sum = function() {
      setNames(rt_image_sum(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel median pixel value.
    #' @return Named numeric vector of length \code{nchan}.
    median = function() {
      setNames(rt_image_median(private$.ptr),
               rt_channel_names(self$colorspace, self$nchan))
    },

    #' @description Per-channel quantiles.
    #' @param probs Numeric vector of probabilities in \code{[0, 1]}.
    #'   Defaults to \code{0.5} (median).
    #' @return A matrix with \code{length(probs)} rows and \code{nchan} columns.
    #'   Row names are percentages (e.g. \code{"25\%"}); column names are channel names.
    quantile = function(probs = 0.5) {
      if (any(probs < 0 | probs > 1))
        stop("probs must be between 0 and 1", call. = FALSE)
      raw <- rt_image_quantile(private$.ptr, probs)
      matrix(raw,
             nrow = length(probs),
             ncol = self$nchan,
             dimnames = list(paste0(probs * 100, "%"),
                             rt_channel_names(self$colorspace, self$nchan)))
    },

    #' @description Add another image or a scalar to this image.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    add = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_add_image, rt_image_add_scalar))
    },

    #' @description Add in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    add_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_add_image, rt_image_add_scalar)
      invisible(self)
    },

    #' @description Subtract another image or a scalar from this image.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    subtract = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_subtract_image, rt_image_subtract_scalar))
    },

    #' @description Subtract in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    subtract_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_subtract_image, rt_image_subtract_scalar)
      invisible(self)
    },

    #' @description Multiply this image element-wise by another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    multiply = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_multiply_image, rt_image_multiply_scalar))
    },

    #' @description Multiply in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    multiply_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_multiply_image, rt_image_multiply_scalar)
      invisible(self)
    },

    #' @description Divide this image element-wise by another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    divide = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_divide_image, rt_image_divide_scalar))
    },

    #' @description Divide in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    divide_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_divide_image, rt_image_divide_scalar)
      invisible(self)
    },

    #' @description Compute the absolute difference with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    absdiff = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_absdiff_image, rt_image_absdiff_scalar))
    },

    #' @description Absolute difference in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    absdiff_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_absdiff_image, rt_image_absdiff_scalar)
      invisible(self)
    },

    #' @description Weighted addition of two images: \code{w1*self + w2*other + gamma}.
    #' @param other An \code{Image}.
    #' @param w1 Numeric scalar. Weight for this image.
    #' @param w2 Numeric scalar. Weight for \code{other}.
    #' @param gamma Numeric scalar. Brightness offset added after blending. Default 0.
    #' @return A new \code{Image}.
    add_weighted = function(other, w1, w2, gamma = 0) {
      if (!inherits(other, "Image"))
        stop("other must be an Image", call. = FALSE)
      if (!is.numeric(w1) || length(w1) != 1L ||
          !is.numeric(w2) || length(w2) != 1L ||
          !is.numeric(gamma) || length(gamma) != 1L)
        stop("w1, w2, and gamma must each be a single numeric value", call. = FALSE)
      Image$new(rt_image_add_weighted(private$.ptr, as.double(w1),
                                      .rt_ptr(other), as.double(w2),
                                      as.double(gamma)))
    },

    #' @description Weighted addition in place.
    #' @param other An \code{Image}.
    #' @param w1 Numeric scalar. Weight for this image.
    #' @param w2 Numeric scalar. Weight for \code{other}.
    #' @param gamma Numeric scalar. Brightness offset. Default 0.
    #' @return \code{self} invisibly.
    add_weighted_ = function(other, w1, w2, gamma = 0) {
      if (!inherits(other, "Image"))
        stop("other must be an Image", call. = FALSE)
      if (!is.numeric(w1) || length(w1) != 1L ||
          !is.numeric(w2) || length(w2) != 1L ||
          !is.numeric(gamma) || length(gamma) != 1L)
        stop("w1, w2, and gamma must each be a single numeric value", call. = FALSE)
      private$.ptr <- rt_image_add_weighted(private$.ptr, as.double(w1),
                                            .rt_ptr(other), as.double(w2),
                                            as.double(gamma))
      invisible(self)
    },

    #' @description Bitwise AND with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    bitwise_and = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_and_image, rt_image_bitwise_and_scalar))
    },

    #' @description Bitwise AND in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_and_ = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_and_image, rt_image_bitwise_and_scalar)
      invisible(self)
    },

    #' @description Bitwise OR with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    bitwise_or = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_or_image, rt_image_bitwise_or_scalar))
    },

    #' @description Bitwise OR in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_or_ = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_or_image, rt_image_bitwise_or_scalar)
      invisible(self)
    },

    #' @description Bitwise XOR with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    bitwise_xor = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_xor_image, rt_image_bitwise_xor_scalar))
    },

    #' @description Bitwise XOR in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_xor_ = function(other) {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_xor_image, rt_image_bitwise_xor_scalar)
      invisible(self)
    },

    #' @description Bitwise NOT (invert all bits).
    #' @return A new \code{Image}.
    bitwise_not = function() {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      Image$new(rt_image_bitwise_not(private$.ptr))
    },

    #' @description Bitwise NOT in place.
    #' @return \code{self} invisibly.
    bitwise_not_ = function() {
      if (!self$depth_name %in% c("CV_8U", "CV_16U", "CV_16S"))
        stop("bitwise operations require an integer depth (CV_8U, CV_16U, or CV_16S)",
             call. = FALSE)
      private$.ptr <- rt_image_bitwise_not(private$.ptr)
      invisible(self)
    },

    #' @description Apply a normalised box filter (simple average blur).
    #' @param ksize Length-2 integer vector \code{c(width, height)} of positive
    #'   integers specifying the kernel size.
    #' @return A new \code{Image}.
    blur = function(ksize) {
      if (!is.numeric(ksize) || length(ksize) != 2L || any(ksize <= 0))
        stop("ksize must be a length-2 vector of positive integers", call. = FALSE)
      Image$new(rt_image_blur(private$.ptr,
                              as.integer(ksize[1]), as.integer(ksize[2])))
    },

    #' @description Box blur in place.
    #' @param ksize Length-2 integer vector \code{c(width, height)} of positive
    #'   integers specifying the kernel size.
    #' @return \code{self} invisibly.
    blur_ = function(ksize) {
      if (!is.numeric(ksize) || length(ksize) != 2L || any(ksize <= 0))
        stop("ksize must be a length-2 vector of positive integers", call. = FALSE)
      private$.ptr <- rt_image_blur(private$.ptr,
                                    as.integer(ksize[1]), as.integer(ksize[2]))
      invisible(self)
    },

    #' @description Apply a Gaussian blur.
    #' @param ksize Length-2 vector. Each element must be a positive odd integer
    #'   or \code{0}. When \code{0}, the kernel size is inferred from
    #'   \code{sigma} automatically.
    #' @param sigma Length-1 or length-2 positive numeric. Gaussian standard
    #'   deviation in the X (and optionally Y) direction. A single value is
    #'   applied to both axes.
    #' @return A new \code{Image}.
    gaussian_blur = function(ksize, sigma) {
      if (!is.numeric(ksize) || length(ksize) != 2L ||
          !all(ksize == 0 | (ksize > 0 & ksize %% 2 == 1)))
        stop("ksize elements must each be odd and positive, or 0", call. = FALSE)
      if (!is.numeric(sigma) || length(sigma) < 1L || length(sigma) > 2L)
        stop("sigma must be length 1 or 2", call. = FALSE)
      if (any(sigma <= 0))
        stop("sigma values must be positive", call. = FALSE)
      sigma <- rep(as.double(sigma), length.out = 2L)
      Image$new(rt_image_gaussian_blur(private$.ptr,
                                       as.integer(ksize[1]), as.integer(ksize[2]),
                                       sigma[1], sigma[2]))
    },

    #' @description Gaussian blur in place.
    #' @param ksize Length-2 vector. Each element must be a positive odd integer
    #'   or \code{0}. When \code{0}, the kernel size is inferred from
    #'   \code{sigma} automatically.
    #' @param sigma Length-1 or length-2 positive numeric. A single value is
    #'   applied to both axes.
    #' @return \code{self} invisibly.
    gaussian_blur_ = function(ksize, sigma) {
      if (!is.numeric(ksize) || length(ksize) != 2L ||
          !all(ksize == 0 | (ksize > 0 & ksize %% 2 == 1)))
        stop("ksize elements must each be odd and positive, or 0", call. = FALSE)
      if (!is.numeric(sigma) || length(sigma) < 1L || length(sigma) > 2L)
        stop("sigma must be length 1 or 2", call. = FALSE)
      if (any(sigma <= 0))
        stop("sigma values must be positive", call. = FALSE)
      sigma <- rep(as.double(sigma), length.out = 2L)
      private$.ptr <- rt_image_gaussian_blur(private$.ptr,
                                             as.integer(ksize[1]), as.integer(ksize[2]),
                                             sigma[1], sigma[2])
      invisible(self)
    },

    #' @description Apply a median blur.
    #' @param ksize Single positive odd integer. The kernel is always square
    #'   (OpenCV constraint).
    #' @return A new \code{Image}.
    median_blur = function(ksize) {
      if (!is.numeric(ksize) || length(ksize) != 1L ||
          ksize <= 0 || ksize %% 2 == 0)
        stop("ksize must be a single positive odd integer", call. = FALSE)
      Image$new(rt_image_median_blur(private$.ptr, as.integer(ksize)))
    },

    #' @description Median blur in place.
    #' @param ksize Single positive odd integer. The kernel is always square
    #'   (OpenCV constraint).
    #' @return \code{self} invisibly.
    median_blur_ = function(ksize) {
      if (!is.numeric(ksize) || length(ksize) != 1L ||
          ksize <= 0 || ksize %% 2 == 0)
        stop("ksize must be a single positive odd integer", call. = FALSE)
      private$.ptr <- rt_image_median_blur(private$.ptr, as.integer(ksize))
      invisible(self)
    },

    #' @description Apply a bilateral filter (edge-preserving smoothing).
    #' @param d Single integer. Diameter of the pixel neighbourhood. When
    #'   \code{d <= 0}, the diameter is computed from \code{sigma_space}.
    #' @param sigma_color Single positive numeric. Filter sigma in colour space.
    #' @param sigma_space Single positive numeric. Filter sigma in coordinate
    #'   space.
    #' @return A new \code{Image}.
    bilateral_filter = function(d, sigma_color, sigma_space) {
      if (!self$depth_name %in% c("CV_8U", "CV_32F"))
        stop("bilateral_filter requires a CV_8U or CV_32F image", call. = FALSE)
      if (!is.numeric(d) || length(d) != 1L)
        stop("d must be a single integer", call. = FALSE)
      if (!is.numeric(sigma_color) || length(sigma_color) != 1L || sigma_color <= 0 ||
          !is.numeric(sigma_space) || length(sigma_space) != 1L || sigma_space <= 0)
        stop("sigma_color and sigma_space must each be a single positive numeric value",
             call. = FALSE)
      Image$new(rt_image_bilateral_filter(private$.ptr, as.integer(d),
                                          as.double(sigma_color),
                                          as.double(sigma_space)))
    },

    #' @description Bilateral filter in place.
    #' @param d Single integer. Diameter of the pixel neighbourhood. When
    #'   \code{d <= 0}, the diameter is computed from \code{sigma_space}.
    #' @param sigma_color Single positive numeric. Filter sigma in colour space.
    #' @param sigma_space Single positive numeric. Filter sigma in coordinate
    #'   space.
    #' @return \code{self} invisibly.
    bilateral_filter_ = function(d, sigma_color, sigma_space) {
      if (!self$depth_name %in% c("CV_8U", "CV_32F"))
        stop("bilateral_filter requires a CV_8U or CV_32F image", call. = FALSE)
      if (!is.numeric(d) || length(d) != 1L)
        stop("d must be a single integer", call. = FALSE)
      if (!is.numeric(sigma_color) || length(sigma_color) != 1L || sigma_color <= 0 ||
          !is.numeric(sigma_space) || length(sigma_space) != 1L || sigma_space <= 0)
        stop("sigma_color and sigma_space must each be a single positive numeric value",
             call. = FALSE)
      private$.ptr <- rt_image_bilateral_filter(private$.ptr, as.integer(d),
                                                as.double(sigma_color),
                                                as.double(sigma_space))
      invisible(self)
    },

    #' @description Apply the Sobel operator to compute image gradients. Returns
    #'   a new Image.
    #' @param dx Non-negative integer. Order of x derivative.
    #' @param dy Non-negative integer. Order of y derivative.
    #'   \code{dx + dy} must be >= 1.
    #' @param ksize Integer. Sobel kernel aperture size: 1, 3, 5, or 7.
    #'   The limit of 7 is an OpenCV requirement.
    #' @param ddepth Character. Output depth: \code{"CV_16S"}, \code{"CV_32F"},
    #'   or \code{"CV_64F"}. Default \code{NULL} (depth inferred from input; a message is emitted).
    #' @param scale Single positive numeric. Optional scale factor for the
    #'   computed derivatives. Must be positive (use \code{convert_depth} +
    #'   arithmetic to invert gradient sign). Default 1.
    #' @param delta Single numeric. Optional delta added to results before
    #'   storing. Default 0.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   these operations.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' grad_x <- img$sobel(1, 0)
    #' grad_x$plot()
    #' }
    sobel = function(dx, dy, ksize = 3, ddepth = NULL,
                     scale = 1, delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!is.numeric(dx) || !is.numeric(dy) ||
          length(dx) != 1L || length(dy) != 1L ||
          dx < 0 || dy < 0 || (dx + dy) < 1)
        stop("dx and dy must be non-negative integers with dx + dy >= 1",
             call. = FALSE)
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      Image$new(rt_image_sobel(private$.ptr, as.integer(dx), as.integer(dy),
                               as.integer(ksize), ddepth, as.double(scale),
                               as.double(delta), border_type))
    },

    #' @description Sobel operator in place.
    #' @param dx Non-negative integer. Order of x derivative.
    #' @param dy Non-negative integer. Order of y derivative.
    #'   \code{dx + dy} must be >= 1.
    #' @param ksize Integer. Sobel kernel aperture size: 1, 3, 5, or 7.
    #' @param ddepth Character. Output depth: \code{"CV_16S"}, \code{"CV_32F"},
    #'   or \code{"CV_64F"}. Default \code{NULL} (depth inferred from input; a message is emitted).
    #' @param scale Single positive numeric. Optional scale factor for the
    #'   computed derivatives. Must be positive (use \code{convert_depth} +
    #'   arithmetic to invert gradient sign). Default 1.
    #' @param delta Single numeric. Delta added to results. Default 0.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   these operations.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$sobel_(1, 0)
    #' img$plot()
    #' }
    sobel_ = function(dx, dy, ksize = 3, ddepth = NULL,
                      scale = 1, delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!is.numeric(dx) || !is.numeric(dy) ||
          length(dx) != 1L || length(dy) != 1L ||
          dx < 0 || dy < 0 || (dx + dy) < 1)
        stop("dx and dy must be non-negative integers with dx + dy >= 1",
             call. = FALSE)
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      private$.ptr <- rt_image_sobel(private$.ptr, as.integer(dx), as.integer(dy),
                                     as.integer(ksize), ddepth, as.double(scale),
                                     as.double(delta), border_type)
      invisible(self)
    },

    #' @description Apply the Laplacian operator to detect edges. Returns a new
    #'   Image.
    #' @param ksize Integer. Aperture size for the Laplacian kernel: 1, 3, 5,
    #'   or 7. \code{ksize = 1} uses the 3-point central-difference stencil.
    #'   Default 1.
    #' @param ddepth Character. Output depth: \code{"CV_16S"}, \code{"CV_32F"},
    #'   or \code{"CV_64F"}. Default \code{NULL} (depth inferred from input; a message is emitted).
    #' @param scale Single positive numeric. Optional scale factor. Must be
    #'   positive. Default 1.
    #' @param delta Single numeric. Optional delta added to results. Default 0.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   these operations.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' edges <- img$laplacian()
    #' edges$plot()
    #' }
    laplacian = function(ksize = 1, ddepth = NULL,
                         scale = 1, delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      Image$new(rt_image_laplacian(private$.ptr, as.integer(ksize), ddepth,
                                   as.double(scale), as.double(delta),
                                   border_type))
    },

    #' @description Laplacian operator in place.
    #' @param ksize Integer. Aperture size: 1, 3, 5, or 7. Default 1.
    #' @param ddepth Character. Output depth: \code{"CV_16S"}, \code{"CV_32F"},
    #'   or \code{"CV_64F"}. Default \code{NULL} (depth inferred from input; a message is emitted).
    #' @param scale Single positive numeric. Optional scale factor. Must be
    #'   positive. Default 1.
    #' @param delta Single numeric. Delta added to results. Default 0.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   these operations.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$laplacian_()
    #' img$plot()
    #' }
    laplacian_ = function(ksize = 1, ddepth = NULL,
                          scale = 1, delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      private$.ptr <- rt_image_laplacian(private$.ptr, as.integer(ksize),
                                         ddepth, as.double(scale),
                                         as.double(delta), border_type)
      invisible(self)
    },

    #' @description Detect edges using the Canny algorithm. Returns a new
    #'   single-channel CV_8U Image with pixel values 0 (no edge) or 255
    #'   (edge). Input must be a single-channel grayscale image.
    #' @param low_threshold Single non-negative numeric. Lower hysteresis threshold.
    #' @param high_threshold Single positive numeric. Upper hysteresis
    #'   threshold. Must be >= \code{low_threshold}.
    #' @param aperture_size Integer. Size of the Sobel kernel used internally:
    #'   3, 5, or 7. Default 3.
    #' @param L2_gradient Logical scalar. If \code{TRUE}, use the L2 norm for
    #'   gradient magnitude (more accurate but slower). Default \code{FALSE}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "staircase.jpg", package = "Retina")
    #' img <- Image$new(img_path)$convert_color("GRAY")
    #' edges <- img$canny(50, 150)
    #' edges$plot()
    #' }
    canny = function(low_threshold, high_threshold,
                     aperture_size = 3, L2_gradient = FALSE) {
      if (self$nchan != 1L)
        stop("canny requires a single-channel (grayscale) image — use convert_color('GRAY') first",
             call. = FALSE)
      if (!is.numeric(low_threshold) || length(low_threshold) != 1L || low_threshold < 0)
        stop("low_threshold must be a single non-negative numeric value", call. = FALSE)
      if (!is.numeric(high_threshold) || length(high_threshold) != 1L || high_threshold <= 0)
        stop("high_threshold must be a single positive numeric value", call. = FALSE)
      if (low_threshold > high_threshold)
        stop("low_threshold must be <= high_threshold", call. = FALSE)
      if (!aperture_size %in% c(3L, 5L, 7L))
        stop("aperture_size must be 3, 5, or 7", call. = FALSE)
      if (!is.logical(L2_gradient) || length(L2_gradient) != 1L)
        stop("L2_gradient must be a single logical value", call. = FALSE)
      Image$new(rt_image_canny(private$.ptr, as.double(low_threshold),
                               as.double(high_threshold),
                               as.integer(aperture_size),
                               as.logical(L2_gradient)))
    },

    #' @description Canny edge detection in place.
    #' @param low_threshold Single non-negative numeric. Lower hysteresis threshold.
    #' @param high_threshold Single positive numeric. Upper hysteresis
    #'   threshold. Must be >= \code{low_threshold}.
    #' @param aperture_size Integer. Size of the Sobel kernel: 3, 5, or 7.
    #'   Default 3.
    #' @param L2_gradient Logical scalar. Use L2 norm for gradient magnitude.
    #'   Default \code{FALSE}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "staircase.jpg", package = "Retina")
    #' img <- Image$new(img_path)$convert_color("GRAY")
    #' img$canny_(50, 150)
    #' img$plot()
    #' }
    canny_ = function(low_threshold, high_threshold,
                      aperture_size = 3, L2_gradient = FALSE) {
      if (self$nchan != 1L)
        stop("canny requires a single-channel (grayscale) image — use convert_color('GRAY') first",
             call. = FALSE)
      if (!is.numeric(low_threshold) || length(low_threshold) != 1L || low_threshold < 0)
        stop("low_threshold must be a single non-negative numeric value", call. = FALSE)
      if (!is.numeric(high_threshold) || length(high_threshold) != 1L || high_threshold <= 0)
        stop("high_threshold must be a single positive numeric value", call. = FALSE)
      if (low_threshold > high_threshold)
        stop("low_threshold must be <= high_threshold", call. = FALSE)
      if (!aperture_size %in% c(3L, 5L, 7L))
        stop("aperture_size must be 3, 5, or 7", call. = FALSE)
      if (!is.logical(L2_gradient) || length(L2_gradient) != 1L)
        stop("L2_gradient must be a single logical value", call. = FALSE)
      private$.ptr <- rt_image_canny(private$.ptr, as.double(low_threshold),
                                     as.double(high_threshold),
                                     as.integer(aperture_size),
                                     as.logical(L2_gradient))
      invisible(self)
    },

    #' @description Apply the Scharr operator to compute image gradients. Returns
    #'   a new Image. Scharr uses a fixed 3x3 kernel with better rotational
    #'   symmetry than Sobel. Exactly one of \code{dx} or \code{dy} must be 1.
    #' @param dx Integer. Order of x derivative: \code{0} or \code{1}.
    #' @param dy Integer. Order of y derivative: \code{0} or \code{1}.
    #'   Exactly one of \code{dx}, \code{dy} must be \code{1}.
    #' @param ddepth Character or \code{NULL}. Output depth: \code{"CV_16S"},
    #'   \code{"CV_32F"}, or \code{"CV_64F"}. When \code{NULL} (default), the
    #'   output depth is inferred from the input depth and a message is emitted.
    #' @param scale Single positive numeric. Scale factor for computed
    #'   derivatives. Default \code{1}.
    #' @param delta Single numeric. Constant added to output pixels. Default
    #'   \code{0}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   Scharr.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' grad_x <- img$scharr(1, 0)
    #' grad_x$plot()
    #' }
    scharr = function(dx, dy, ddepth = NULL, scale = 1, delta = 0,
                      border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant")
      dx <- as.integer(dx); dy <- as.integer(dy)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (length(dx) != 1L || length(dy) != 1L ||
          !dx %in% c(0L, 1L) || !dy %in% c(0L, 1L) || (dx + dy) != 1L)
        stop("dx and dy must each be 0 or 1, and exactly one must be 1",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      Image$new(rt_image_scharr(private$.ptr, dx, dy, ddepth,
                                as.double(scale), as.double(delta), border_type))
    },

    #' @description Scharr operator in place.
    #' @param dx Integer. Order of x derivative: \code{0} or \code{1}.
    #' @param dy Integer. Order of y derivative: \code{0} or \code{1}.
    #'   Exactly one of \code{dx}, \code{dy} must be \code{1}.
    #' @param ddepth Character or \code{NULL}. Output depth: \code{"CV_16S"},
    #'   \code{"CV_32F"}, or \code{"CV_64F"}. Default \code{NULL} (depth
    #'   inferred from input; a message is emitted).
    #' @param scale Single positive numeric. Default \code{1}.
    #' @param delta Single numeric. Default \code{0}.
    #' @param border_type Character. Border handling mode. \code{"wrap"} is not
    #'   supported. Default \code{"reflect_101"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$scharr_(1, 0)
    #' img$plot()
    #' }
    scharr_ = function(dx, dy, ddepth = NULL, scale = 1, delta = 0,
                       border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant")
      dx <- as.integer(dx); dy <- as.integer(dy)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (length(dx) != 1L || length(dy) != 1L ||
          !dx %in% c(0L, 1L) || !dy %in% c(0L, 1L) || (dx + dy) != 1L)
        stop("dx and dy must each be 0 or 1, and exactly one must be 1",
             call. = FALSE)
      if (is.null(ddepth)) {
        ddepth <- .rt_infer_ddepth(self$depth_name)
        message('ddepth not specified; using "', ddepth,
                '" for a ', self$depth_name, ' image.')
      } else if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F")) {
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      }
      private$.ptr <- rt_image_scharr(private$.ptr, dx, dy, ddepth,
                                      as.double(scale), as.double(delta),
                                      border_type)
      invisible(self)
    },

    #' @description Apply an arbitrary 2D convolution kernel. Returns a new Image.
    #' @param kernel Numeric matrix. The convolution kernel. Values are coerced
    #'   to double.
    #' @param ddepth Character or \code{NULL}. Output depth. One of
    #'   \code{"CV_8U"}, \code{"CV_16U"}, \code{"CV_16S"}, \code{"CV_32F"},
    #'   \code{"CV_64F"}. When \code{NULL} (default), the output depth matches
    #'   the input depth (OpenCV \code{-1}).
    #' @param anchor \code{NULL} (default, kernel centre) or a length-2 integer
    #'   vector \code{c(col, row)} specifying the anchor pixel within the kernel
    #'   (0-based).
    #' @param delta Single numeric. Constant added to every output pixel after
    #'   convolution. Default \code{0}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black); \code{"wrap"} tiles the image at the boundary.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
    #' sharpened <- img$filter2D(sharpen)
    #' sharpened$plot()
    #' }
    filter2D = function(kernel, ddepth = NULL, anchor = NULL, delta = 0,
                        border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      .valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")
      if (!is.matrix(kernel) || !is.numeric(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      if (any(!is.finite(kernel)))
        stop("kernel must not contain NA or infinite values", call. = FALSE)
      if (!is.null(ddepth)) {
        if (!is.character(ddepth) || length(ddepth) != 1L ||
            !ddepth %in% .valid_depths)
          stop("ddepth must be NULL or one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
               call. = FALSE)
      }
      if (!is.null(anchor)) {
        anchor <- as.integer(anchor)
        if (length(anchor) != 2L || any(is.na(anchor)))
          stop("anchor must be NULL or a length-2 integer vector", call. = FALSE)
        if (anchor[1L] < 0L || anchor[1L] >= ncol(kernel) ||
            anchor[2L] < 0L || anchor[2L] >= nrow(kernel))
          stop("anchor values are out of kernel bounds (0-based)", call. = FALSE)
      }
      if (!is.numeric(delta) || length(delta) != 1L || !is.finite(delta))
        stop("delta must be a single finite numeric", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .ddepth_int <- if (is.null(ddepth)) -1L else {
        c(CV_8U = 0L, CV_16U = 2L, CV_16S = 3L, CV_32F = 5L, CV_64F = 6L)[[ddepth]]
      }
      .anchor_x <- if (is.null(anchor)) -1L else anchor[1L]
      .anchor_y <- if (is.null(anchor)) -1L else anchor[2L]
      Image$new(rt_image_filter2d(private$.ptr,
                                  as.double(as.vector(kernel)),
                                  nrow(kernel), ncol(kernel),
                                  .ddepth_int, .anchor_x, .anchor_y,
                                  as.double(delta), border_type))
    },

    #' @description Apply an arbitrary 2D convolution kernel in place.
    #' @param kernel Numeric matrix. The convolution kernel.
    #' @param ddepth Character or \code{NULL}. Output depth. Default \code{NULL}
    #'   (preserves input depth).
    #' @param anchor \code{NULL} (kernel centre) or \code{c(col, row)} (0-based).
    #' @param delta Single numeric. Additive offset. Default \code{0}.
    #' @param border_type Character. Border handling mode. Default
    #'   \code{"reflect_101"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' sharpen <- matrix(c(0,-1,0,-1,5,-1,0,-1,0), nrow = 3)
    #' img$filter2D_(sharpen)
    #' img$plot()
    #' }
    filter2D_ = function(kernel, ddepth = NULL, anchor = NULL, delta = 0,
                         border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      .valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")
      if (!is.matrix(kernel) || !is.numeric(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      if (any(!is.finite(kernel)))
        stop("kernel must not contain NA or infinite values", call. = FALSE)
      if (!is.null(ddepth)) {
        if (!is.character(ddepth) || length(ddepth) != 1L ||
            !ddepth %in% .valid_depths)
          stop("ddepth must be NULL or one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
               call. = FALSE)
      }
      if (!is.null(anchor)) {
        anchor <- as.integer(anchor)
        if (length(anchor) != 2L || any(is.na(anchor)))
          stop("anchor must be NULL or a length-2 integer vector", call. = FALSE)
        if (anchor[1L] < 0L || anchor[1L] >= ncol(kernel) ||
            anchor[2L] < 0L || anchor[2L] >= nrow(kernel))
          stop("anchor values are out of kernel bounds (0-based)", call. = FALSE)
      }
      if (!is.numeric(delta) || length(delta) != 1L || !is.finite(delta))
        stop("delta must be a single finite numeric", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .ddepth_int <- if (is.null(ddepth)) -1L else {
        c(CV_8U = 0L, CV_16U = 2L, CV_16S = 3L, CV_32F = 5L, CV_64F = 6L)[[ddepth]]
      }
      .anchor_x <- if (is.null(anchor)) -1L else anchor[1L]
      .anchor_y <- if (is.null(anchor)) -1L else anchor[2L]
      private$.ptr <- rt_image_filter2d(private$.ptr,
                                        as.double(as.vector(kernel)),
                                        nrow(kernel), ncol(kernel),
                                        .ddepth_int, .anchor_x, .anchor_y,
                                        as.double(delta), border_type)
      invisible(self)
    },

    #' @description Apply a separable filter using two 1D kernels (one horizontal,
    #'   one vertical). Returns a new Image. Equivalent to applying
    #'   \code{kernel_x} along columns then \code{kernel_y} along rows, but
    #'   computed more efficiently.
    #' @param kernel_x Numeric vector. Horizontal (column-direction) 1D kernel.
    #' @param kernel_y Numeric vector. Vertical (row-direction) 1D kernel.
    #' @param ddepth Character or \code{NULL}. Output depth. One of
    #'   \code{"CV_8U"}, \code{"CV_16U"}, \code{"CV_16S"}, \code{"CV_32F"},
    #'   \code{"CV_64F"}. When \code{NULL} (default), the output depth matches
    #'   the input depth.
    #' @param anchor \code{NULL} (default, kernel centres) or a length-2 integer
    #'   vector \code{c(pos_in_kernel_x, pos_in_kernel_y)} (0-based).
    #' @param delta Single numeric. Constant added to every output pixel. Default
    #'   \code{0}.
    #' @param border_type Character. Border handling mode. Default
    #'   \code{"reflect_101"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' blurred <- img$sep_filter2D(rep(1/3, 3), rep(1/3, 3))
    #' blurred$plot()
    #' }
    sep_filter2D = function(kernel_x, kernel_y, ddepth = NULL, anchor = NULL,
                            delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      .valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")
      if (!is.numeric(kernel_x) || length(kernel_x) < 1L || any(!is.finite(kernel_x)))
        stop("kernel_x must be a non-empty numeric vector with finite values",
             call. = FALSE)
      if (!is.numeric(kernel_y) || length(kernel_y) < 1L || any(!is.finite(kernel_y)))
        stop("kernel_y must be a non-empty numeric vector with finite values",
             call. = FALSE)
      if (!is.null(ddepth)) {
        if (!is.character(ddepth) || length(ddepth) != 1L ||
            !ddepth %in% .valid_depths)
          stop("ddepth must be NULL or one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
               call. = FALSE)
      }
      if (!is.null(anchor)) {
        anchor <- as.integer(anchor)
        if (length(anchor) != 2L || any(is.na(anchor)))
          stop("anchor must be NULL or a length-2 integer vector", call. = FALSE)
        if (anchor[1L] < 0L || anchor[1L] >= length(kernel_x) ||
            anchor[2L] < 0L || anchor[2L] >= length(kernel_y))
          stop("anchor values are out of kernel bounds (0-based)", call. = FALSE)
      }
      if (!is.numeric(delta) || length(delta) != 1L || !is.finite(delta))
        stop("delta must be a single finite numeric", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .ddepth_int <- if (is.null(ddepth)) -1L else {
        c(CV_8U = 0L, CV_16U = 2L, CV_16S = 3L, CV_32F = 5L, CV_64F = 6L)[[ddepth]]
      }
      .anchor_x <- if (is.null(anchor)) -1L else anchor[1L]
      .anchor_y <- if (is.null(anchor)) -1L else anchor[2L]
      Image$new(rt_image_sep_filter2d(private$.ptr,
                                      as.double(kernel_x), as.double(kernel_y),
                                      .ddepth_int, .anchor_x, .anchor_y,
                                      as.double(delta), border_type))
    },

    #' @description Separable filter in place.
    #' @param kernel_x Numeric vector. Horizontal 1D kernel.
    #' @param kernel_y Numeric vector. Vertical 1D kernel.
    #' @param ddepth Character or \code{NULL}. Output depth. Default \code{NULL}.
    #' @param anchor \code{NULL} or \code{c(pos_x, pos_y)} (0-based). Default
    #'   \code{NULL} (kernel centres).
    #' @param delta Single numeric. Default \code{0}.
    #' @param border_type Character. Default \code{"reflect_101"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$sep_filter2D_(rep(1/3, 3), rep(1/3, 3))
    #' img$plot()
    #' }
    sep_filter2D_ = function(kernel_x, kernel_y, ddepth = NULL, anchor = NULL,
                             delta = 0, border_type = "reflect_101") {
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      .valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")
      if (!is.numeric(kernel_x) || length(kernel_x) < 1L || any(!is.finite(kernel_x)))
        stop("kernel_x must be a non-empty numeric vector with finite values",
             call. = FALSE)
      if (!is.numeric(kernel_y) || length(kernel_y) < 1L || any(!is.finite(kernel_y)))
        stop("kernel_y must be a non-empty numeric vector with finite values",
             call. = FALSE)
      if (!is.null(ddepth)) {
        if (!is.character(ddepth) || length(ddepth) != 1L ||
            !ddepth %in% .valid_depths)
          stop("ddepth must be NULL or one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F",
               call. = FALSE)
      }
      if (!is.null(anchor)) {
        anchor <- as.integer(anchor)
        if (length(anchor) != 2L || any(is.na(anchor)))
          stop("anchor must be NULL or a length-2 integer vector", call. = FALSE)
        if (anchor[1L] < 0L || anchor[1L] >= length(kernel_x) ||
            anchor[2L] < 0L || anchor[2L] >= length(kernel_y))
          stop("anchor values are out of kernel bounds (0-based)", call. = FALSE)
      }
      if (!is.numeric(delta) || length(delta) != 1L || !is.finite(delta))
        stop("delta must be a single finite numeric", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .ddepth_int <- if (is.null(ddepth)) -1L else {
        c(CV_8U = 0L, CV_16U = 2L, CV_16S = 3L, CV_32F = 5L, CV_64F = 6L)[[ddepth]]
      }
      .anchor_x <- if (is.null(anchor)) -1L else anchor[1L]
      .anchor_y <- if (is.null(anchor)) -1L else anchor[2L]
      private$.ptr <- rt_image_sep_filter2d(private$.ptr,
                                            as.double(kernel_x), as.double(kernel_y),
                                            .ddepth_int, .anchor_x, .anchor_y,
                                            as.double(delta), border_type)
      invisible(self)
    },

    #' @description Apply a morphological operation. Returns a new Image.
    #' @param operation Character. One of \code{"erode"} (shrinks bright
    #'   regions), \code{"dilate"} (expands bright regions), \code{"open"}
    #'   (erode then dilate — removes small bright spots), \code{"close"}
    #'   (dilate then erode — fills small dark holes), \code{"gradient"}
    #'   (dilate minus erode — highlights edges), \code{"tophat"} (image minus
    #'   open — isolates bright features smaller than the kernel),
    #'   \code{"blackhat"} (close minus image — isolates dark features smaller
    #'   than the kernel).
    #' @param shape Character. Structuring element shape: \code{"rect"},
    #'   \code{"cross"}, or \code{"ellipse"}. Ignored when \code{kernel} is
    #'   supplied. Default \code{"rect"}.
    #' @param size Positive odd integer. Side length of the structuring element.
    #'   Ignored when \code{kernel} is supplied. Default \code{3L}.
    #' @param kernel Optional numeric matrix used as the structuring element.
    #'   Values are coerced to integers. Overrides
    #'   \code{shape} and \code{size} when supplied.
    #' @param iterations Positive integer. For primitive operations
    #'   (\code{"erode"}, \code{"dilate"}), the number of times the operation
    #'   is applied. For compound operations (\code{"open"}, \code{"close"},
    #'   \code{"gradient"}, \code{"tophat"}, \code{"blackhat"}), each internal
    #'   erosion or dilation step is repeated \code{iterations} times
    #'   independently (e.g., \code{iterations = 2} with \code{"open"} erodes
    #'   twice then dilates twice, not opens twice). Default \code{1L}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   morphological operations.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)$convert_color("GRAY")
    #' eroded <- img$morph("erode")
    #' eroded$plot()
    #' }
    morph = function(operation, shape = "rect", size = 3L,
                     kernel = NULL, iterations = 1L,
                     border_type = "reflect_101") {
      .valid_ops    <- c("erode", "dilate", "open", "close",
                         "gradient", "tophat", "blackhat")
      .valid_shapes <- c("rect", "cross", "ellipse")
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!is.character(operation) || length(operation) != 1L ||
          !operation %in% .valid_ops)
        stop("operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat",
             call. = FALSE)
      if (!is.null(kernel) && !is.matrix(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      if (is.null(kernel)) {
        if (!is.character(shape) || length(shape) != 1L || !shape %in% .valid_shapes)
          stop("shape must be one of: rect, cross, ellipse", call. = FALSE)
        size <- as.integer(size)
        if (length(size) != 1L || is.na(size) || size < 1L || size %% 2L == 0L)
          stop("size must be a single positive odd integer", call. = FALSE)
      }
      iterations <- as.integer(iterations)
      if (length(iterations) != 1L || is.na(iterations) || iterations < 1L)
        stop("iterations must be a single positive integer", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(kernel)) {
        Image$new(rt_image_morph(private$.ptr, operation, shape, size,
                                 iterations, border_type))
      } else {
        k <- matrix(as.integer(kernel), nrow = nrow(kernel))
        Image$new(rt_image_morph_custom(private$.ptr, operation, k,
                                        iterations, border_type))
      }
    },

    #' @description Apply a morphological operation in place.
    #' @param operation Character. One of \code{"erode"} (shrinks bright
    #'   regions), \code{"dilate"} (expands bright regions), \code{"open"}
    #'   (erode then dilate — removes small bright spots), \code{"close"}
    #'   (dilate then erode — fills small dark holes), \code{"gradient"}
    #'   (dilate minus erode — highlights edges), \code{"tophat"} (image minus
    #'   open — isolates bright features smaller than the kernel),
    #'   \code{"blackhat"} (close minus image — isolates dark features smaller
    #'   than the kernel).
    #' @param shape Character. Structuring element shape: \code{"rect"},
    #'   \code{"cross"}, or \code{"ellipse"}. Ignored when \code{kernel} is
    #'   supplied. Default \code{"rect"}.
    #' @param size Positive odd integer. Side length of the structuring element.
    #'   Ignored when \code{kernel} is supplied. Default \code{3L}.
    #' @param kernel Optional numeric matrix used as the structuring element.
    #'   Values are coerced to integers. Overrides
    #'   \code{shape} and \code{size} when supplied.
    #' @param iterations Positive integer. For primitive operations
    #'   (\code{"erode"}, \code{"dilate"}), the number of times the operation
    #'   is applied. For compound operations (\code{"open"}, \code{"close"},
    #'   \code{"gradient"}, \code{"tophat"}, \code{"blackhat"}), each internal
    #'   erosion or dilation step is repeated \code{iterations} times
    #'   independently (e.g., \code{iterations = 2} with \code{"open"} erodes
    #'   twice then dilates twice, not opens twice). Default \code{1L}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"constant"} fills with a fixed
    #'   value (0, i.e. black). \code{"wrap"} is not supported by OpenCV for
    #'   morphological operations.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)$convert_color("GRAY")
    #' img$morph_("erode")
    #' img$plot()
    #' }
    morph_ = function(operation, shape = "rect", size = 3L,
                      kernel = NULL, iterations = 1L,
                      border_type = "reflect_101") {
      .valid_ops    <- c("erode", "dilate", "open", "close",
                         "gradient", "tophat", "blackhat")
      .valid_shapes <- c("rect", "cross", "ellipse")
      .valid_border <- c("reflect", "reflect_101",
                         "replicate", "constant")
      if (!is.character(operation) || length(operation) != 1L ||
          !operation %in% .valid_ops)
        stop("operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat",
             call. = FALSE)
      if (!is.null(kernel) && !is.matrix(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      if (is.null(kernel)) {
        if (!is.character(shape) || length(shape) != 1L || !shape %in% .valid_shapes)
          stop("shape must be one of: rect, cross, ellipse", call. = FALSE)
        size <- as.integer(size)
        if (length(size) != 1L || is.na(size) || size < 1L || size %% 2L == 0L)
          stop("size must be a single positive odd integer", call. = FALSE)
      }
      iterations <- as.integer(iterations)
      if (length(iterations) != 1L || is.na(iterations) || iterations < 1L)
        stop("iterations must be a single positive integer", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant",
             call. = FALSE)
      if (is.null(kernel)) {
        private$.ptr <- rt_image_morph(private$.ptr, operation, shape, size,
                                       iterations, border_type)
      } else {
        k <- matrix(as.integer(kernel), nrow = nrow(kernel))
        private$.ptr <- rt_image_morph_custom(private$.ptr, operation, k,
                                              iterations, border_type)
      }
      invisible(self)
    },

    #' @description Resize the image. Returns a new Image.
    #' @param width Positive integer. Output width in pixels. Supply with
    #'   \code{height}; mutually exclusive with \code{fx}/\code{fy}.
    #' @param height Positive integer. Output height in pixels.
    #' @param fx Positive numeric. Horizontal scale factor. Supply with
    #'   \code{fy}; mutually exclusive with \code{width}/\code{height}.
    #' @param fy Positive numeric. Vertical scale factor.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$resize(width = 320L, height = 240L)$plot()
    #' img$resize(fx = 0.5, fy = 0.5)$plot()
    #' }
    resize = function(width = NULL, height = NULL, fx = NULL, fy = NULL,
                      interpolation = "linear") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .use_dims  <- !is.null(width)  || !is.null(height)
      .use_scale <- !is.null(fx)     || !is.null(fy)
      if (.use_dims && .use_scale)
        stop("supply either width/height or fx/fy, not both", call. = FALSE)
      if (!.use_dims && !.use_scale)
        stop("supply either width/height or fx/fy", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (.use_dims) {
        if (is.null(width) || is.null(height) ||
            !is.numeric(width) || !is.numeric(height) ||
            length(width) != 1L || length(height) != 1L ||
            width < 1L || height < 1L)
          stop("width and height must be single positive integers", call. = FALSE)
        if (width != as.integer(width) || height != as.integer(height))
          stop("width and height must be single positive integers", call. = FALSE)
        Image$new(rt_image_resize(private$.ptr,
                                  as.integer(width), as.integer(height),
                                  0, 0, interpolation))
      } else {
        if (is.null(fx) || is.null(fy) ||
            !is.numeric(fx) || !is.numeric(fy) ||
            length(fx) != 1L || length(fy) != 1L ||
            fx <= 0 || fy <= 0)
          stop("fx and fy must be single positive numeric values", call. = FALSE)
        Image$new(rt_image_resize(private$.ptr,
                                  0L, 0L,
                                  as.double(fx), as.double(fy),
                                  interpolation))
      }
    },

    #' @description Resize the image in place.
    #' @param width Positive integer. Output width in pixels.
    #' @param height Positive integer. Output height in pixels.
    #' @param fx Positive numeric. Horizontal scale factor.
    #' @param fy Positive numeric. Vertical scale factor.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$resize_(fx = 0.5, fy = 0.5)
    #' img$plot()
    #' }
    resize_ = function(width = NULL, height = NULL, fx = NULL, fy = NULL,
                       interpolation = "linear") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .use_dims  <- !is.null(width)  || !is.null(height)
      .use_scale <- !is.null(fx)     || !is.null(fy)
      if (.use_dims && .use_scale)
        stop("supply either width/height or fx/fy, not both", call. = FALSE)
      if (!.use_dims && !.use_scale)
        stop("supply either width/height or fx/fy", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (.use_dims) {
        if (is.null(width) || is.null(height) ||
            !is.numeric(width) || !is.numeric(height) ||
            length(width) != 1L || length(height) != 1L ||
            width < 1L || height < 1L)
          stop("width and height must be single positive integers", call. = FALSE)
        if (width != as.integer(width) || height != as.integer(height))
          stop("width and height must be single positive integers", call. = FALSE)
        private$.ptr <- rt_image_resize(private$.ptr,
                                        as.integer(width), as.integer(height),
                                        0, 0, interpolation)
      } else {
        if (is.null(fx) || is.null(fy) ||
            !is.numeric(fx) || !is.numeric(fy) ||
            length(fx) != 1L || length(fy) != 1L ||
            fx <= 0 || fy <= 0)
          stop("fx and fy must be single positive numeric values", call. = FALSE)
        private$.ptr <- rt_image_resize(private$.ptr,
                                        0L, 0L,
                                        as.double(fx), as.double(fy),
                                        interpolation)
      }
      invisible(self)
    },

    #' @description Rotate the image. Returns a new Image. Output retains
    #'   original dimensions; content outside the canvas is clipped.
    #' @param angle Single numeric. Rotation angle in degrees,
    #'   counter-clockwise.
    #' @param cx Single positive numeric. X coordinate of the rotation centre
    #'   (1-based). Defaults to image centre.
    #' @param cy Single positive numeric. Y coordinate of the rotation centre
    #'   (1-based). Defaults to image centre.
    #' @param scale Single positive numeric. Isotropic scale factor applied
    #'   during rotation. Default \code{1}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"reflect_101"}, \code{"reflect"}, \code{"replicate"},
    #'   \code{"constant"}, \code{"wrap"}. Default \code{"reflect_101"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$rotate(45)$plot()
    #' }
    rotate = function(angle, cx = NULL, cy = NULL, scale = 1,
                      interpolation = "linear", border_type = "reflect_101") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      if (!is.numeric(angle) || length(angle) != 1L)
        stop("angle must be a single numeric value", call. = FALSE)
      if (!is.null(cx) && (!is.numeric(cx) || length(cx) != 1L ||
                           cx < 1 || cx > self$ncol))
        stop("cx and cy must be single positive numeric values within image dimensions",
             call. = FALSE)
      if (!is.null(cy) && (!is.numeric(cy) || length(cy) != 1L ||
                           cy < 1 || cy > self$nrow))
        stop("cx and cy must be single positive numeric values within image dimensions",
             call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .cx <- if (is.null(cx)) self$ncol / 2 else as.double(cx)
      .cy <- if (is.null(cy)) self$nrow / 2 else as.double(cy)
      Image$new(rt_image_rotate(private$.ptr, as.double(angle), .cx, .cy,
                                as.double(scale), interpolation, border_type))
    },

    #' @description Rotate the image in place.
    #' @param angle Single numeric. Rotation angle in degrees,
    #'   counter-clockwise.
    #' @param cx Single positive numeric. X coordinate of the rotation centre
    #'   (1-based). Defaults to image centre.
    #' @param cy Single positive numeric. Y coordinate of the rotation centre
    #'   (1-based). Defaults to image centre.
    #' @param scale Single positive numeric. Isotropic scale factor. Default
    #'   \code{1}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"reflect_101"}, \code{"reflect"}, \code{"replicate"},
    #'   \code{"constant"}, \code{"wrap"}. Default \code{"reflect_101"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$rotate_(45)
    #' img$plot()
    #' }
    rotate_ = function(angle, cx = NULL, cy = NULL, scale = 1,
                       interpolation = "linear", border_type = "reflect_101") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border <- c("reflect", "reflect_101", "replicate", "constant", "wrap")
      if (!is.numeric(angle) || length(angle) != 1L)
        stop("angle must be a single numeric value", call. = FALSE)
      if (!is.null(cx) && (!is.numeric(cx) || length(cx) != 1L ||
                           cx < 1 || cx > self$ncol))
        stop("cx and cy must be single positive numeric values within image dimensions",
             call. = FALSE)
      if (!is.null(cy) && (!is.numeric(cy) || length(cy) != 1L ||
                           cy < 1 || cy > self$nrow))
        stop("cx and cy must be single positive numeric values within image dimensions",
             call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .cx <- if (is.null(cx)) self$ncol / 2 else as.double(cx)
      .cy <- if (is.null(cy)) self$nrow / 2 else as.double(cy)
      private$.ptr <- rt_image_rotate(private$.ptr, as.double(angle), .cx, .cy,
                                      as.double(scale), interpolation, border_type)
      invisible(self)
    },

    #' @description Flip the image horizontally, vertically, or both. Returns
    #'   a new Image.
    #' @param flip_h Logical scalar. If \code{TRUE}, flip left-right.
    #'   Default \code{FALSE}.
    #' @param flip_v Logical scalar. If \code{TRUE}, flip top-bottom.
    #'   Default \code{FALSE}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$flip(flip_h = TRUE)$plot()
    #' }
    flip = function(flip_h = FALSE, flip_v = FALSE) {
      if (!is.logical(flip_h) || length(flip_h) != 1L ||
          !is.logical(flip_v) || length(flip_v) != 1L)
        stop("flip_h and flip_v must be single logical values", call. = FALSE)
      if (!flip_h && !flip_v)
        stop("at least one of flip_h or flip_v must be TRUE", call. = FALSE)
      .flip_code <- if (flip_h && flip_v) -1L else if (flip_h) 1L else 0L
      Image$new(rt_image_flip(private$.ptr, .flip_code))
    },

    #' @description Flip the image in place.
    #' @param flip_h Logical scalar. If \code{TRUE}, flip left-right.
    #'   Default \code{FALSE}.
    #' @param flip_v Logical scalar. If \code{TRUE}, flip top-bottom.
    #'   Default \code{FALSE}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$flip_(flip_v = TRUE)
    #' img$plot()
    #' }
    flip_ = function(flip_h = FALSE, flip_v = FALSE) {
      if (!is.logical(flip_h) || length(flip_h) != 1L ||
          !is.logical(flip_v) || length(flip_v) != 1L)
        stop("flip_h and flip_v must be single logical values", call. = FALSE)
      if (!flip_h && !flip_v)
        stop("at least one of flip_h or flip_v must be TRUE", call. = FALSE)
      .flip_code <- if (flip_h && flip_v) -1L else if (flip_h) 1L else 0L
      private$.ptr <- rt_image_flip(private$.ptr, .flip_code)
      invisible(self)
    },

    #' @description Crop the image to a rectangular region. Returns a new
    #'   Image. Coordinates are 1-based.
    #' @param x1 Single positive integer. Left column (inclusive, 1-based).
    #' @param y1 Single positive integer. Top row (inclusive, 1-based).
    #' @param x2 Single positive integer. Right column (inclusive, 1-based).
    #'   Must be greater than \code{x1} and \code{<= ncol}.
    #' @param y2 Single positive integer. Bottom row (inclusive, 1-based).
    #'   Must be greater than \code{y1} and \code{<= nrow}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$crop(1L, 1L, 100L, 100L)$plot()
    #' }
    crop = function(x1, y1, x2, y2) {
      if (!is.numeric(x1) || !is.numeric(y1) ||
          !is.numeric(x2) || !is.numeric(y2) ||
          length(x1) != 1L || length(y1) != 1L ||
          length(x2) != 1L || length(y2) != 1L ||
          x1 < 1L || y1 < 1L || x2 < 1L || y2 < 1L)
        stop("x1, y1, x2, y2 must be single positive integers", call. = FALSE)
      if (x1 != as.integer(x1) || y1 != as.integer(y1) ||
          x2 != as.integer(x2) || y2 != as.integer(y2))
        stop("x1, y1, x2, y2 must be single positive integers", call. = FALSE)
      if (x1 >= x2)
        stop("x1 must be less than x2", call. = FALSE)
      if (y1 >= y2)
        stop("y1 must be less than y2", call. = FALSE)
      if (x2 > self$ncol || y2 > self$nrow)
        stop("crop coordinates exceed image dimensions", call. = FALSE)
      Image$new(rt_image_crop(private$.ptr,
                              as.integer(x1), as.integer(y1),
                              as.integer(x2), as.integer(y2)))
    },

    #' @description Crop the image in place.
    #' @param x1 Single positive integer. Left column (inclusive, 1-based).
    #' @param y1 Single positive integer. Top row (inclusive, 1-based).
    #' @param x2 Single positive integer. Right column (inclusive, 1-based).
    #' @param y2 Single positive integer. Bottom row (inclusive, 1-based).
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$crop_(1L, 1L, 100L, 100L)
    #' img$plot()
    #' }
    crop_ = function(x1, y1, x2, y2) {
      if (!is.numeric(x1) || !is.numeric(y1) ||
          !is.numeric(x2) || !is.numeric(y2) ||
          length(x1) != 1L || length(y1) != 1L ||
          length(x2) != 1L || length(y2) != 1L ||
          x1 < 1L || y1 < 1L || x2 < 1L || y2 < 1L)
        stop("x1, y1, x2, y2 must be single positive integers", call. = FALSE)
      if (x1 != as.integer(x1) || y1 != as.integer(y1) ||
          x2 != as.integer(x2) || y2 != as.integer(y2))
        stop("x1, y1, x2, y2 must be single positive integers", call. = FALSE)
      if (x1 >= x2)
        stop("x1 must be less than x2", call. = FALSE)
      if (y1 >= y2)
        stop("y1 must be less than y2", call. = FALSE)
      if (x2 > self$ncol || y2 > self$nrow)
        stop("crop coordinates exceed image dimensions", call. = FALSE)
      private$.ptr <- rt_image_crop(private$.ptr,
                                    as.integer(x1), as.integer(y1),
                                    as.integer(x2), as.integer(y2))
      invisible(self)
    },

    #' @description Apply an affine transformation to the image. Returns a new
    #'   Image. Output defaults to the same dimensions as the input; content
    #'   outside the canvas is clipped.
    #' @param m A 2x3 numeric matrix representing the affine transformation.
    #'   Build one with \code{\link{affine_translate}},
    #'   \code{\link{affine_scale}}, \code{\link{affine_shear}},
    #'   \code{\link{affine_rotate}}, or \code{\link{affine_from_points}}.
    #'   Compose multiple transforms by embedding into 3x3 with
    #'   \code{rbind(m, c(0, 0, 1))} then multiplying with \code{\%*\%}.
    #' @param width Positive integer. Output width in pixels. Default:
    #'   \code{self$ncol}.
    #' @param height Positive integer. Output height in pixels. Default:
    #'   \code{self$nrow}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"wrap"} tiles the image;
    #'   \code{"constant"} fills with a fixed value (0, i.e. black).
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' m <- affine_translate(50, 30)
    #' img$warp_affine(m)$plot()
    #' }
    warp_affine = function(m, width = NULL, height = NULL,
                           interpolation = "linear", border_type = "reflect_101") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("reflect", "reflect_101",
                          "replicate", "constant", "wrap")
      if (!is.matrix(m) || !is.numeric(m) || !identical(dim(m), c(2L, 3L)))
        stop("m must be a 2x3 numeric matrix", call. = FALSE)
      if (!is.null(width) && (!is.numeric(width) || length(width) != 1L ||
                              !isTRUE(width >= 1L) || !isTRUE(width == as.integer(width))))
        stop("width must be a single positive integer", call. = FALSE)
      if (!is.null(height) && (!is.numeric(height) || length(height) != 1L ||
                               !isTRUE(height >= 1L) || !isTRUE(height == as.integer(height))))
        stop("height must be a single positive integer", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .w <- if (is.null(width))  self$ncol else as.integer(width)
      .h <- if (is.null(height)) self$nrow else as.integer(height)
      Image$new(rt_image_warp_affine(private$.ptr, as.double(m),
                                     .w, .h, interpolation, border_type))
    },

    #' @description Apply an affine transformation to the image in place.
    #' @param m A 2x3 numeric matrix representing the affine transformation.
    #'   Build one with \code{\link{affine_translate}},
    #'   \code{\link{affine_scale}}, \code{\link{affine_shear}},
    #'   \code{\link{affine_rotate}}, or \code{\link{affine_from_points}}.
    #'   Compose multiple transforms by embedding into 3x3 with
    #'   \code{rbind(m, c(0, 0, 1))} then multiplying with \code{\%*\%}.
    #' @param width Positive integer. Output width in pixels. Default:
    #'   \code{self$ncol}.
    #' @param height Positive integer. Output height in pixels. Default:
    #'   \code{self$nrow}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"wrap"} tiles the image;
    #'   \code{"constant"} fills with a fixed value (0, i.e. black).
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$warp_affine_(affine_translate(50, 30))
    #' img$plot()
    #' }
    warp_affine_ = function(m, width = NULL, height = NULL,
                            interpolation = "linear", border_type = "reflect_101") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("reflect", "reflect_101",
                          "replicate", "constant", "wrap")
      if (!is.matrix(m) || !is.numeric(m) || !identical(dim(m), c(2L, 3L)))
        stop("m must be a 2x3 numeric matrix", call. = FALSE)
      if (!is.null(width) && (!is.numeric(width) || length(width) != 1L ||
                              !isTRUE(width >= 1L) || !isTRUE(width == as.integer(width))))
        stop("width must be a single positive integer", call. = FALSE)
      if (!is.null(height) && (!is.numeric(height) || length(height) != 1L ||
                               !isTRUE(height >= 1L) || !isTRUE(height == as.integer(height))))
        stop("height must be a single positive integer", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .w <- if (is.null(width))  self$ncol else as.integer(width)
      .h <- if (is.null(height)) self$nrow else as.integer(height)
      private$.ptr <- rt_image_warp_affine(private$.ptr, as.double(m),
                                           .w, .h, interpolation, border_type)
      invisible(self)
    },

    #' @description Apply a perspective transformation to the image. Returns a
    #'   new Image. Output defaults to the same dimensions as the input; content
    #'   outside the canvas is clipped.
    #' @param m A 3x3 numeric matrix representing the perspective transformation.
    #'   Build one with \code{\link{perspective_from_points}}.
    #' @param width Positive integer. Output width in pixels. Default:
    #'   \code{self$ncol}.
    #' @param height Positive integer. Output height in pixels. Default:
    #'   \code{self$nrow}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"wrap"} tiles the image;
    #'   \code{"constant"} fills with a fixed value (0, i.e. black).
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' w <- img$ncol; h <- img$nrow
    #' src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    #' dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    #' m <- perspective_from_points(src, dst)
    #' img$warp_perspective(m)$plot()
    #' }
    warp_perspective = function(m, width = NULL, height = NULL,
                                interpolation = "linear", border_type = "reflect_101") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("reflect", "reflect_101",
                          "replicate", "constant", "wrap")
      if (!is.matrix(m) || !is.numeric(m) || !identical(dim(m), c(3L, 3L)))
        stop("m must be a 3x3 numeric matrix", call. = FALSE)
      if (!is.null(width) && (!is.numeric(width) || length(width) != 1L ||
                              !isTRUE(width >= 1L) || !isTRUE(width == as.integer(width))))
        stop("width must be a single positive integer", call. = FALSE)
      if (!is.null(height) && (!is.numeric(height) || length(height) != 1L ||
                               !isTRUE(height >= 1L) || !isTRUE(height == as.integer(height))))
        stop("height must be a single positive integer", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .w <- if (is.null(width))  self$ncol else as.integer(width)
      .h <- if (is.null(height)) self$nrow else as.integer(height)
      Image$new(rt_image_warp_perspective(private$.ptr, as.double(m),
                                          .w, .h, interpolation, border_type))
    },

    #' @description Apply a perspective transformation to the image in place.
    #' @param m A 3x3 numeric matrix representing the perspective transformation.
    #'   Build one with \code{\link{perspective_from_points}}.
    #' @param width Positive integer. Output width in pixels. Default:
    #'   \code{self$ncol}.
    #' @param height Positive integer. Output height in pixels. Default:
    #'   \code{self$nrow}.
    #' @param interpolation Character. One of \code{"nearest"}, \code{"linear"},
    #'   \code{"cubic"}, \code{"area"}, \code{"lanczos4"}. Default
    #'   \code{"linear"}.
    #' @param border_type Character. How to fill pixels outside the image
    #'   boundary. \code{"reflect_101"} (default) mirrors the image excluding
    #'   the edge pixel (e.g. dcb|abcde|dcb); \code{"reflect"} mirrors
    #'   including the edge pixel (e.g. edcb|abcde|edcb); \code{"replicate"}
    #'   repeats the nearest edge pixel; \code{"wrap"} tiles the image;
    #'   \code{"constant"} fills with a fixed value (0, i.e. black).
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' w <- img$ncol; h <- img$nrow
    #' src <- matrix(c(1, 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    #' dst <- matrix(c(round(w*0.1), 1,  w, 1,  w, h,  1, h), nrow = 4, byrow = TRUE)
    #' img$warp_perspective_(perspective_from_points(src, dst))
    #' img$plot()
    #' }
    warp_perspective_ = function(m, width = NULL, height = NULL,
                                 interpolation = "linear", border_type = "reflect_101") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("reflect", "reflect_101",
                          "replicate", "constant", "wrap")
      if (!is.matrix(m) || !is.numeric(m) || !identical(dim(m), c(3L, 3L)))
        stop("m must be a 3x3 numeric matrix", call. = FALSE)
      if (!is.null(width) && (!is.numeric(width) || length(width) != 1L ||
                              !isTRUE(width >= 1L) || !isTRUE(width == as.integer(width))))
        stop("width must be a single positive integer", call. = FALSE)
      if (!is.null(height) && (!is.numeric(height) || length(height) != 1L ||
                               !isTRUE(height >= 1L) || !isTRUE(height == as.integer(height))))
        stop("height must be a single positive integer", call. = FALSE)
      if (!is.character(interpolation) || length(interpolation) != 1L ||
          !interpolation %in% .valid_interp)
        stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4",
             call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .w <- if (is.null(width))  self$ncol else as.integer(width)
      .h <- if (is.null(height)) self$nrow else as.integer(height)
      private$.ptr <- rt_image_warp_perspective(private$.ptr, as.double(m),
                                                .w, .h, interpolation, border_type)
      invisible(self)
    },

    #' @description Add a border around the image.
    #'
    #' The argument order `(top, left, bottom, right)` is deliberately different
    #' from the CSS shorthand (`top, right, bottom, left`) and from OpenCV's
    #' `copyMakeBorder` (`top, bottom, left, right`). With this order, the
    #' two-argument form `$border(v, h)` adds `v` pixels vertically (top and
    #' bottom) and `h` pixels horizontally (left and right) — the most natural
    #' two-argument case for symmetric borders.
    #'
    #' @param top Integer. Border width in pixels on the top edge.
    #' @param left Integer. Border width on the left edge. Defaults to `top`.
    #' @param bottom Integer. Border width on the bottom edge. Defaults to `top`.
    #' @param right Integer. Border width on the right edge. Defaults to `left`.
    #' @param type Character. Border fill mode. `"constant"` (default) fills
    #'   with a fixed colour (see `value`); `"reflect"` mirrors the image
    #'   including the edge pixel; `"reflect_101"` mirrors excluding the edge
    #'   pixel; `"replicate"` repeats the nearest edge pixel; `"wrap"` tiles
    #'   the image.
    #' @param value Numeric vector of length 1 or `nchan`. Fill colour used when
    #'   `type = "constant"`. Recycled to `nchan` values. Default 0 (black).
    #' @return A new `Image`.
    border = function(top, left = top, bottom = top, right = left,
                      type = "constant", value = 0) {
      for (nm in c("top", "left", "bottom", "right")) {
        v <- get(nm)
        if (length(v) != 1L || !isTRUE(v >= 0L) || !isTRUE(v == as.integer(v)))
          stop(nm, " must be a single non-negative integer", call. = FALSE)
      }
      valid_types <- c("constant", "reflect", "reflect_101", "replicate", "wrap")
      if (!is.character(type) || length(type) != 1L || !type %in% valid_types)
        stop("type must be one of: ", paste(valid_types, collapse = ", "), call. = FALSE)
      if (!is.numeric(value) || length(value) < 1L || anyNA(value))
        stop("value must be a non-empty numeric vector with no NAs", call. = FALSE)
      Image$new(rt_image_border(private$.ptr,
                                as.integer(top), as.integer(bottom),
                                as.integer(left), as.integer(right),
                                type, as.double(rep_len(value, self$nchan))))
    },

    #' @description Add a border around the image, in place.
    #'
    #' See `$border()` for the rationale behind the argument order
    #' `(top, left, bottom, right)`.
    #'
    #' @param top Integer. Border width on the top edge.
    #' @param left Integer. Defaults to `top`.
    #' @param bottom Integer. Defaults to `top`.
    #' @param right Integer. Defaults to `left`.
    #' @param type Character. Border fill mode. `"constant"` (default) fills
    #'   with a fixed colour (see `value`); `"reflect"` mirrors the image
    #'   including the edge pixel; `"reflect_101"` mirrors excluding the edge
    #'   pixel; `"replicate"` repeats the nearest edge pixel; `"wrap"` tiles
    #'   the image.
    #' @param value Numeric vector of length 1 or `nchan`. Fill colour used when
    #'   `type = "constant"`. Recycled to `nchan` values. Default 0 (black).
    #' @return `self` invisibly.
    border_ = function(top, left = top, bottom = top, right = left,
                       type = "constant", value = 0) {
      for (nm in c("top", "left", "bottom", "right")) {
        v <- get(nm)
        if (length(v) != 1L || !isTRUE(v >= 0L) || !isTRUE(v == as.integer(v)))
          stop(nm, " must be a single non-negative integer", call. = FALSE)
      }
      valid_types <- c("constant", "reflect", "reflect_101", "replicate", "wrap")
      if (!is.character(type) || length(type) != 1L || !type %in% valid_types)
        stop("type must be one of: ", paste(valid_types, collapse = ", "), call. = FALSE)
      if (!is.numeric(value) || length(value) < 1L || anyNA(value))
        stop("value must be a non-empty numeric vector with no NAs", call. = FALSE)
      private$.ptr <- rt_image_border(private$.ptr,
                                       as.integer(top), as.integer(bottom),
                                       as.integer(left), as.integer(right),
                                       type, as.double(rep_len(value, self$nchan)))
      invisible(self)
    },

    #' @description Tile (repeat) the image in a grid.
    #' @param nrow Integer. Number of vertical repetitions.
    #' @param ncol Integer. Number of horizontal repetitions. Defaults to `nrow`.
    #' @return A new `Image` with dimensions `nrow * self$nrow` x `ncol * self$ncol`.
    tile = function(nrow, ncol = nrow) {
      if (length(nrow) != 1L || !isTRUE(nrow >= 1L) || !isTRUE(nrow == as.integer(nrow)))
        stop("nrow must be a single positive integer", call. = FALSE)
      if (length(ncol) != 1L || !isTRUE(ncol >= 1L) || !isTRUE(ncol == as.integer(ncol)))
        stop("ncol must be a single positive integer", call. = FALSE)
      Image$new(rt_image_tile(private$.ptr, as.integer(nrow), as.integer(ncol)))
    },

    #' @description Tile (repeat) the image in a grid, in place.
    #' @param nrow Integer. Number of vertical repetitions.
    #' @param ncol Integer. Number of horizontal repetitions. Defaults to `nrow`.
    #' @return `self` invisibly.
    tile_ = function(nrow, ncol = nrow) {
      if (length(nrow) != 1L || !isTRUE(nrow >= 1L) || !isTRUE(nrow == as.integer(nrow)))
        stop("nrow must be a single positive integer", call. = FALSE)
      if (length(ncol) != 1L || !isTRUE(ncol >= 1L) || !isTRUE(ncol == as.integer(ncol)))
        stop("ncol must be a single positive integer", call. = FALSE)
      private$.ptr <- rt_image_tile(private$.ptr, as.integer(nrow), as.integer(ncol))
      invisible(self)
    },

    #' @description Set all pixels — or only masked pixels — to a constant value.
    #' @param value Numeric scalar or vector of length `nchan`. Recycled to
    #'   `nchan` channels. No NAs.
    #' @param mask `NULL` (apply to all pixels) or a single-channel `CV_8U`
    #'   `Image` with the same `nrow` and `ncol`. Non-zero pixels mark where
    #'   `value` is written.
    #' @return A new `Image`.
    set_to = function(value, mask = NULL) {
      if (!is.numeric(value) || length(value) < 1L || anyNA(value) ||
          !all(is.finite(value)))
        stop("value must be a non-empty finite numeric vector with no NAs", call. = FALSE)
      if (!is.null(mask)) {
        if (!inherits(mask, "Image"))
          stop("mask must be an Image", call. = FALSE)
        if (mask$nchan != 1L)
          stop("mask must be a single-channel image", call. = FALSE)
        if (mask$depth_name != "CV_8U")
          stop("mask must be CV_8U depth", call. = FALSE)
        if (mask$nrow != self$nrow || mask$ncol != self$ncol)
          stop("mask dimensions must match image dimensions", call. = FALSE)
      }
      value_v  <- as.double(rep_len(value, self$nchan))
      mask_ptr <- if (is.null(mask)) NULL else .rt_ptr(mask)
      Image$new(rt_image_set_to(private$.ptr, value_v, mask_ptr))
    },

    #' @description Set all pixels — or only masked pixels — to a constant
    #'   value, in place.
    #' @param value Numeric scalar or vector of length `nchan`. Recycled to
    #'   `nchan` channels. No NAs.
    #' @param mask `NULL` or a single-channel `CV_8U` `Image` same size as self.
    #' @return `self` invisibly.
    set_to_ = function(value, mask = NULL) {
      if (!is.numeric(value) || length(value) < 1L || anyNA(value) ||
          !all(is.finite(value)))
        stop("value must be a non-empty finite numeric vector with no NAs", call. = FALSE)
      if (!is.null(mask)) {
        if (!inherits(mask, "Image"))
          stop("mask must be an Image", call. = FALSE)
        if (mask$nchan != 1L)
          stop("mask must be a single-channel image", call. = FALSE)
        if (mask$depth_name != "CV_8U")
          stop("mask must be CV_8U depth", call. = FALSE)
        if (mask$nrow != self$nrow || mask$ncol != self$ncol)
          stop("mask dimensions must match image dimensions", call. = FALSE)
      }
      value_v  <- as.double(rep_len(value, self$nchan))
      mask_ptr <- if (is.null(mask)) NULL else .rt_ptr(mask)
      private$.ptr <- rt_image_set_to(private$.ptr, value_v, mask_ptr)
      invisible(self)
    },

    #' @description Apply a threshold to the image.
    #' @param thresh Single finite numeric or one of 17 lowercase auto-threshold
    #'   method strings. When numeric, passed directly to OpenCV. When a string,
    #'   the threshold is auto-computed from the image histogram.
    #' @param maxval Single finite numeric. Value assigned to above-threshold
    #'   pixels in `"binary"` and `"binary_inv"` modes. Default `255`.
    #' @param type Character. How pixel values are mapped relative to the
    #'   threshold `T`. `"binary"` (default): above `T` → `maxval`, at or
    #'   below → 0. `"binary_inv"`: above `T` → 0, at or below → `maxval`.
    #'   `"trunc"`: above `T` → `T`, at or below → unchanged (acts as a
    #'   ceiling). `"tozero"`: at or below `T` → 0, above → unchanged.
    #'   `"tozero_inv"`: above `T` → 0, at or below → unchanged. `maxval` is
    #'   only used by `"binary"` and `"binary_inv"`.
    #' @param bins Single integer >= 2. Histogram bins for auto-threshold on
    #'   non-`CV_8U` images. Ignored when `thresh` is numeric or for `CV_8U`.
    #'   Default `256`.
    #' @return A new `Image`.
    threshold = function(thresh, maxval = 255, type = "binary", bins = 256L) {
      if (is.character(thresh)) {
        if (length(thresh) != 1L || !(thresh %in% .autothresh_methods))
          stop(sprintf("thresh must be a single finite numeric or one of: %s",
                       paste(.autothresh_methods, collapse = ", ")), call. = FALSE)
        if (self$nchan != 1L)
          stop("auto-threshold methods require a single-channel image", call. = FALSE)
        bins_i <- as.integer(bins)
        if (!is.numeric(bins) || length(bins) != 1L || is.na(bins_i) || bins_i < 2L)
          stop("bins must be a single integer >= 2", call. = FALSE)
        thresh_val <- rt_autothreshold_value(private$.ptr, thresh, bins_i)
      } else {
        if (!is.numeric(thresh) || length(thresh) != 1L || !is.finite(thresh))
          stop("thresh must be a single finite numeric or a method string", call. = FALSE)
        thresh_val <- as.double(thresh)
      }
      if (!is.numeric(maxval) || length(maxval) != 1L || !is.finite(maxval))
        stop("maxval must be a single finite numeric", call. = FALSE)
      type_int <- switch(type,
        binary     = 0L,
        binary_inv = 1L,
        trunc      = 2L,
        tozero     = 3L,
        tozero_inv = 4L,
        stop("type must be one of: binary, binary_inv, trunc, tozero, tozero_inv",
             call. = FALSE)
      )
      Image$new(rt_image_threshold(private$.ptr, thresh_val, as.double(maxval), type_int))
    },

    #' @description Apply a threshold to the image, in place.
    #' @param thresh See `$threshold()`.
    #' @param maxval See `$threshold()`.
    #' @param type See `$threshold()` for a description of all five modes.
    #' @param bins See `$threshold()`.
    #' @return `self` invisibly.
    threshold_ = function(thresh, maxval = 255, type = "binary", bins = 256L) {
      if (is.character(thresh)) {
        if (length(thresh) != 1L || !(thresh %in% .autothresh_methods))
          stop(sprintf("thresh must be a single finite numeric or one of: %s",
                       paste(.autothresh_methods, collapse = ", ")), call. = FALSE)
        if (self$nchan != 1L)
          stop("auto-threshold methods require a single-channel image", call. = FALSE)
        bins_i <- as.integer(bins)
        if (!is.numeric(bins) || length(bins) != 1L || is.na(bins_i) || bins_i < 2L)
          stop("bins must be a single integer >= 2", call. = FALSE)
        thresh_val <- rt_autothreshold_value(private$.ptr, thresh, bins_i)
      } else {
        if (!is.numeric(thresh) || length(thresh) != 1L || !is.finite(thresh))
          stop("thresh must be a single finite numeric or a method string", call. = FALSE)
        thresh_val <- as.double(thresh)
      }
      if (!is.numeric(maxval) || length(maxval) != 1L || !is.finite(maxval))
        stop("maxval must be a single finite numeric", call. = FALSE)
      type_int <- switch(type,
        binary     = 0L,
        binary_inv = 1L,
        trunc      = 2L,
        tozero     = 3L,
        tozero_inv = 4L,
        stop("type must be one of: binary, binary_inv, trunc, tozero, tozero_inv",
             call. = FALSE)
      )
      private$.ptr <- rt_image_threshold(private$.ptr, thresh_val, as.double(maxval), type_int)
      invisible(self)
    },

    #' @description Apply an adaptive threshold to the image.
    #' @param maxval Single finite numeric. Value for above-threshold pixels.
    #'   Default `255`.
    #' @param method `"mean"` (local neighbourhood mean) or `"gaussian"`
    #'   (Gaussian-weighted neighbourhood). Default `"mean"`.
    #' @param type `"binary"` (default): pixels above the local threshold →
    #'   `maxval`, others → 0. `"binary_inv"`: inverted — pixels above → 0,
    #'   others → `maxval`.
    #' @param block_size Single odd integer >= 3. Neighbourhood size.
    #'   Default `11`.
    #' @param offset Single finite numeric. Constant subtracted from the local
    #'   mean (OpenCV's `C` parameter). May be negative. Default `2`.
    #' @return A new single-channel `CV_8U` `Image` with colorspace `"GRAY"`.
    adaptive_threshold = function(maxval = 255, method = "mean",
                                   type = "binary", block_size = 11L,
                                   offset = 2) {
      if (self$nchan != 1L || self$depth_name != "CV_8U")
        stop("adaptive_threshold() requires a single-channel CV_8U image",
             call. = FALSE)
      if (!is.numeric(maxval) || length(maxval) != 1L || !is.finite(maxval))
        stop("maxval must be a single finite numeric", call. = FALSE)
      method_int <- switch(method,
        mean     = 0L,
        gaussian = 1L,
        stop("method must be one of: mean, gaussian", call. = FALSE)
      )
      type_int <- switch(type,
        binary     = 0L,
        binary_inv = 1L,
        stop("type must be one of: binary, binary_inv", call. = FALSE)
      )
      bs <- as.integer(block_size)
      if (!is.numeric(block_size) || length(block_size) != 1L ||
          is.na(bs) || bs < 3L || bs %% 2L == 0L)
        stop("block_size must be a single odd integer >= 3", call. = FALSE)
      if (!is.numeric(offset) || length(offset) != 1L || !is.finite(offset))
        stop("offset must be a single finite numeric", call. = FALSE)
      Image$new(rt_image_adaptive_threshold(
        private$.ptr, as.double(maxval), method_int, type_int,
        bs, as.double(offset)))
    },

    #' @description Apply an adaptive threshold to the image, in place.
    #' @param maxval See `$adaptive_threshold()`.
    #' @param method See `$adaptive_threshold()`.
    #' @param type See `$adaptive_threshold()` for a description of both modes.
    #' @param block_size See `$adaptive_threshold()`.
    #' @param offset See `$adaptive_threshold()`.
    #' @return `self` invisibly.
    adaptive_threshold_ = function(maxval = 255, method = "mean",
                                    type = "binary", block_size = 11L,
                                    offset = 2) {
      if (self$nchan != 1L || self$depth_name != "CV_8U")
        stop("adaptive_threshold() requires a single-channel CV_8U image",
             call. = FALSE)
      if (!is.numeric(maxval) || length(maxval) != 1L || !is.finite(maxval))
        stop("maxval must be a single finite numeric", call. = FALSE)
      method_int <- switch(method,
        mean     = 0L,
        gaussian = 1L,
        stop("method must be one of: mean, gaussian", call. = FALSE)
      )
      type_int <- switch(type,
        binary     = 0L,
        binary_inv = 1L,
        stop("type must be one of: binary, binary_inv", call. = FALSE)
      )
      bs <- as.integer(block_size)
      if (!is.numeric(block_size) || length(block_size) != 1L ||
          is.na(bs) || bs < 3L || bs %% 2L == 0L)
        stop("block_size must be a single odd integer >= 3", call. = FALSE)
      if (!is.numeric(offset) || length(offset) != 1L || !is.finite(offset))
        stop("offset must be a single finite numeric", call. = FALSE)
      private$.ptr <- rt_image_adaptive_threshold(
        private$.ptr, as.double(maxval), method_int, type_int,
        bs, as.double(offset))
      invisible(self)
    },

    #' @description Create a binary mask where each pixel is 255 if all channels
    #'   fall within `[lower[k], upper[k]]`, and 0 otherwise.
    #' @param lower Numeric vector of length 1 or `nchan`. Lower bound per
    #'   channel. Recycled to `nchan`. No NAs; all finite.
    #' @param upper Numeric vector of length 1 or `nchan`. Upper bound per
    #'   channel. Recycled to `nchan`. No NAs; all finite.
    #' @return A new single-channel `CV_8U` `Image` with colorspace `"GRAY"`.
    in_range = function(lower, upper) {
      .nchan <- self$nchan
      if (!is.numeric(lower) || anyNA(lower) || !all(is.finite(lower)))
        stop("lower must be a finite numeric vector with no NAs", call. = FALSE)
      if (!is.numeric(upper) || anyNA(upper) || !all(is.finite(upper)))
        stop("upper must be a finite numeric vector with no NAs", call. = FALSE)
      if (!(length(lower) %in% c(1L, .nchan)))
        stop(sprintf("lower must have length 1 or %d (nchan)", .nchan), call. = FALSE)
      if (!(length(upper) %in% c(1L, .nchan)))
        stop(sprintf("upper must have length 1 or %d (nchan)", .nchan), call. = FALSE)
      lo <- as.double(rep_len(lower, .nchan))
      hi <- as.double(rep_len(upper, .nchan))
      if (any(lo > hi))
        stop("each lower[k] must be <= upper[k]", call. = FALSE)
      Image$new(rt_image_in_range(private$.ptr, lo, hi))
    },

    #' @description Create a binary mask in place. See `$in_range()`.
    #' @param lower See `$in_range()`.
    #' @param upper See `$in_range()`.
    #' @return `self` invisibly.
    in_range_ = function(lower, upper) {
      .nchan <- self$nchan
      if (!is.numeric(lower) || anyNA(lower) || !all(is.finite(lower)))
        stop("lower must be a finite numeric vector with no NAs", call. = FALSE)
      if (!is.numeric(upper) || anyNA(upper) || !all(is.finite(upper)))
        stop("upper must be a finite numeric vector with no NAs", call. = FALSE)
      if (!(length(lower) %in% c(1L, .nchan)))
        stop(sprintf("lower must have length 1 or %d (nchan)", .nchan), call. = FALSE)
      if (!(length(upper) %in% c(1L, .nchan)))
        stop(sprintf("upper must have length 1 or %d (nchan)", .nchan), call. = FALSE)
      lo <- as.double(rep_len(lower, .nchan))
      hi <- as.double(rep_len(upper, .nchan))
      if (any(lo > hi))
        stop("each lower[k] must be <= upper[k]", call. = FALSE)
      private$.ptr <- rt_image_in_range(private$.ptr, lo, hi)
      invisible(self)
    },

    #' @description Draw a line segment on the image. Returns a new Image.
    #' @param x1 Positive integer. X (column) coordinate of the start point.
    #' @param y1 Positive integer. Y (row) coordinate of the start point.
    #' @param x2 Positive integer. X (column) coordinate of the end point.
    #' @param y2 Positive integer. Y (row) coordinate of the end point.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"} (4-connected),
    #'   \code{"line_8"} (8-connected, default), \code{"aa"} (anti-aliased;
    #'   8-bit images only).
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_line(1, 1, 100, 100, color = "red")$plot()
    #' }
    draw_line = function(x1, y1, x2, y2, color, thickness = 1L,
                         line_type = "line_8") {
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      Image$new(rt_draw_line(private$.ptr,
                             as.integer(x1), as.integer(y1),
                             as.integer(x2), as.integer(y2),
                             .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw a line segment on the image in place.
    #' @param x1 Positive integer. X (column) coordinate of the start point.
    #' @param y1 Positive integer. Y (row) coordinate of the start point.
    #' @param x2 Positive integer. X (column) coordinate of the end point.
    #' @param y2 Positive integer. Y (row) coordinate of the end point.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return \code{self} invisibly.
    draw_line_ = function(x1, y1, x2, y2, color, thickness = 1L,
                          line_type = "line_8") {
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      private$.ptr <- rt_draw_line(private$.ptr,
                                   as.integer(x1), as.integer(y1),
                                   as.integer(x2), as.integer(y2),
                                   .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw an arrowed line on the image. Returns a new Image.
    #' @param x1 Positive integer. X coordinate of the arrow tail.
    #' @param y1 Positive integer. Y coordinate of the arrow tail.
    #' @param x2 Positive integer. X coordinate of the arrowhead tip.
    #' @param y2 Positive integer. Y coordinate of the arrowhead tip.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param tip_length Numeric. Arrowhead length as a proportion of total
    #'   arrow length. Negative values produce a reversed arrowhead. Default
    #'   \code{0.1}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_arrow(10, 10, 100, 100, color = "blue")$plot()
    #' }
    draw_arrow = function(x1, y1, x2, y2, color, thickness = 1L,
                          line_type = "line_8", tip_length = 0.1) {
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      Image$new(rt_draw_arrow(private$.ptr,
                              as.integer(x1), as.integer(y1),
                              as.integer(x2), as.integer(y2),
                              .a$color, .a$thickness, .a$line_type,
                              as.double(tip_length)))
    },

    #' @description Draw an arrowed line on the image in place.
    #' @param x1 Positive integer. X coordinate of the arrow tail.
    #' @param y1 Positive integer. Y coordinate of the arrow tail.
    #' @param x2 Positive integer. X coordinate of the arrowhead tip.
    #' @param y2 Positive integer. Y coordinate of the arrowhead tip.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param tip_length Numeric. Arrowhead length as a proportion of total
    #'   arrow length. Default \code{0.1}.
    #' @return \code{self} invisibly.
    draw_arrow_ = function(x1, y1, x2, y2, color, thickness = 1L,
                           line_type = "line_8", tip_length = 0.1) {
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      private$.ptr <- rt_draw_arrow(private$.ptr,
                                    as.integer(x1), as.integer(y1),
                                    as.integer(x2), as.integer(y2),
                                    .a$color, .a$thickness, .a$line_type,
                                    as.double(tip_length))
      invisible(self)
    },

    #' @description Draw a rectangle outline (or filled rectangle) on the
    #'   image. Returns a new Image.
    #' @param x1 Integer. X coordinate of one corner.
    #' @param y1 Integer. Y coordinate of one corner.
    #' @param x2 Integer. X coordinate of the opposite corner.
    #' @param y2 Integer. Y coordinate of the opposite corner.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width in pixels. Ignored
    #'   when \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, draw a filled rectangle.
    #'   Default \code{FALSE}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_rectangle(10, 10, 100, 100, color = "blue", filled = TRUE)$plot()
    #' }
    draw_rectangle = function(x1, y1, x2, y2, color, thickness = 1L,
                              line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      Image$new(rt_draw_rectangle(private$.ptr,
                                  as.integer(x1), as.integer(y1),
                                  as.integer(x2), as.integer(y2),
                                  .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw a rectangle on the image in place.
    #' @param x1 Integer. X coordinate of one corner.
    #' @param y1 Integer. Y coordinate of one corner.
    #' @param x2 Integer. X coordinate of the opposite corner.
    #' @param y2 Integer. Y coordinate of the opposite corner.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width. Ignored when
    #'   \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, fill the rectangle. Default
    #'   \code{FALSE}.
    #' @return \code{self} invisibly.
    draw_rectangle_ = function(x1, y1, x2, y2, color, thickness = 1L,
                               line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      private$.ptr <- rt_draw_rectangle(private$.ptr,
                                        as.integer(x1), as.integer(y1),
                                        as.integer(x2), as.integer(y2),
                                        .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw a circle outline (or filled circle) on the image.
    #'   Returns a new Image.
    #' @param x Integer. X coordinate of the center.
    #' @param y Integer. Y coordinate of the center.
    #' @param radius Non-negative integer. Circle radius in pixels.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width. Ignored when
    #'   \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, draw a filled circle. Default
    #'   \code{FALSE}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_circle(100, 100, 50, color = "green", filled = TRUE)$plot()
    #' }
    draw_circle = function(x, y, radius, color, thickness = 1L,
                           line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      if (!is.numeric(radius) || length(radius) != 1L ||
          !is.finite(radius) || radius != round(radius) || radius < 0L)
        stop("radius must be a single non-negative integer", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      Image$new(rt_draw_circle(private$.ptr,
                               as.integer(x), as.integer(y),
                               as.integer(radius),
                               .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw a circle on the image in place.
    #' @param x Integer. X coordinate of the center.
    #' @param y Integer. Y coordinate of the center.
    #' @param radius Non-negative integer. Circle radius in pixels.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width. Ignored when
    #'   \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, fill the circle. Default
    #'   \code{FALSE}.
    #' @return \code{self} invisibly.
    draw_circle_ = function(x, y, radius, color, thickness = 1L,
                            line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      if (!is.numeric(radius) || length(radius) != 1L ||
          !is.finite(radius) || radius != round(radius) || radius < 0L)
        stop("radius must be a single non-negative integer", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      private$.ptr <- rt_draw_circle(private$.ptr,
                                     as.integer(x), as.integer(y),
                                     as.integer(radius),
                                     .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw an ellipse outline (or filled ellipse) on the image.
    #'   Returns a new Image.
    #' @param x Integer. X coordinate of the ellipse center.
    #' @param y Integer. Y coordinate of the ellipse center.
    #' @param rx Positive integer. Horizontal semi-axis length in pixels
    #'   (before rotation).
    #' @param ry Positive integer. Vertical semi-axis length in pixels
    #'   (before rotation).
    #' @param angle Numeric. Rotation of the ellipse in degrees (clockwise).
    #'   Default \code{0}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width. Ignored when
    #'   \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, draw a filled ellipse. Default
    #'   \code{FALSE}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_ellipse(100, 100, 80L, 40L, angle = 30, color = "red")$plot()
    #' }
    draw_ellipse = function(x, y, rx, ry, angle = 0, color, thickness = 1L,
                            line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      if (!is.numeric(rx) || length(rx) != 1L || !is.finite(rx) ||
          rx != round(rx) || rx < 1L ||
          !is.numeric(ry) || length(ry) != 1L || !is.finite(ry) ||
          ry != round(ry) || ry < 1L)
        stop("rx and ry must be single positive integers", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      Image$new(rt_draw_ellipse(private$.ptr,
                                as.integer(x), as.integer(y),
                                as.integer(rx), as.integer(ry),
                                as.double(angle),
                                .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw an ellipse on the image in place.
    #' @param x Integer. X coordinate of the ellipse center.
    #' @param y Integer. Y coordinate of the ellipse center.
    #' @param rx Positive integer. Horizontal semi-axis length in pixels.
    #' @param ry Positive integer. Vertical semi-axis length in pixels.
    #' @param angle Numeric. Rotation in degrees. Default \code{0}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Outline width. Ignored when
    #'   \code{filled = TRUE}. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @param filled Logical. If \code{TRUE}, fill the ellipse. Default
    #'   \code{FALSE}.
    #' @return \code{self} invisibly.
    draw_ellipse_ = function(x, y, rx, ry, angle = 0, color, thickness = 1L,
                             line_type = "line_8", filled = FALSE) {
      if (!is.logical(filled) || length(filled) != 1L)
        stop("filled must be a single logical value", call. = FALSE)
      if (!is.numeric(rx) || length(rx) != 1L || !is.finite(rx) ||
          rx != round(rx) || rx < 1L ||
          !is.numeric(ry) || length(ry) != 1L || !is.finite(ry) ||
          ry != round(ry) || ry < 1L)
        stop("rx and ry must be single positive integers", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type, filled = filled)
      private$.ptr <- rt_draw_ellipse(private$.ptr,
                                      as.integer(x), as.integer(y),
                                      as.integer(rx), as.integer(ry),
                                      as.double(angle),
                                      .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw a partial ellipse arc on the image. Returns a new
    #'   Image.
    #' @param x Integer. X coordinate of the ellipse center.
    #' @param y Integer. Y coordinate of the ellipse center.
    #' @param rx Positive integer. Horizontal semi-axis length in pixels.
    #' @param ry Positive integer. Vertical semi-axis length in pixels.
    #' @param angle Numeric. Rotation of the ellipse in degrees. Default
    #'   \code{0}.
    #' @param start_angle Numeric. Start angle of the arc in degrees.
    #' @param end_angle Numeric. End angle of the arc in degrees. If
    #'   \code{start_angle > end_angle}, OpenCV swaps them automatically.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default
    #'   \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_arc(100, 100, 80L, 40L, start_angle = 0, end_angle = 180,
    #'              color = "red")$plot()
    #' }
    draw_arc = function(x, y, rx, ry, angle = 0, start_angle, end_angle,
                        color, thickness = 1L, line_type = "line_8") {
      if (!is.numeric(rx) || length(rx) != 1L || !is.finite(rx) ||
          rx != round(rx) || rx < 1L ||
          !is.numeric(ry) || length(ry) != 1L || !is.finite(ry) ||
          ry != round(ry) || ry < 1L)
        stop("rx and ry must be single positive integers", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      Image$new(rt_draw_arc(private$.ptr,
                            as.integer(x), as.integer(y),
                            as.integer(rx), as.integer(ry),
                            as.double(angle),
                            as.double(start_angle), as.double(end_angle),
                            .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw a partial ellipse arc on the image in place.
    #' @param x Integer. X coordinate of the ellipse center.
    #' @param y Integer. Y coordinate of the ellipse center.
    #' @param rx Positive integer. Horizontal semi-axis length in pixels.
    #' @param ry Positive integer. Vertical semi-axis length in pixels.
    #' @param angle Numeric. Rotation in degrees. Default \code{0}.
    #' @param start_angle Numeric. Start angle of the arc in degrees.
    #' @param end_angle Numeric. End angle of the arc in degrees.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return \code{self} invisibly.
    draw_arc_ = function(x, y, rx, ry, angle = 0, start_angle, end_angle,
                         color, thickness = 1L, line_type = "line_8") {
      if (!is.numeric(rx) || length(rx) != 1L || !is.finite(rx) ||
          rx != round(rx) || rx < 1L ||
          !is.numeric(ry) || length(ry) != 1L || !is.finite(ry) ||
          ry != round(ry) || ry < 1L)
        stop("rx and ry must be single positive integers", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      private$.ptr <- rt_draw_arc(private$.ptr,
                                  as.integer(x), as.integer(y),
                                  as.integer(rx), as.integer(ry),
                                  as.double(angle),
                                  as.double(start_angle), as.double(end_angle),
                                  .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw a polyline (open or closed polygon outline) on the
    #'   image. Returns a new Image.
    #' @param pts A numeric matrix with exactly 2 columns (x, y) and at least
    #'   2 rows. Each row is a vertex.
    #' @param closed Logical. If \code{TRUE}, connect the last vertex back to
    #'   the first. Default \code{FALSE}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width in pixels. Default
    #'   \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
    #' img$draw_polyline(pts, closed = TRUE, color = "yellow")$plot()
    #' }
    draw_polyline = function(pts, closed = FALSE, color, thickness = 1L,
                             line_type = "line_8") {
      if (!is.matrix(pts) || !is.numeric(pts))
        stop("pts must be a numeric matrix", call. = FALSE)
      if (ncol(pts) != 2L)
        stop("pts must have exactly 2 columns (x, y)", call. = FALSE)
      if (nrow(pts) < 2L)
        stop("pts must have at least 2 rows", call. = FALSE)
      if (!is.logical(closed) || length(closed) != 1L)
        stop("closed must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      Image$new(rt_draw_polyline(private$.ptr,
                                 as.integer(pts[, 1L]),
                                 as.integer(pts[, 2L]),
                                 isTRUE(closed),
                                 .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw a polyline on the image in place.
    #' @param pts A numeric matrix with exactly 2 columns and at least 2 rows.
    #' @param closed Logical. If \code{TRUE}, close the polygon. Default
    #'   \code{FALSE}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Line width. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return \code{self} invisibly.
    draw_polyline_ = function(pts, closed = FALSE, color, thickness = 1L,
                              line_type = "line_8") {
      if (!is.matrix(pts) || !is.numeric(pts))
        stop("pts must be a numeric matrix", call. = FALSE)
      if (ncol(pts) != 2L)
        stop("pts must have exactly 2 columns (x, y)", call. = FALSE)
      if (nrow(pts) < 2L)
        stop("pts must have at least 2 rows", call. = FALSE)
      if (!is.logical(closed) || length(closed) != 1L)
        stop("closed must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      private$.ptr <- rt_draw_polyline(private$.ptr,
                                       as.integer(pts[, 1L]),
                                       as.integer(pts[, 2L]),
                                       isTRUE(closed),
                                       .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    #' @description Draw a filled polygon on the image. Returns a new Image.
    #' @param pts A numeric matrix with exactly 2 columns (x, y) and at least
    #'   3 rows. Each row is a vertex.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' pts <- matrix(c(10, 10, 100, 10, 55, 90), nrow = 3, ncol = 2, byrow = TRUE)
    #' img$fill_poly(pts, color = "cyan")$plot()
    #' }
    fill_poly = function(pts, color, line_type = "line_8") {
      if (!is.matrix(pts) || !is.numeric(pts))
        stop("pts must be a numeric matrix", call. = FALSE)
      if (ncol(pts) != 2L)
        stop("pts must have exactly 2 columns (x, y)", call. = FALSE)
      if (nrow(pts) < 3L)
        stop("pts must have at least 3 rows", call. = FALSE)
      if (!is.character(line_type) || length(line_type) != 1L ||
          !line_type %in% c("line_4", "line_8", "aa"))
        stop("line_type must be one of: line_4, line_8, aa", call. = FALSE)
      .color <- as.double(col2bgr(color)[1:3])
      Image$new(rt_fill_poly(private$.ptr,
                             as.integer(pts[, 1L]),
                             as.integer(pts[, 2L]),
                             .color, line_type))
    },

    #' @description Draw a filled polygon on the image in place.
    #' @param pts A numeric matrix with exactly 2 columns and at least 3 rows.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return \code{self} invisibly.
    fill_poly_ = function(pts, color, line_type = "line_8") {
      if (!is.matrix(pts) || !is.numeric(pts))
        stop("pts must be a numeric matrix", call. = FALSE)
      if (ncol(pts) != 2L)
        stop("pts must have exactly 2 columns (x, y)", call. = FALSE)
      if (nrow(pts) < 3L)
        stop("pts must have at least 3 rows", call. = FALSE)
      if (!is.character(line_type) || length(line_type) != 1L ||
          !line_type %in% c("line_4", "line_8", "aa"))
        stop("line_type must be one of: line_4, line_8, aa", call. = FALSE)
      .color <- as.double(col2bgr(color)[1:3])
      private$.ptr <- rt_fill_poly(private$.ptr,
                                   as.integer(pts[, 1L]),
                                   as.integer(pts[, 2L]),
                                   .color, line_type)
      invisible(self)
    },

    #' @description Draw text on the image. Returns a new Image.
    #' @param text Character. The string to draw.
    #' @param x Integer. X coordinate of the bottom-left corner of the text
    #'   bounding box.
    #' @param y Integer. Y coordinate of the bottom-left corner of the text
    #'   bounding box.
    #' @param font Character. One of \code{"simplex"} (default), \code{"plain"},
    #'   \code{"duplex"}, \code{"complex"}, \code{"triplex"},
    #'   \code{"complex_small"}, \code{"script_simplex"},
    #'   \code{"script_complex"}.
    #' @param font_size Numeric. Scale factor applied to the base font size.
    #'   Negative values mirror/reverse the text. Default \code{1}.
    #' @param italic Logical. If \code{TRUE}, use the italic variant of the
    #'   font. Default \code{FALSE}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Character stroke width. Default
    #'   \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$draw_text("Hello", 10, 50, font = "duplex", font_size = 1.5,
    #'               color = "white")$plot()
    #' }
    draw_text = function(text, x, y, font = "simplex", font_size = 1,
                         italic = FALSE, color, thickness = 1L,
                         line_type = "line_8") {
      .valid_fonts <- c("simplex", "plain", "duplex", "complex", "triplex",
                        "complex_small", "script_simplex", "script_complex")
      if (!is.character(text) || length(text) != 1L)
        stop("text must be a single character string", call. = FALSE)
      if (!is.character(font) || length(font) != 1L || !font %in% .valid_fonts)
        stop(paste("font must be one of:", paste(.valid_fonts, collapse = ", ")),
             call. = FALSE)
      if (!is.numeric(font_size) || length(font_size) != 1L)
        stop("font_size must be a single numeric value", call. = FALSE)
      if (!is.logical(italic) || length(italic) != 1L)
        stop("italic must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      Image$new(rt_draw_text(private$.ptr,
                             as.character(text),
                             as.integer(x), as.integer(y),
                             font, as.double(font_size), isTRUE(italic),
                             .a$color, .a$thickness, .a$line_type))
    },

    #' @description Draw text on the image in place.
    #' @param text Character. The string to draw.
    #' @param x Integer. X coordinate of the bottom-left corner of the text.
    #' @param y Integer. Y coordinate of the bottom-left corner of the text.
    #' @param font Character. Font face name. Default \code{"simplex"}.
    #' @param font_size Numeric. Scale factor. Negative mirrors the text.
    #'   Default \code{1}.
    #' @param italic Logical. Italic variant. Default \code{FALSE}.
    #' @param color An R color name, hex string, or numeric BGR(A) vector.
    #' @param thickness Positive integer. Stroke width. Default \code{1L}.
    #' @param line_type Character. One of \code{"line_4"}, \code{"line_8"}
    #'   (default), \code{"aa"}.
    #' @return \code{self} invisibly.
    draw_text_ = function(text, x, y, font = "simplex", font_size = 1,
                          italic = FALSE, color, thickness = 1L,
                          line_type = "line_8") {
      .valid_fonts <- c("simplex", "plain", "duplex", "complex", "triplex",
                        "complex_small", "script_simplex", "script_complex")
      if (!is.character(text) || length(text) != 1L)
        stop("text must be a single character string", call. = FALSE)
      if (!is.character(font) || length(font) != 1L || !font %in% .valid_fonts)
        stop(paste("font must be one of:", paste(.valid_fonts, collapse = ", ")),
             call. = FALSE)
      if (!is.numeric(font_size) || length(font_size) != 1L)
        stop("font_size must be a single numeric value", call. = FALSE)
      if (!is.logical(italic) || length(italic) != 1L)
        stop("italic must be a single logical value", call. = FALSE)
      .a <- .rt_valid_draw_common(color, thickness, line_type)
      private$.ptr <- rt_draw_text(private$.ptr,
                                   as.character(text),
                                   as.integer(x), as.integer(y),
                                   font, as.double(font_size), isTRUE(italic),
                                   .a$color, .a$thickness, .a$line_type)
      invisible(self)
    },

    # ── Histogram ─────────────────────────────────────────────────────────────

    #' @description Compute a per-channel histogram of pixel values.
    #' @param bins Single positive integer. Number of histogram bins. Default
    #'   \code{256}.
    #' @param range Length-2 numeric vector \code{c(lo, hi)} giving the
    #'   pixel-value range to histogram. \code{NULL} (default) applies a
    #'   depth-appropriate default and emits a message.
    #' @param freq Logical. \code{TRUE} (default): \code{count} column contains
    #'   raw pixel counts (consistent with base R \code{hist(freq = TRUE)}).
    #'   \code{FALSE}: \code{count} column contains probability densities
    #'   (counts / (total_pixels * bin_width)).
    #' @return A tidy data frame with columns \code{bin_center} (double),
    #'   \code{channel} (character), and \code{count} (double). One row per
    #'   bin per channel, ordered by channel then ascending \code{bin_center}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)$to_gray()
    #' h <- img$hist(bins = 256L, range = c(0, 256))
    #' # plot with ggplot2:
    #' # ggplot2::ggplot(h, ggplot2::aes(x = bin_center, y = count)) +
    #' #   ggplot2::geom_col()
    #' }
    hist = function(bins = 256L, range = NULL, freq = TRUE) {
      .depth_ranges <- list(
        CV_8U  = c(0, 256),
        CV_16U = c(0, 65536),
        CV_16S = c(-32768, 32768),
        CV_32F = c(0, 1),
        CV_64F = c(0, 1)
      )
      bins <- as.integer(bins)
      if (!is.integer(bins) || length(bins) != 1L || is.na(bins) || bins < 1L)
        stop("bins must be a single positive integer", call. = FALSE)
      if (is.null(range)) {
        r <- .depth_ranges[[self$depth_name]]
        if (is.null(r))
          stop("No default range for depth '", self$depth_name,
               "' — provide range explicitly.", call. = FALSE)
        range <- r
        message("range not specified; using [", range[1], ", ", range[2],
                "] for ", self$depth_name, " image.")
      }
      if (!is.numeric(range) || length(range) != 2L ||
          !all(is.finite(range)) || range[1] >= range[2])
        stop("range must be a length-2 finite numeric vector with range[1] < range[2]",
             call. = FALSE)
      if (!is.logical(freq) || length(freq) != 1L || is.na(freq))
        stop("freq must be a single logical value", call. = FALSE)

      ch_names    <- rt_channel_names(self$colorspace, self$nchan)
      counts_list <- rt_hist(private$.ptr, bins,
                             as.double(range[1]), as.double(range[2]))
      bin_width   <- (range[2] - range[1]) / bins
      bin_centers <- range[1] + (seq_len(bins) - 0.5) * bin_width
      total_px    <- self$nrow * self$ncol

      dfs <- lapply(seq_along(ch_names), \(i) {
        counts <- counts_list[[i]]
        if (!freq) counts <- counts / (total_px * bin_width)
        data.frame(bin_center = bin_centers, channel = ch_names[i],
                   count = counts, stringsAsFactors = FALSE)
      })
      do.call(rbind, dfs)
    },

    #' @description Print a summary of the image.
    #' @param ... Ignored.
    #' @return \code{self} invisibly.
    print = function(...) {
      cat("<Image>\n")
      cat("  Size      :", self$ncol, "x", self$nrow, "\n")
      cat("  Channels  :", self$nchan, "\n")
      cat("  Depth     :", self$depth_name, "\n")
      cat("  Colorspace:", self$colorspace, "\n")
      cat("  GPU       :", self$gpu, "\n")
      invisible(self)
    }
  )
)

# ── S3 indexing operators ──────────────────────────────────────────────────────

#' @export
`[.Image` <- function(x, i, j, k, drop = TRUE) {
  # drop is accepted for S3 generic compatibility but not used.
  .nrow  <- x$nrow
  .ncol  <- x$ncol
  .nchan <- x$nchan
  .ptr   <- .rt_ptr(x)

  .i_missing <- missing(i)
  .j_missing <- missing(j)
  .k_missing <- missing(k)

  if (.i_missing && .j_missing)
    stop("at least one index must be provided", call. = FALSE)

  if (.i_missing) i <- seq_len(.nrow)
  if (.j_missing) j <- seq_len(.ncol)

  if (anyNA(i)) stop("row index must not contain NA", call. = FALSE)
  if (anyNA(j)) stop("column index must not contain NA", call. = FALSE)

  i <- as.integer(i)
  j <- as.integer(j)

  if (length(i) < 1L) stop("row index must not be empty", call. = FALSE)
  if (length(j) < 1L) stop("column index must not be empty", call. = FALSE)

  if (any(i < 1L) || any(i > .nrow))
    stop("row index out of bounds", call. = FALSE)
  if (length(i) > 1L && !all(diff(i) == 1L))
    stop("index must be a contiguous integer sequence", call. = FALSE)

  if (any(j < 1L) || any(j > .ncol))
    stop("column index out of bounds", call. = FALSE)
  if (length(j) > 1L && !all(diff(j) == 1L))
    stop("index must be a contiguous integer sequence", call. = FALSE)

  if (length(i) == 1L && length(j) == 1L) {
    vals <- setNames(
      as.numeric(rt_image_get_pixel(.ptr, i, j)),
      rt_channel_names(x$colorspace, .nchan)
    )
    if (!.k_missing) {
      if (is.na(k)) stop("channel index must not be NA", call. = FALSE)
      k <- as.integer(k)
      if (length(k) != 1L || k < 1L || k > .nchan)
        stop("channel index out of bounds", call. = FALSE)
      return(vals[[k]])
    }
    return(vals)
  }

  if (!.k_missing)
    stop("channel index k is not supported for range extraction", call. = FALSE)

  Image$new(rt_image_extract_region(.ptr, i[1L], j[1L], i[length(i)], j[length(j)]))
}

#' @export
`[<-.Image` <- function(x, i, j, k, value) {
  .nrow  <- x$nrow
  .ncol  <- x$ncol
  .nchan <- x$nchan
  .depth <- x$depth
  .ptr   <- .rt_ptr(x)

  .k_missing <- missing(k)

  if (missing(i) || missing(j))
    stop("both row and column indices must be provided for assignment", call. = FALSE)

  if (anyNA(i)) stop("row index must not contain NA", call. = FALSE)
  if (anyNA(j)) stop("column index must not contain NA", call. = FALSE)

  i <- as.integer(i)
  j <- as.integer(j)

  if (length(i) < 1L) stop("row index must not be empty", call. = FALSE)
  if (length(j) < 1L) stop("column index must not be empty", call. = FALSE)

  if (any(i < 1L) || any(i > .nrow))
    stop("row index out of bounds", call. = FALSE)
  if (length(i) > 1L && !all(diff(i) == 1L))
    stop("index must be a contiguous integer sequence", call. = FALSE)

  if (any(j < 1L) || any(j > .ncol))
    stop("column index out of bounds", call. = FALSE)
  if (length(j) > 1L && !all(diff(j) == 1L))
    stop("index must be a contiguous integer sequence", call. = FALSE)

  if (length(i) == 1L && length(j) == 1L) {
    if (!.k_missing) {
      if (is.na(k)) stop("channel index must not be NA", call. = FALSE)
      k <- as.integer(k)
      if (length(k) != 1L || k < 1L || k > .nchan)
        stop("channel index out of bounds", call. = FALSE)
      if (!is.numeric(value) || length(value) != 1L)
        stop("value must be a single numeric", call. = FALSE)
      vals <- as.numeric(rt_image_get_pixel(.ptr, i, j))
      vals[k] <- as.double(value)
      rt_image_set_pixel(.ptr, i, j, vals)
    } else {
      if (!is.numeric(value) || length(value) != .nchan)
        stop(sprintf("value must be a numeric vector of length %d (matching nchan)", .nchan),
             call. = FALSE)
      rt_image_set_pixel(.ptr, i, j, as.double(value))
    }
  } else {
    if (!.k_missing)
      stop("channel index k is not supported for range assignment", call. = FALSE)
    # Assignment always requires explicit row and column indices.
    # Unlike [.Image, no defaulting to full row/column is provided.
    if (!inherits(value, "Image"))
      stop("value must be an Image for range assignment", call. = FALSE)
    if (value$nrow != length(i) || value$ncol != length(j))
      stop("value dimensions do not match the index range", call. = FALSE)
    if (value$nchan != .nchan)
      stop("value has a different number of channels", call. = FALSE)
    if (value$depth != .depth)
      stop("value has a different depth", call. = FALSE)
    rt_image_copy_roi(.ptr, .rt_ptr(value), i[1L], j[1L])
  }

  x
}

# ── Image class-level constructors ────────────────────────────────────────────
# These are attached to the Image class generator so they are called as
# Image$zeros(), Image$ones(), etc. — analogous to Image$new().

.rt_valid_depths <- c("CV_8U", "CV_16U", "CV_16S", "CV_32F", "CV_64F")

.rt_check_construct_args <- function(nrow, ncol, nchan, depth, colorspace) {
  if (length(nrow) != 1L || !isTRUE(nrow >= 1L) || !isTRUE(nrow == as.integer(nrow)))
    stop("nrow must be a single positive integer", call. = FALSE)
  if (length(ncol) != 1L || !isTRUE(ncol >= 1L) || !isTRUE(ncol == as.integer(ncol)))
    stop("ncol must be a single positive integer", call. = FALSE)
  if (length(nchan) != 1L || !isTRUE(nchan >= 1L) || !isTRUE(nchan <= 4L) ||
      !isTRUE(nchan == as.integer(nchan)))
    stop("nchan must be a single positive integer <= 4", call. = FALSE)
  if (length(depth) != 1L || !depth %in% .rt_valid_depths)
    stop("depth must be one of: ", paste(.rt_valid_depths, collapse = ", "), call. = FALSE)
  if (length(colorspace) != 1L || !is.character(colorspace) || is.na(colorspace))
    stop("colorspace must be a single character string", call. = FALSE)
}

# General fill constructor — all other constructors delegate to this one.
# value: numeric scalar (recycled) or vector of length nchan. No NAs.
Image$fill <- function(value, nrow, ncol, nchan = 1L, depth = "CV_8U",
                       colorspace = "GRAY") {
  .rt_check_construct_args(nrow, ncol, nchan, depth, colorspace)
  if (!is.numeric(value) || length(value) < 1L || length(value) > 4L ||
      anyNA(value) || !all(is.finite(value)))
    stop("value must be a non-empty finite numeric vector (length 1-4) with no NAs",
         call. = FALSE)
  if (length(value) > 1L && length(value) != nchan)
    stop("value length (", length(value), ") must equal nchan (", nchan, ") or be 1",
         call. = FALSE)
  value_recycled <- rep_len(as.double(value), as.integer(nchan))
  Image$new(rt_fill(as.integer(nrow), as.integer(ncol),
                    as.integer(nchan), depth, colorspace,
                    value_recycled))
}

# Create a zero-filled image. Delegates to Image$fill(0, ...).
Image$zeros <- function(nrow, ncol, nchan = 1L, depth = "CV_8U",
                        colorspace = "GRAY") {
  Image$fill(0, nrow, ncol, nchan, depth, colorspace)
}

# Create an image filled with ones (value = 1, not depth maximum).
# Delegates to Image$fill(1, ...).
Image$ones <- function(nrow, ncol, nchan = 1L, depth = "CV_8U",
                       colorspace = "GRAY") {
  Image$fill(1, nrow, ncol, nchan, depth, colorspace)
}

# Create an image with uniform random values drawn from Uniform(low, high).
# Depth-aware defaults are applied when low or high is missing; a message is
# emitted. Suppress with suppressMessages().
Image$randu <- function(nrow, ncol, nchan = 1L, depth = "CV_8U",
                        colorspace = "GRAY", low, high) {
  .rt_check_construct_args(nrow, ncol, nchan, depth, colorspace)
  if (missing(low) || missing(high)) {
    .defaults <- list(
      CV_8U  = c(0,      255),
      CV_16U = c(0,    65535),
      CV_16S = c(-32768, 32767),
      CV_32F = c(0,        1),
      CV_64F = c(0,        1)
    )
    d <- .defaults[[depth]]
    if (is.null(d)) stop("No default range for depth '", depth, "' — please provide 'low' and 'high' explicitly.", call. = FALSE)
    if (missing(low))  low  <- d[1]
    if (missing(high)) high <- d[2]
    message("Using default range [", low, ", ", high, "] for ", depth,
            ". Provide both 'low' and 'high' explicitly to suppress this message.")
  }
  if (length(low)  != 1L || !is.numeric(low)  || !is.finite(low))
    stop("low must be a single finite numeric",  call. = FALSE)
  if (length(high) != 1L || !is.numeric(high) || !is.finite(high))
    stop("high must be a single finite numeric", call. = FALSE)
  if (low >= high) stop("low must be strictly less than high", call. = FALSE)
  Image$new(rt_randu(as.integer(nrow), as.integer(ncol),
                     as.integer(nchan), depth, colorspace,
                     as.double(low), as.double(high)))
}

# Create an image with Gaussian random values drawn from Normal(mean, sd).
# Integer-depth images saturate out-of-range values. Depth-aware defaults
# applied when mean or sd is missing; a message is emitted.
Image$randn <- function(nrow, ncol, nchan = 1L, depth = "CV_8U",
                        colorspace = "GRAY", mean, sd) {
  .rt_check_construct_args(nrow, ncol, nchan, depth, colorspace)
  if (missing(mean) || missing(sd)) {
    .defaults <- list(
      CV_8U  = c(128,   30),
      CV_16U = c(32767, 10000),
      CV_16S = c(0,     10000),
      CV_32F = c(0.5,   0.167),
      CV_64F = c(0.5,   0.167)
    )
    d <- .defaults[[depth]]
    if (is.null(d)) stop("No default mean/sd for depth '", depth, "' — please provide 'mean' and 'sd' explicitly.", call. = FALSE)
    if (missing(mean)) mean <- d[1]
    if (missing(sd))   sd   <- d[2]
    message("Using default mean/sd [", mean, ", ", sd, "] for ", depth,
            ". Provide both 'mean' and 'sd' explicitly to suppress this message.")
  }
  if (length(mean) != 1L || !is.numeric(mean) || !is.finite(mean))
    stop("mean must be a single finite numeric", call. = FALSE)
  if (length(sd) != 1L || !is.numeric(sd) || !is.finite(sd) || sd <= 0)
    stop("sd must be a single positive finite numeric", call. = FALSE)
  Image$new(rt_randn(as.integer(nrow), as.integer(ncol),
                     as.integer(nchan), depth, colorspace,
                     as.double(mean), as.double(sd)))
}
