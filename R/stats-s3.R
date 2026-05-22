#' @importFrom stats median var quantile
NULL

#' @export
mean.Image <- function(x, ...) x$mean()

#' @export
median.Image <- function(x, na.rm = FALSE, ...) x$median()

#' @export
quantile.Image <- function(x, probs = 0.5, ...) x$quantile(probs)

#' @export
Summary.Image <- function(..., na.rm = FALSE) {
  img <- ..1
  switch(.Generic,
    min = img$min(),
    max = img$max(),
    sum = img$sum(),
    stop(paste(.Generic, "not defined for Image objects"), call. = FALSE)
  )
}

# sd and var are not S3 generics in base R, so we shadow them with new generics
# and provide a .default method that delegates back to the stats originals.

#' Standard deviation for Image objects
#'
#' S3 generic extending \code{\link[stats]{sd}} to support \code{Image}
#' objects. Non-Image inputs delegate to \code{stats::sd}.
#'
#' @param x An \code{Image} object, or a numeric vector for the default method.
#' @param na.rm Logical; should missing values be removed? Passed to
#'   \code{stats::sd} for non-Image objects (ignored for \code{Image}).
#' @param ... Additional arguments passed to methods.
#'
#' @return For \code{Image} inputs, a numeric vector of per-channel standard
#'   deviations. For other inputs, the result of \code{\link[stats]{sd}}.
#'
#' @seealso \code{\link[stats]{sd}}, \code{\link{var}}
#'
#' @export
sd <- function(x, ...) UseMethod("sd")

#' @rdname sd
#' @export
sd.default <- function(x, na.rm = FALSE, ...) stats::sd(x, na.rm = na.rm)

#' @rdname sd
#' @export
sd.Image <- function(x, ...) x$sd()

#' Variance for Image objects
#'
#' S3 generic extending \code{\link[stats]{var}} to support \code{Image}
#' objects. Non-Image inputs delegate to \code{stats::var}.
#'
#' @param x An \code{Image} object, or a numeric vector/matrix for the default
#'   method.
#' @param y \code{NULL} or a numeric vector/matrix; passed to
#'   \code{stats::var} for non-Image objects.
#' @param na.rm Logical; should missing values be removed? Passed to
#'   \code{stats::var} for non-Image objects (ignored for \code{Image}).
#' @param use An optional character string specifying the method for computing
#'   covariances; passed to \code{stats::var} for non-Image objects.
#' @param ... Additional arguments passed to methods.
#'
#' @return For \code{Image} inputs, a numeric vector of per-channel variances.
#'   For other inputs, the result of \code{\link[stats]{var}}.
#'
#' @seealso \code{\link[stats]{var}}, \code{\link{sd}}
#'
#' @export
var <- function(x, ...) UseMethod("var")

#' @rdname var
#' @export
var.default <- function(x, y = NULL, na.rm = FALSE, use, ...) {
  if (missing(use))
    stats::var(x, y = y, na.rm = na.rm)
  else
    stats::var(x, y = y, na.rm = na.rm, use = use)
}

#' @rdname var
#' @export
var.Image <- function(x, ...) x$var()
