#' @export
Ops.Image <- function(e1, e2) {
  switch(.Generic,
    "+" = e1$add(e2),
    "-" = e1$subtract(e2),
    "*" = e1$multiply(e2),
    "/" = e1$divide(e2),
    stop(paste(.Generic, "not defined for Image objects"), call. = FALSE)
  )
}

#' @export
bitwAnd <- function(x, y, ...) UseMethod("bitwAnd")

#' @export
bitwAnd.default <- function(x, y, ...) base::bitwAnd(x, y)

#' @export
bitwAnd.Image <- function(x, y, ...) x$bitwise_and(y)

#' @export
bitwOr <- function(x, y, ...) UseMethod("bitwOr")

#' @export
bitwOr.default <- function(x, y, ...) base::bitwOr(x, y)

#' @export
bitwOr.Image <- function(x, y, ...) x$bitwise_or(y)

#' @export
bitwXor <- function(x, y, ...) UseMethod("bitwXor")

#' @export
bitwXor.default <- function(x, y, ...) base::bitwXor(x, y)

#' @export
bitwXor.Image <- function(x, y, ...) x$bitwise_xor(y)

#' @export
bitwNot <- function(x, ...) UseMethod("bitwNot")

#' @export
bitwNot.default <- function(x, ...) base::bitwNot(x)

#' @export
bitwNot.Image <- function(x, ...) x$bitwise_not()
