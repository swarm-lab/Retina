#' Generate a structuring element kernel
#'
#' Returns an integer matrix of 0s and 1s suitable for use as \code{kernel} in
#' \code{$morph()}.
#'
#' @param shape Character. Kernel shape: \code{"rect"} (all ones),
#'   \code{"cross"} (plus-shaped: centre row and column are ones, rest zeros),
#'   or \code{"ellipse"} (ones inside the inscribed ellipse, zeros outside).
#' @param size Single positive odd integer for a square kernel, or a length-2
#'   vector \code{c(width, height)} for a non-square kernel. Both width and
#'   height must be positive odd integers.
#' @return An integer matrix with 0s and 1s, of dimensions
#'   \code{height x width}.
#' @export
#' @examples
#' get_structuring_element("cross", 5L)
#' get_structuring_element("ellipse", c(7L, 5L))
get_structuring_element <- function(shape = "rect", size = 3L) {
  .valid_shapes <- c("rect", "cross", "ellipse")
  if (!is.character(shape) || length(shape) != 1L || !shape %in% .valid_shapes)
    stop("shape must be one of: rect, cross, ellipse", call. = FALSE)
  size <- as.integer(size)
  if (length(size) == 1L) size <- c(size, size)
  if (length(size) != 2L || any(is.na(size)) ||
      any(size < 1L) || any(size %% 2L == 0L))
    stop("size must be a single positive odd integer or c(width, height) of positive odd integers",
         call. = FALSE)
  matrix(rt_get_structuring_element(shape, size[1L], size[2L]),
         nrow = size[2L], ncol = size[1L])
}

#' Generate a Gabor filter kernel
#'
#' Returns a numeric matrix containing Gabor filter coefficients, suitable for
#' use as \code{kernel} in \code{$filter2D()}.
#'
#' @param ksize Length-2 integer vector \code{c(width, height)}. Both must be
#'   positive odd integers.
#' @param sigma Single positive numeric. Standard deviation of the Gaussian
#'   envelope.
#' @param theta Single numeric. Orientation of the filter normal in
#'   \strong{degrees} (converted to radians internally).
#' @param lambda Single positive numeric. Wavelength of the sinusoidal
#'   component, in pixels.
#' @param gamma Single positive numeric. Spatial aspect ratio. Values less
#'   than 1 produce elongated filters; \code{1} gives a circular envelope.
#' @param psi Single numeric. Phase offset in radians. Default \code{pi / 2}.
#' @param kdepth Character. Precision of the returned kernel matrix:
#'   \code{"CV_32F"} (single-precision float) or \code{"CV_64F"}
#'   (double-precision, default).
#' @return A numeric matrix of dimensions \code{height x width}.
#' @export
#' @examples
#' k <- get_gabor_kernel(c(9L, 9L), sigma = 2, theta = 0, lambda = 5, gamma = 0.5)
#' dim(k)
get_gabor_kernel <- function(ksize, sigma, theta, lambda, gamma,
                             psi = pi / 2, kdepth = "CV_64F") {
  ksize <- as.integer(ksize)
  if (length(ksize) != 2L || any(is.na(ksize)) ||
      any(ksize < 1L) || any(ksize %% 2L == 0L))
    stop("ksize must be c(width, height) of positive odd integers", call. = FALSE)
  if (!is.numeric(sigma) || length(sigma) != 1L || !is.finite(sigma) || sigma <= 0)
    stop("sigma must be a single positive finite numeric", call. = FALSE)
  if (!is.numeric(theta) || length(theta) != 1L || !is.finite(theta))
    stop("theta must be a single finite numeric", call. = FALSE)
  if (!is.numeric(lambda) || length(lambda) != 1L || !is.finite(lambda) || lambda <= 0)
    stop("lambda must be a single positive finite numeric", call. = FALSE)
  if (!is.numeric(gamma) || length(gamma) != 1L || !is.finite(gamma) || gamma <= 0)
    stop("gamma must be a single positive finite numeric", call. = FALSE)
  if (!is.numeric(psi) || length(psi) != 1L || !is.finite(psi))
    stop("psi must be a single finite numeric", call. = FALSE)
  if (!is.character(kdepth) || length(kdepth) != 1L ||
      !kdepth %in% c("CV_32F", "CV_64F"))
    stop("kdepth must be one of: CV_32F, CV_64F", call. = FALSE)
  .ktype <- switch(kdepth, CV_32F = 5L, CV_64F = 6L)
  .theta_rad <- as.double(theta) * pi / 180
  matrix(
    rt_get_gabor_kernel(ksize[1L], ksize[2L], as.double(sigma), .theta_rad,
                        as.double(lambda), as.double(gamma), as.double(psi),
                        .ktype),
    nrow = ksize[2L], ncol = ksize[1L]
  )
}
