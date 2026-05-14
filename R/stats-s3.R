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

#' @export
sd <- function(x, ...) UseMethod("sd")

#' @export
sd.default <- function(x, na.rm = FALSE, ...) stats::sd(x, na.rm = na.rm)

#' @export
sd.Image <- function(x, ...) x$sd()

#' @export
var <- function(x, ...) UseMethod("var")

#' @export
var.default <- function(x, y = NULL, na.rm = FALSE, use, ...) {
  if (missing(use))
    stats::var(x, y = y, na.rm = na.rm)
  else
    stats::var(x, y = y, na.rm = na.rm, use = use)
}

#' @export
var.Image <- function(x, ...) x$var()
