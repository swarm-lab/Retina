#' Build an affine translation matrix
#'
#' Returns a 2x3 affine transformation matrix that translates by \code{(dx, dy)}
#' pixels. Combine with \code{\link{affine_scale}}, \code{\link{affine_shear}},
#' or \code{\link{affine_rotate}} using \code{\%*\%}.
#'
#' @param dx Numeric. Horizontal shift in pixels (positive = rightward).
#' @param dy Numeric. Vertical shift in pixels (positive = downward).
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_scale}}, \code{\link{affine_shear}},
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_translate <- function(dx, dy) {
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
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_scale <- function(fx, fy, cx = 1, cy = 1) {
  matrix(c(fx, 0, (1 - fx) * (cx - 1),
            0, fy, (1 - fy) * (cy - 1)), nrow = 2L, ncol = 3L, byrow = TRUE)
}

#' Build an affine shear matrix
#'
#' Returns a 2x3 affine transformation matrix that shears by \code{(sx, sy)}.
#'
#' @param sx Numeric. Horizontal shear factor.
#' @param sy Numeric. Vertical shear factor.
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_translate}}, \code{\link{affine_scale}},
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_shear <- function(sx, sy) {
  matrix(c(1, sx, 0,  sy, 1, 0), nrow = 2L, ncol = 3L, byrow = TRUE)
}
