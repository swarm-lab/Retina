.depth_names <- c(
  "CV_8U", "CV_8S", "CV_16U", "CV_16S",
  "CV_32S", "CV_32F", "CV_64F", "CV_16F"
)

#' Translate an OpenCV depth code to its human-readable name
#'
#' @param depth Integer depth code as returned by \code{img$depth}
#'   (0 = CV_8U, 1 = CV_8S, 2 = CV_16U, 3 = CV_16S,
#'    4 = CV_32S, 5 = CV_32F, 6 = CV_64F, 7 = CV_16F).
#' @return A character string, e.g. \code{"CV_8U"}.
#' @export
depth_name <- function(depth) {
  if (!is.numeric(depth) || length(depth) != 1L ||
      depth < 0 || depth >= length(.depth_names)) {
    stop("Unknown depth code: ", depth, call. = FALSE)
  }
  .depth_names[depth + 1L]
}
