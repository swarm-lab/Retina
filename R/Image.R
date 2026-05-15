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
    #' @param x A file path (character), a 3D integer array (nrow x ncol x nchan),
    #'   or a 2D integer matrix. For arrays, values must be in [0, 255].
    #' @param colorspace Color space label string. Ignored when reading from file
    #'   (OpenCV assumes BGR for color images).
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
    #' @param ... Additional arguments passed to \code{grid::grid.raster()}.
    #' @return \code{self} invisibly.
    plot = function(...) {
      nr <- rt_image_to_native_raster(private$.ptr)
      grid::grid.newpage()
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
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_and_image, rt_image_bitwise_and_scalar))
    },

    #' @description Bitwise AND in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_and_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_and_image, rt_image_bitwise_and_scalar)
      invisible(self)
    },

    #' @description Bitwise OR with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    bitwise_or = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_or_image, rt_image_bitwise_or_scalar))
    },

    #' @description Bitwise OR in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_or_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_or_image, rt_image_bitwise_or_scalar)
      invisible(self)
    },

    #' @description Bitwise XOR with another image or a scalar.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return A new \code{Image}.
    bitwise_xor = function(other) {
      Image$new(.rt_arith(private$.ptr, other, self$nchan, self$depth,
                          rt_image_bitwise_xor_image, rt_image_bitwise_xor_scalar))
    },

    #' @description Bitwise XOR in place.
    #' @param other An \code{Image} or a numeric vector (length 1 or \code{nchan}).
    #' @return \code{self} invisibly.
    bitwise_xor_ = function(other) {
      private$.ptr <- .rt_arith(private$.ptr, other, self$nchan, self$depth,
                                rt_image_bitwise_xor_image, rt_image_bitwise_xor_scalar)
      invisible(self)
    },

    #' @description Bitwise NOT (invert all bits).
    #' @return A new \code{Image}.
    bitwise_not = function() Image$new(rt_image_bitwise_not(private$.ptr)),

    #' @description Bitwise NOT in place.
    #' @return \code{self} invisibly.
    bitwise_not_ = function() {
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
