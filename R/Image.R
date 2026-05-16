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

    #' @description Display the image using R's graphics device.
    #' @param newpage Logical. If \code{TRUE} (default), clears the graphics
    #'   device before drawing. Set to \code{FALSE} when composing multiple
    #'   images in a layout using \code{grid} viewports.
    #' @param ... Additional arguments passed to \code{grid::grid.raster()}.
    #' @return \code{self} invisibly.
    plot = function(newpage = TRUE, ...) {
      nr <- rt_image_to_native_raster(private$.ptr)
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
    #'   or \code{"CV_64F"}. Default \code{"CV_32F"}.
    #' @param scale Single positive numeric. Optional scale factor for the
    #'   computed derivatives. Must be positive (use \code{convert_depth} +
    #'   arithmetic to invert gradient sign). Default 1.
    #' @param delta Single numeric. Optional delta added to results before
    #'   storing. Default 0.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' grad_x <- img$sobel(1, 0)
    #' grad_x$plot()
    #' }
    sobel = function(dx, dy, ksize = 3, ddepth = "CV_32F",
                     scale = 1, delta = 0, border_type = "default") {
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!is.numeric(dx) || !is.numeric(dy) ||
          length(dx) != 1L || length(dy) != 1L ||
          dx < 0 || dy < 0 || (dx + dy) < 1)
        stop("dx and dy must be non-negative integers with dx + dy >= 1",
             call. = FALSE)
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F"))
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
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
    #'   or \code{"CV_64F"}. Default \code{"CV_32F"}.
    #' @param scale Single positive numeric. Optional scale factor for the
    #'   computed derivatives. Must be positive (use \code{convert_depth} +
    #'   arithmetic to invert gradient sign). Default 1.
    #' @param delta Single numeric. Delta added to results. Default 0.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "brick_wall.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$sobel_(1, 0)
    #' img$plot()
    #' }
    sobel_ = function(dx, dy, ksize = 3, ddepth = "CV_32F",
                      scale = 1, delta = 0, border_type = "default") {
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!is.numeric(dx) || !is.numeric(dy) ||
          length(dx) != 1L || length(dy) != 1L ||
          dx < 0 || dy < 0 || (dx + dy) < 1)
        stop("dx and dy must be non-negative integers with dx + dy >= 1",
             call. = FALSE)
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F"))
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
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
    #'   or \code{"CV_64F"}. Default \code{"CV_32F"}.
    #' @param scale Single positive numeric. Optional scale factor. Must be
    #'   positive. Default 1.
    #' @param delta Single numeric. Optional delta added to results. Default 0.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' edges <- img$laplacian()
    #' edges$plot()
    #' }
    laplacian = function(ksize = 1, ddepth = "CV_32F",
                         scale = 1, delta = 0, border_type = "default") {
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F"))
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      Image$new(rt_image_laplacian(private$.ptr, as.integer(ksize), ddepth,
                                   as.double(scale), as.double(delta),
                                   border_type))
    },

    #' @description Laplacian operator in place.
    #' @param ksize Integer. Aperture size: 1, 3, 5, or 7. Default 1.
    #' @param ddepth Character. Output depth: \code{"CV_16S"}, \code{"CV_32F"},
    #'   or \code{"CV_64F"}. Default \code{"CV_32F"}.
    #' @param scale Single positive numeric. Optional scale factor. Must be
    #'   positive. Default 1.
    #' @param delta Single numeric. Delta added to results. Default 0.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$laplacian_()
    #' img$plot()
    #' }
    laplacian_ = function(ksize = 1, ddepth = "CV_32F",
                          scale = 1, delta = 0, border_type = "default") {
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!ksize %in% c(1L, 3L, 5L, 7L))
        stop("ksize must be 1, 3, 5, or 7", call. = FALSE)
      if (!ddepth %in% c("CV_16S", "CV_32F", "CV_64F"))
        stop("ddepth must be one of: CV_16S, CV_32F, CV_64F", call. = FALSE)
      if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
        stop("scale must be a single positive numeric value", call. = FALSE)
      if (!is.numeric(delta) || length(delta) != 1L)
        stop("delta must be a single numeric value", call. = FALSE)
      if (!border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
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

    #' @description Apply a morphological operation. Returns a new Image.
    #' @param operation Character. One of \code{"erode"}, \code{"dilate"},
    #'   \code{"open"}, \code{"close"}, \code{"gradient"}, \code{"tophat"},
    #'   \code{"blackhat"}.
    #' @param shape Character. Structuring element shape: \code{"rect"},
    #'   \code{"cross"}, or \code{"ellipse"}. Ignored when \code{kernel} is
    #'   supplied. Default \code{"rect"}.
    #' @param size Positive odd integer. Side length of the structuring element.
    #'   Ignored when \code{kernel} is supplied. Default \code{3L}.
    #' @param kernel Optional numeric matrix used as the structuring element.
    #'   Values are coerced to integers. Overrides
    #'   \code{shape} and \code{size} when supplied.
    #' @param iterations Positive integer. Number of times the operation is
    #'   applied. Default \code{1L}.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
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
                     border_type = "default") {
      .valid_ops    <- c("erode", "dilate", "open", "close",
                         "gradient", "tophat", "blackhat")
      .valid_shapes <- c("rect", "cross", "ellipse")
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!is.character(operation) || length(operation) != 1L ||
          !operation %in% .valid_ops)
        stop("operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat",
             call. = FALSE)
      if (!is.character(shape) || length(shape) != 1L || !shape %in% .valid_shapes)
        stop("shape must be one of: rect, cross, ellipse", call. = FALSE)
      size <- as.integer(size)
      if (length(size) != 1L || is.na(size) || size < 1L || size %% 2L == 0L)
        stop("size must be a single positive odd integer", call. = FALSE)
      if (!is.null(kernel) && !is.matrix(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      iterations <- as.integer(iterations)
      if (length(iterations) != 1L || is.na(iterations) || iterations < 1L)
        stop("iterations must be a single positive integer", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #' @param operation Character. One of \code{"erode"}, \code{"dilate"},
    #'   \code{"open"}, \code{"close"}, \code{"gradient"}, \code{"tophat"},
    #'   \code{"blackhat"}.
    #' @param shape Character. Structuring element shape: \code{"rect"},
    #'   \code{"cross"}, or \code{"ellipse"}. Ignored when \code{kernel} is
    #'   supplied. Default \code{"rect"}.
    #' @param size Positive odd integer. Side length of the structuring element.
    #'   Ignored when \code{kernel} is supplied. Default \code{3L}.
    #' @param kernel Optional numeric matrix used as the structuring element.
    #'   Values are coerced to integers. Overrides
    #'   \code{shape} and \code{size} when supplied.
    #' @param iterations Positive integer. Number of times the operation is
    #'   applied. Default \code{1L}.
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
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
                      border_type = "default") {
      .valid_ops    <- c("erode", "dilate", "open", "close",
                         "gradient", "tophat", "blackhat")
      .valid_shapes <- c("rect", "cross", "ellipse")
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
      if (!is.character(operation) || length(operation) != 1L ||
          !operation %in% .valid_ops)
        stop("operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat",
             call. = FALSE)
      if (!is.character(shape) || length(shape) != 1L || !shape %in% .valid_shapes)
        stop("shape must be one of: rect, cross, ellipse", call. = FALSE)
      size <- as.integer(size)
      if (length(size) != 1L || is.na(size) || size < 1L || size %% 2L == 0L)
        stop("size must be a single positive odd integer", call. = FALSE)
      if (!is.null(kernel) && !is.matrix(kernel))
        stop("kernel must be a numeric matrix", call. = FALSE)
      iterations <- as.integer(iterations)
      if (length(iterations) != 1L || is.na(iterations) || iterations < 1L)
        stop("iterations must be a single positive integer", call. = FALSE)
      if (!is.character(border_type) || length(border_type) != 1L ||
          !border_type %in% .valid_border)
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$rotate(45)$plot()
    #' }
    rotate = function(angle, cx = NULL, cy = NULL, scale = 1,
                      interpolation = "linear", border_type = "default") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$rotate_(45)
    #' img$plot()
    #' }
    rotate_ = function(angle, cx = NULL, cy = NULL, scale = 1,
                       interpolation = "linear", border_type = "default") {
      .valid_interp <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border <- c("default", "reflect", "reflect_101",
                         "replicate", "constant", "wrap")
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
    #' @return A new \code{Image}.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' m <- affine_translate(50, 30)
    #' img$warp_affine(m)$plot()
    #' }
    warp_affine = function(m, width = NULL, height = NULL,
                           interpolation = "linear", border_type = "default") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("default", "reflect", "reflect_101",
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
    #' @return \code{self} invisibly.
    #' @examples
    #' \donttest{
    #' img_path <- system.file("img", "flower.jpg", package = "Retina")
    #' img <- Image$new(img_path)
    #' img$warp_affine_(affine_translate(50, 30))
    #' img$plot()
    #' }
    warp_affine_ = function(m, width = NULL, height = NULL,
                            interpolation = "linear", border_type = "default") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("default", "reflect", "reflect_101",
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
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
                                interpolation = "linear", border_type = "default") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("default", "reflect", "reflect_101",
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
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
    #' @param border_type Character. Pixel extrapolation method. One of
    #'   \code{"default"}, \code{"reflect"}, \code{"reflect_101"},
    #'   \code{"replicate"}, \code{"constant"}, \code{"wrap"}.
    #'   Default \code{"default"}.
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
                                 interpolation = "linear", border_type = "default") {
      .valid_interp  <- c("nearest", "linear", "cubic", "area", "lanczos4")
      .valid_border  <- c("default", "reflect", "reflect_101",
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
        stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap",
             call. = FALSE)
      .w <- if (is.null(width))  self$ncol else as.integer(width)
      .h <- if (is.null(height)) self$nrow else as.integer(height)
      private$.ptr <- rt_image_warp_perspective(private$.ptr, as.double(m),
                                                .w, .h, interpolation, border_type)
      invisible(self)
    },

    #' @description Add a border around the image.
    #' @param top Integer. Border width in pixels on the top edge.
    #' @param bottom Integer. Border width on the bottom edge. Defaults to `top`.
    #' @param left Integer. Border width on the left edge. Defaults to `top`.
    #' @param right Integer. Border width on the right edge. Defaults to `left`.
    #' @param type Character. Border fill mode. One of `"constant"`,
    #'   `"default"`, `"reflect"`, `"reflect_101"`, `"replicate"`, `"wrap"`.
    #'   Default `"constant"`.
    #' @param value Numeric vector of length 1 or `nchan`. Fill colour used when
    #'   `type = "constant"`. Recycled to `nchan` values. Default 0 (black).
    #' @return A new `Image`.
    border = function(top, bottom = top, left = top, right = left,
                      type = "constant", value = 0) {
      for (nm in c("top", "bottom", "left", "right")) {
        v <- get(nm)
        if (length(v) != 1L || !isTRUE(v >= 0L) || !isTRUE(v == as.integer(v)))
          stop(nm, " must be a single non-negative integer", call. = FALSE)
      }
      valid_types <- c("constant", "default", "reflect", "reflect_101", "replicate", "wrap")
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
    #' @param top Integer. Border width on the top edge.
    #' @param bottom Integer. Defaults to `top`.
    #' @param left Integer. Defaults to `top`.
    #' @param right Integer. Defaults to `left`.
    #' @param type Character. Border fill mode. One of `"constant"`,
    #'   `"default"`, `"reflect"`, `"reflect_101"`, `"replicate"`, `"wrap"`.
    #'   Default `"constant"`.
    #' @param value Numeric vector of length 1 or `nchan`. Fill colour used when
    #'   `type = "constant"`. Recycled to `nchan` values. Default 0 (black).
    #' @return `self` invisibly.
    border_ = function(top, bottom = top, left = top, right = left,
                       type = "constant", value = 0) {
      for (nm in c("top", "bottom", "left", "right")) {
        v <- get(nm)
        if (length(v) != 1L || !isTRUE(v >= 0L) || !isTRUE(v == as.integer(v)))
          stop(nm, " must be a single non-negative integer", call. = FALSE)
      }
      valid_types <- c("constant", "default", "reflect", "reflect_101", "replicate", "wrap")
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
