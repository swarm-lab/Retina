#' Build an affine translation matrix
#'
#' Returns a 2x3 affine transformation matrix that translates by \code{(dx, dy)}
#' pixels. To compose transforms, embed into a 3x3 matrix with \code{rbind(m, c(0, 0, 1))}
#' before multiplying with \code{\%*\%}.
#'
#' @param dx Numeric. Horizontal shift in pixels (positive = rightward).
#' @param dy Numeric. Vertical shift in pixels (positive = downward).
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_scale}}, \code{\link{affine_shear}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_translate <- function(dx, dy) {
  if (!is.numeric(dx) || length(dx) != 1L || !is.numeric(dy) || length(dy) != 1L)
    stop("dx and dy must be single numeric values", call. = FALSE)
  matrix(c(1, 0, dx,  0, 1, dy), nrow = 2L, ncol = 3L, byrow = TRUE)
}

#' Build an affine scaling matrix
#'
#' Returns a 2x3 affine transformation matrix that scales by \code{(fx, fy)}
#' around centre \code{(cx, cy)} (1-based pixel coordinates).
#'
#' @param fx Numeric. Horizontal scale factor.
#' @param fy Numeric. Vertical scale factor.
#' @param cx Numeric. X coordinate of the scale centre (1-based). Default
#'   \code{1} (top-left; produces a pure scale with no translation).
#' @param cy Numeric. Y coordinate of the scale centre (1-based). Default
#'   \code{1}.
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_translate}}, \code{\link{affine_shear}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_scale <- function(fx, fy, cx = 1, cy = 1) {
  if (!is.numeric(fx) || length(fx) != 1L || !is.numeric(fy) || length(fy) != 1L)
    stop("fx and fy must be single numeric values", call. = FALSE)
  if (!is.numeric(cx) || length(cx) != 1L || !is.numeric(cy) || length(cy) != 1L)
    stop("cx and cy must be single numeric values", call. = FALSE)
  matrix(c(fx, 0, (1 - fx) * (cx - 1),
            0, fy, (1 - fy) * (cy - 1)), nrow = 2L, ncol = 3L, byrow = TRUE)
}

#' Build an affine shear matrix
#'
#' Returns a 2x3 affine transformation matrix that applies a simultaneous
#' horizontal shear (controlled by \code{sx}) and vertical shear (controlled
#' by \code{sy}). \code{sx} shifts columns in the x direction proportionally
#' to their y position; \code{sy} shifts rows in the y direction
#' proportionally to their x position. Use zero for either to apply a
#' single-axis shear.
#'
#' @param sx Numeric. Horizontal shear factor.
#' @param sy Numeric. Vertical shear factor.
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_translate}}, \code{\link{affine_scale}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_shear <- function(sx, sy) {
  if (!is.numeric(sx) || length(sx) != 1L || !is.numeric(sy) || length(sy) != 1L)
    stop("sx and sy must be single numeric values", call. = FALSE)
  matrix(c(1, sx, 0,  sy, 1, 0), nrow = 2L, ncol = 3L, byrow = TRUE)
}
