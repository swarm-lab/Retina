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
    initialize = function(x, colorspace = "BGR") {
      if (is.character(x)) {
        private$.ptr <- rt_image_read(path.expand(x))
      } else if (is.array(x) || is.matrix(x)) {
        if (!is.integer(x))
          storage.mode(x) <- "integer"
        private$.ptr <- rt_image_from_array(x, colorspace)
      } else if (inherits(x, "externalptr")) {
        private$.ptr <- x
      } else {
        stop("x must be a file path (character), an array/matrix, or an external pointer.",
             call. = FALSE)
      }
    },

    #' @description Convert the image to a 3D integer array (nrow x ncol x nchan).
    #'   Values are in [0, 255] for 8-bit images.
    #' @return An integer array with dimensions \code{[nrow, ncol, nchan]}.
    to_array = function() {
      rt_image_to_array(private$.ptr)
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
