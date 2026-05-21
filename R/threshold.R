.autothresh_methods <- c(
  "imagej", "huang", "huang2", "intermodes", "isodata", "li",
  "maxentropy", "mean", "minerrori", "minimum", "moments", "otsu",
  "percentile", "renyientropy", "shanbhag", "triangle", "yen"
)

#' Compute an automatic threshold value from an image
#'
#' Returns the numeric threshold value computed by one of the 17 ImageJ Auto
#' Threshold algorithms, without modifying the image.
#'
#' @param img A single-channel \code{Image} object.
#' @param method A lowercase string naming one of the 17 supported methods:
#'   \code{"imagej"}, \code{"huang"}, \code{"huang2"}, \code{"intermodes"},
#'   \code{"isodata"}, \code{"li"}, \code{"maxentropy"}, \code{"mean"},
#'   \code{"minerrori"}, \code{"minimum"}, \code{"moments"}, \code{"otsu"},
#'   \code{"percentile"}, \code{"renyientropy"}, \code{"shanbhag"},
#'   \code{"triangle"}, \code{"yen"}.
#' @param bins Integer >= 2. Histogram bin count used when the image depth is
#'   not \code{CV_8U}. Ignored for \code{CV_8U} images (always 256 bins).
#'   Default \code{256}.
#' @return A single numeric (double) -- the threshold in the image's native
#'   intensity units.
#' @export
autothreshold_value <- function(img, method, bins = 256L) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  if (img$nchan != 1L)
    stop("autothreshold_value() requires a single-channel image", call. = FALSE)
  if (!is.character(method) || length(method) != 1L || !(method %in% .autothresh_methods))
    stop(sprintf("method must be one of: %s",
                 paste(.autothresh_methods, collapse = ", ")), call. = FALSE)
  bins_i <- as.integer(bins)
  if (!is.numeric(bins) || length(bins) != 1L || is.na(bins_i) || bins_i < 2L)
    stop("bins must be a single integer >= 2", call. = FALSE)
  rt_autothreshold_value(.rt_ptr(img), method, bins_i)
}
