# ── col2bgr ───────────────────────────────────────────────────────────────────

#' Convert an R color to a BGR(A) numeric vector
#'
#' Mirrors the interface of \code{\link[grDevices]{col2rgb}}: accepts any R
#' color name or hex string, plus a pre-formed numeric BGR or BGRA vector.
#'
#' @param color An R color name (e.g., \code{"red"}), a hex string (e.g.,
#'   \code{"#FF0000"}), or a numeric vector of length 3 (BGR) or 4 (BGRA)
#'   with values in [0, 255].
#' @param alpha Logical. When \code{TRUE}, include the alpha channel (output
#'   is BGRA). Applies only to string/hex input; numeric vectors are returned
#'   as-is regardless of this flag. Default \code{FALSE}.
#' @return A named numeric vector \code{c(B = ..., G = ..., R = ...)} when
#'   \code{alpha = FALSE}, or \code{c(B = ..., G = ..., R = ..., A = ...)}
#'   when \code{alpha = TRUE}.
#' @export
col2bgr <- function(color, alpha = FALSE) {
  if (!is.logical(alpha) || length(alpha) != 1L)
    stop("alpha must be a single logical value", call. = FALSE)
  if (is.numeric(color)) {
    if (length(color) < 3L || length(color) > 4L)
      stop("color must be a numeric vector of length 3 or 4", call. = FALSE)
    if (any(!is.finite(color)) || any(color < 0) || any(color > 255))
      stop("numeric color values must be in [0, 255]", call. = FALSE)
    nms <- if (length(color) == 4L) c("B", "G", "R", "A") else c("B", "G", "R")
    return(setNames(as.numeric(color), nms))
  }
  rgb <- grDevices::col2rgb(color, alpha = alpha)
  if (isTRUE(alpha)) {
    c(B = unname(rgb["blue",   1L]),
      G = unname(rgb["green",  1L]),
      R = unname(rgb["red",    1L]),
      A = unname(rgb["alpha",  1L]))
  } else {
    c(B = unname(rgb["blue",  1L]),
      G = unname(rgb["green", 1L]),
      R = unname(rgb["red",   1L]))
  }
}

# ── shared validation helper ──────────────────────────────────────────────────

.rt_valid_draw_common <- function(color, thickness, line_type, filled = FALSE) {
  .color <- col2bgr(color)[1:3]
  if (!isTRUE(filled)) {
    if (!is.numeric(thickness) || length(thickness) != 1L ||
        !is.finite(thickness) || thickness != round(thickness) || thickness < 1L)
      stop("thickness must be a single positive integer", call. = FALSE)
  }
  if (!is.character(line_type) || length(line_type) != 1L ||
      !line_type %in% c("line_4", "line_8", "aa"))
    stop("line_type must be one of: line_4, line_8, aa", call. = FALSE)
  list(
    color     = .color,
    thickness = if (isTRUE(filled)) -1L else as.integer(thickness),
    line_type = line_type
  )
}
