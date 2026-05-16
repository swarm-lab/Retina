.valid_depths <- c("CV_8U", "CV_8S", "CV_16U", "CV_16S", "CV_32S", "CV_32F", "CV_64F")

.check_construct_args <- function(nrow, ncol, nchan, depth, colorspace) {
  if (length(nrow) != 1L || !isTRUE(nrow >= 1L) || !isTRUE(nrow == as.integer(nrow)))
    stop("nrow must be a single positive integer", call. = FALSE)
  if (length(ncol) != 1L || !isTRUE(ncol >= 1L) || !isTRUE(ncol == as.integer(ncol)))
    stop("ncol must be a single positive integer", call. = FALSE)
  if (length(nchan) != 1L || !isTRUE(nchan >= 1L) || !isTRUE(nchan <= 4L) ||
      !isTRUE(nchan == as.integer(nchan)))
    stop("nchan must be a single positive integer <= 4", call. = FALSE)
  if (length(depth) != 1L || !depth %in% .valid_depths)
    stop("depth must be one of: ", paste(.valid_depths, collapse = ", "), call. = FALSE)
  if (length(colorspace) != 1L || !is.character(colorspace))
    stop("colorspace must be a single character string", call. = FALSE)
}

#' Create a zero-filled image
#'
#' @param nrow,ncol Integer. Image dimensions in pixels.
#' @param nchan Integer. Number of channels (1-4). Default 1.
#' @param depth Character. Bit depth. One of `"CV_8U"`, `"CV_8S"`, `"CV_16U"`,
#'   `"CV_16S"`, `"CV_32S"`, `"CV_32F"`, `"CV_64F"`. Default `"CV_8U"`.
#' @param colorspace Character. Color space label. Default `"GRAY"`.
#' @return A new `Image` with all pixels set to 0.
#' @export
zeros <- function(nrow, ncol, nchan = 1L, depth = "CV_8U", colorspace = "GRAY") {
  .check_construct_args(nrow, ncol, nchan, depth, colorspace)
  Image$new(rt_zeros(as.integer(nrow), as.integer(ncol),
                     as.integer(nchan), depth, colorspace))
}

#' Create an image filled with ones
#'
#' All pixel values are set to 1 (not the depth maximum). For CV_8U images this
#' is nearly black. Use `zeros()` combined with `$set_to()` for an arbitrary
#' fill value.
#'
#' @param nrow,ncol Integer. Image dimensions in pixels.
#' @param nchan Integer. Number of channels (1-4). Default 1.
#' @param depth Character. Bit depth. Default `"CV_8U"`.
#' @param colorspace Character. Color space label. Default `"GRAY"`.
#' @return A new `Image` with all pixels set to 1.
#' @export
ones <- function(nrow, ncol, nchan = 1L, depth = "CV_8U", colorspace = "GRAY") {
  .check_construct_args(nrow, ncol, nchan, depth, colorspace)
  Image$new(rt_ones(as.integer(nrow), as.integer(ncol),
                    as.integer(nchan), depth, colorspace))
}

#' Create an image filled with uniform random values
#'
#' @param nrow,ncol Integer. Image dimensions in pixels.
#' @param nchan Integer. Number of channels (1-4). Default 1.
#' @param depth Character. Bit depth. Default `"CV_8U"`.
#' @param colorspace Character. Color space label. Default `"GRAY"`.
#' @param low,high Single numeric. Range of the uniform distribution.
#'   Default `low = 0`, `high = 255`.
#' @return A new `Image` with pixel values drawn from Uniform(`low`, `high`).
#' @export
randu <- function(nrow, ncol, nchan = 1L, depth = "CV_8U", colorspace = "GRAY",
                  low = 0, high = 255) {
  .check_construct_args(nrow, ncol, nchan, depth, colorspace)
  if (length(low) != 1L || !is.numeric(low) || !is.finite(low))
    stop("low must be a single finite numeric", call. = FALSE)
  if (length(high) != 1L || !is.numeric(high) || !is.finite(high))
    stop("high must be a single finite numeric", call. = FALSE)
  if (low >= high) stop("low must be strictly less than high", call. = FALSE)
  Image$new(rt_randu(as.integer(nrow), as.integer(ncol),
                     as.integer(nchan), depth, colorspace,
                     as.double(low), as.double(high)))
}

#' Create an image filled with Gaussian random values
#'
#' @param nrow,ncol Integer. Image dimensions in pixels.
#' @param nchan Integer. Number of channels (1-4). Default 1.
#' @param depth Character. Bit depth. Default `"CV_8U"`.
#' @param colorspace Character. Color space label. Default `"GRAY"`.
#' @param mean Single numeric. Mean of the Gaussian. Default 128.
#' @param sd Single positive numeric. Standard deviation. Default 30.
#' @return A new `Image` with pixel values drawn from Normal(`mean`, `sd`).
#' @export
randn <- function(nrow, ncol, nchan = 1L, depth = "CV_8U", colorspace = "GRAY",
                  mean = 128, sd = 30) {
  .check_construct_args(nrow, ncol, nchan, depth, colorspace)
  if (length(mean) != 1L || !is.numeric(mean) || !is.finite(mean))
    stop("mean must be a single finite numeric", call. = FALSE)
  if (length(sd) != 1L || !is.numeric(sd) || !is.finite(sd) || sd <= 0)
    stop("sd must be a single positive finite numeric", call. = FALSE)
  Image$new(rt_randn(as.integer(nrow), as.integer(ncol),
                     as.integer(nchan), depth, colorspace,
                     as.double(mean), as.double(sd)))
}
