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
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
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
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
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
#'   \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_shear <- function(sx, sy) {
  if (!is.numeric(sx) || length(sx) != 1L || !is.numeric(sy) || length(sy) != 1L)
    stop("sx and sy must be single numeric values", call. = FALSE)
  matrix(c(1, sx, 0,  sy, 1, 0), nrow = 2L, ncol = 3L, byrow = TRUE)
}

#' Build an affine rotation matrix
#'
#' Returns a 2x3 affine transformation matrix for rotating by \code{angle}
#' degrees counter-clockwise around \code{(cx, cy)} (1-based pixel
#' coordinates). To compose with other transforms, embed into a 3x3 matrix
#' with \code{rbind(m, c(0, 0, 1))} before multiplying with \code{\%*\%}.
#'
#' @param angle Numeric. Rotation angle in degrees, counter-clockwise.
#' @param cx Numeric. X coordinate of the rotation centre (1-based).
#' @param cy Numeric. Y coordinate of the rotation centre (1-based).
#' @param scale Numeric. Isotropic scale factor applied during rotation.
#'   Default \code{1}.
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_translate}}, \code{\link{affine_scale}},
#'   \code{\link{affine_shear}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_rotate <- function(angle, cx, cy, scale = 1) {
  if (!is.numeric(angle) || length(angle) != 1L)
    stop("angle must be a single numeric value", call. = FALSE)
  if (!is.numeric(cx) || length(cx) != 1L)
    stop("cx must be a single numeric value", call. = FALSE)
  if (!is.numeric(cy) || length(cy) != 1L)
    stop("cy must be a single numeric value", call. = FALSE)
  if (!is.numeric(scale) || length(scale) != 1L || scale <= 0)
    stop("scale must be a single positive numeric value", call. = FALSE)
  m <- rt_affine_rotate(as.double(angle), as.double(cx), as.double(cy),
                        as.double(scale))
  matrix(m, nrow = 2L, ncol = 3L)
}

#' Compute an affine transformation matrix from point correspondences
#'
#' Computes the 2x3 affine transformation matrix that maps \code{src} points
#' to \code{dst} points. Requires exactly 3 point pairs.
#'
#' @param src A 3x2 numeric matrix of source points. Column 1 = x, column 2 = y
#'   (1-based pixel coordinates).
#' @param dst A 3x2 numeric matrix of destination points. Same convention as
#'   \code{src}.
#' @return A 2x3 numeric matrix.
#' @seealso \code{\link{affine_translate}}, \code{\link{affine_scale}},
#'   \code{\link{affine_shear}}, \code{\link{affine_rotate}},
#'   \code{\link[Retina]{Image}}
#' @export
affine_from_points <- function(src, dst) {
  if (!is.matrix(src) || !is.numeric(src) || !identical(dim(src), c(3L, 2L)))
    stop("src must be a 3x2 numeric matrix", call. = FALSE)
  if (!is.matrix(dst) || !is.numeric(dst) || !identical(dim(dst), c(3L, 2L)))
    stop("dst must be a 3x2 numeric matrix", call. = FALSE)
  m <- rt_affine_from_points(as.double(src), as.double(dst))
  matrix(m, nrow = 2L, ncol = 3L)
}

#' Compute a perspective transformation matrix from point correspondences
#'
#' Computes the 3x3 perspective (homography) matrix that maps \code{src}
#' points to \code{dst} points. Requires exactly 4 point pairs.
#'
#' @param src A 4x2 numeric matrix of source points. Column 1 = x, column 2 = y
#'   (1-based pixel coordinates).
#' @param dst A 4x2 numeric matrix of destination points. Same convention as
#'   \code{src}.
#' @return A 3x3 numeric matrix.
#' @seealso \code{\link{affine_rotate}}, \code{\link{affine_from_points}},
#'   \code{\link[Retina]{Image}}
#' @export
perspective_from_points <- function(src, dst) {
  if (!is.matrix(src) || !is.numeric(src) || !identical(dim(src), c(4L, 2L)))
    stop("src must be a 4x2 numeric matrix", call. = FALSE)
  if (!is.matrix(dst) || !is.numeric(dst) || !identical(dim(dst), c(4L, 2L)))
    stop("dst must be a 4x2 numeric matrix", call. = FALSE)
  m <- rt_perspective_from_points(as.double(src), as.double(dst))
  matrix(m, nrow = 3L, ncol = 3L)
}
