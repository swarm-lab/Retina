# -- col2bgr -------------------------------------------------------------------

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

# -- shared validation helper --------------------------------------------------

.rt_valid_draw_common <- function(color, thickness, line_type, filled = FALSE) {
  .color <- as.double(col2bgr(color)[1:3])
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

# -- get_text_size -------------------------------------------------------------

#' Measure the bounding box of a text string
#'
#' Returns the pixel dimensions of the bounding box that would be drawn by
#' \code{$draw_text()}, without modifying any image.
#'
#' @param text Character. The string to measure.
#' @param font Character. Font face name. One of \code{"simplex"} (default),
#'   \code{"plain"}, \code{"duplex"}, \code{"complex"}, \code{"triplex"},
#'   \code{"complex_small"}, \code{"script_simplex"}, \code{"script_complex"}.
#' @param font_size Numeric. Scale factor. Use the same value as in
#'   \code{$draw_text()}. Default \code{1}.
#' @param italic Logical. Use the italic variant. Default \code{FALSE}.
#' @param thickness Positive integer. Character stroke width. Must match the
#'   value used in \code{$draw_text()} to get accurate results. Default
#'   \code{1L}.
#' @return A named list: \code{list(width = ..., height = ..., baseline = ...)}.
#'   All values are non-negative integers. \code{baseline} is the y-offset of
#'   the baseline below the bottom of the bounding box.
#' @export
get_text_size <- function(text, font = "simplex", font_size = 1,
                          italic = FALSE, thickness = 1L) {
  .valid_fonts <- c("simplex", "plain", "duplex", "complex", "triplex",
                    "complex_small", "script_simplex", "script_complex")
  if (!is.character(text) || length(text) != 1L)
    stop("text must be a single character string", call. = FALSE)
  if (!is.character(font) || length(font) != 1L || !font %in% .valid_fonts)
    stop(paste("font must be one of:", paste(.valid_fonts, collapse = ", ")),
         call. = FALSE)
  if (!is.numeric(font_size) || length(font_size) != 1L)
    stop("font_size must be a single numeric value", call. = FALSE)
  if (!is.logical(italic) || length(italic) != 1L)
    stop("italic must be a single logical value", call. = FALSE)
  if (!is.numeric(thickness) || length(thickness) != 1L ||
      !is.finite(thickness) || thickness != round(thickness) || thickness < 1L)
    stop("thickness must be a single positive integer", call. = FALSE)
  rt_get_text_size(as.character(text), font,
                   as.double(font_size), isTRUE(italic),
                   as.integer(thickness))
}
