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

#' Bitwise operations for Image objects
#'
#' S3 generics extending \code{\link[base]{bitwAnd}}, \code{\link[base]{bitwOr}},
#' \code{\link[base]{bitwXor}}, and \code{\link[base]{bitwNot}} to support
#' \code{Image} objects. Non-Image inputs delegate to the corresponding
#' \code{base} function.
#'
#' @param x An \code{Image} object, or an integer vector for the default
#'   methods.
#' @param y An \code{Image} object, scalar, or integer vector
#'   (\code{bitwAnd}, \code{bitwOr}, \code{bitwXor} only).
#' @param ... Additional arguments (ignored for \code{Image} objects).
#'
#' @return For \code{Image} inputs, a new \code{Image} with the element-wise
#'   bitwise result. For other inputs, delegates to the corresponding
#'   \code{\link[base]{bitwAnd}} family function.
#'
#' @seealso \code{\link[base]{bitwAnd}}
#'
#' @name bitwAnd
#' @export
bitwAnd <- function(x, y, ...) UseMethod("bitwAnd")

#' @rdname bitwAnd
#' @export
bitwAnd.default <- function(x, y, ...) base::bitwAnd(x, y)

#' @rdname bitwAnd
#' @export
bitwAnd.Image <- function(x, y, ...) x$bitwise_and(y)

#' @rdname bitwAnd
#' @export
bitwOr <- function(x, y, ...) UseMethod("bitwOr")

#' @rdname bitwAnd
#' @export
bitwOr.default <- function(x, y, ...) base::bitwOr(x, y)

#' @rdname bitwAnd
#' @export
bitwOr.Image <- function(x, y, ...) x$bitwise_or(y)

#' @rdname bitwAnd
#' @export
bitwXor <- function(x, y, ...) UseMethod("bitwXor")

#' @rdname bitwAnd
#' @export
bitwXor.default <- function(x, y, ...) base::bitwXor(x, y)

#' @rdname bitwAnd
#' @export
bitwXor.Image <- function(x, y, ...) x$bitwise_xor(y)

#' @rdname bitwAnd
#' @export
bitwNot <- function(x, ...) UseMethod("bitwNot")

#' @rdname bitwAnd
#' @export
bitwNot.default <- function(x, ...) base::bitwNot(x)

#' @rdname bitwAnd
#' @export
bitwNot.Image <- function(x, ...) x$bitwise_not()
