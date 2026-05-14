#' Display an image using R's graphics device
#'
#' Wraps \code{dev.hold()} / \code{dev.flush()} for use in capture loops.
#' Typical frame rate is 15–25 fps for moderate image sizes.
#'
#' @param img An \code{Image} object.
#' @param ... Additional arguments passed to \code{img$plot()}.
#' @return \code{NULL} invisibly.
#' @export
display <- function(img, ...) {
  dev.hold()
  img$plot(...)
  dev.flush()
  invisible(NULL)
}
