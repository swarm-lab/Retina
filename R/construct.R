# Standalone image construction functions (non-class-level).
# Class-level constructors (fill, zeros, ones, randu, randn) live in R/Image.R
# as Image$fill(), Image$zeros(), etc.

#' Concatenate images side-by-side or top-to-bottom
#'
#' Combines a list of images using \code{cv::hconcat} or \code{cv::vconcat}.
#' All images must share the same \code{depth}, \code{colorspace}, and
#' \code{nchan}. For horizontal concatenation all must have the same
#' \code{nrow}; for vertical, the same \code{ncol}.
#'
#' @param imgs A list of at least 2 \code{Image} objects.
#' @param axis \code{"h"} or \code{"horizontal"} for side-by-side;
#'   \code{"v"} or \code{"vertical"} for top-to-bottom. Default \code{"h"}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' a <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
#' b <- Image$fill(128, 3L, 3L, 1L, "CV_8U", "GRAY")
#' concatenate(list(a, b), "h")$plot()
#' }
#' @export
concatenate <- function(imgs, axis = "h") {
  if (!is.list(imgs) || length(imgs) < 2L ||
      !all(vapply(imgs, inherits, logical(1L), "Image")))
    stop("imgs must be a list of at least 2 Image objects", call. = FALSE)

  valid_axes <- c("h", "horizontal", "v", "vertical")
  if (length(axis) != 1L || !is.character(axis) || !axis %in% valid_axes)
    stop("axis must be one of: h, horizontal, v, vertical", call. = FALSE)

  depths      <- vapply(imgs, function(x) x$depth,      integer(1L))
  nchans      <- vapply(imgs, function(x) x$nchan,      integer(1L))
  colorspaces <- vapply(imgs, function(x) x$colorspace, character(1L))

  if (length(unique(depths)) > 1L)
    stop("all images must have the same depth", call. = FALSE)
  if (length(unique(nchans)) > 1L)
    stop("all images must have the same nchan", call. = FALSE)
  if (length(unique(colorspaces)) > 1L)
    stop("all images must have the same colorspace", call. = FALSE)

  if (axis %in% c("h", "horizontal")) {
    nrows <- vapply(imgs, function(x) x$nrow, integer(1L))
    if (length(unique(nrows)) > 1L)
      stop("for horizontal concatenation all images must have the same nrow",
           call. = FALSE)
  } else {
    ncols <- vapply(imgs, function(x) x$ncol, integer(1L))
    if (length(unique(ncols)) > 1L)
      stop("for vertical concatenation all images must have the same ncol",
           call. = FALSE)
  }

  Image$new(rt_concatenate(lapply(imgs, .rt_ptr), axis))
}
