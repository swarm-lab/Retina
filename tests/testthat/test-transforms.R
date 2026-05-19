library(Retina)

# ── affine_translate ──────────────────────────────────────────────────────────

test_that("affine_translate returns correct 2x3 matrix", {
  m <- affine_translate(10, 5)
  expect_true(is.matrix(m))
  expect_equal(dim(m), c(2L, 3L))
  expect_equal(m, matrix(c(1, 0, 10,  0, 1, 5), nrow = 2, byrow = TRUE))
})

test_that("affine_translate with zero shift returns identity translation", {
  m <- affine_translate(0, 0)
  expect_equal(m, matrix(c(1, 0, 0,  0, 1, 0), nrow = 2, byrow = TRUE))
})

# ── affine_scale ──────────────────────────────────────────────────────────────

test_that("affine_scale with default center returns pure scale matrix", {
  m <- affine_scale(2, 3)
  expect_true(is.matrix(m))
  expect_equal(dim(m), c(2L, 3L))
  # cx=1, cy=1: translation terms = (1-fx)*(1-1) = 0
  expect_equal(m, matrix(c(2, 0, 0,  0, 3, 0), nrow = 2, byrow = TRUE))
})

test_that("affine_scale with explicit center produces correct translation", {
  m <- affine_scale(2, 2, cx = 5, cy = 5)
  # translation = (1 - fx) * (cx - 1) = (1-2)*(5-1) = -4
  expect_equal(m[1, 3], (1 - 2) * (5 - 1))
  expect_equal(m[2, 3], (1 - 2) * (5 - 1))
})

# ── affine_shear ──────────────────────────────────────────────────────────────

test_that("affine_shear returns correct 2x3 matrix", {
  m <- affine_shear(0.5, 0.2)
  expect_true(is.matrix(m))
  expect_equal(dim(m), c(2L, 3L))
  expect_equal(m, matrix(c(1, 0.5, 0,  0.2, 1, 0), nrow = 2, byrow = TRUE))
})

test_that("affine_shear with zero shear returns identity-like matrix", {
  m <- affine_shear(0, 0)
  expect_equal(m, matrix(c(1, 0, 0,  0, 1, 0), nrow = 2, byrow = TRUE))
})

# ── affine_rotate ─────────────────────────────────────────────────────────────

test_that("affine_rotate returns a 2x3 numeric matrix", {
  m <- affine_rotate(45, cx = 5, cy = 5)
  expect_true(is.matrix(m))
  expect_type(m, "double")
  expect_equal(dim(m), c(2L, 3L))
})

test_that("affine_rotate 0 degrees returns identity-like matrix", {
  m <- affine_rotate(0, cx = 1, cy = 1)
  expect_equal(m[1, 1],  1, tolerance = 1e-6)
  expect_equal(m[1, 2],  0, tolerance = 1e-6)
  expect_equal(m[2, 1],  0, tolerance = 1e-6)
  expect_equal(m[2, 2],  1, tolerance = 1e-6)
})

test_that("affine_rotate 90 degrees around non-origin centre has correct translation", {
  # OpenCV getRotationMatrix2D rotates CW for positive angle.
  # Rotating 90 CW around (cx=5, cy=5), OpenCV centre (4,4) (0-based):
  # [[cos(-90), -sin(-90), tx], [sin(-90), cos(-90), ty]]
  # = [[0, 1, tx], [-1, 0, ty]]
  # tx = (1-cos(-90))*4 + sin(-90)*(-4) ... simplifies to 0 via OpenCV formula
  # ty = -sin(-90)*4 + (1-cos(-90))*4 = 4+4 = 8
  # In R 2x3 matrix (column-major): m[1,2]=1, m[2,1]=-1, m[1,3]=0, m[2,3]=8
  m <- affine_rotate(90, cx = 5, cy = 5)
  expect_equal(m[1, 1],  0, tolerance = 1e-5)
  expect_equal(m[1, 2],  1, tolerance = 1e-5)
  expect_equal(m[2, 1], -1, tolerance = 1e-5)
  expect_equal(m[2, 2],  0, tolerance = 1e-5)
  expect_equal(m[1, 3],  0, tolerance = 1e-5)
  expect_equal(m[2, 3],  8, tolerance = 1e-5)
})

# ── affine_from_points ────────────────────────────────────────────────────────

test_that("affine_from_points returns a 2x3 numeric matrix", {
  src <- matrix(c(1, 1,  10, 1,  1, 10), nrow = 3, ncol = 2, byrow = TRUE)
  dst <- matrix(c(2, 2,  11, 2,  2, 11), nrow = 3, ncol = 2, byrow = TRUE)
  m <- affine_from_points(src, dst)
  expect_true(is.matrix(m))
  expect_equal(dim(m), c(2L, 3L))
})

test_that("affine_from_points identity mapping returns identity-like matrix", {
  src <- matrix(c(1, 1,  10, 1,  1, 10), nrow = 3, ncol = 2, byrow = TRUE)
  m <- affine_from_points(src, src)
  expect_equal(m[1, 1],  1, tolerance = 1e-5)
  expect_equal(m[1, 2],  0, tolerance = 1e-5)
  expect_equal(m[2, 1],  0, tolerance = 1e-5)
  expect_equal(m[2, 2],  1, tolerance = 1e-5)
  expect_equal(m[1, 3],  0, tolerance = 1e-5)
  expect_equal(m[2, 3],  0, tolerance = 1e-5)
})

test_that("affine_from_points errors on wrong src shape", {
  src <- matrix(1:8, nrow = 4, ncol = 2)
  dst <- matrix(c(1, 1,  10, 1,  1, 10), nrow = 3, ncol = 2, byrow = TRUE)
  expect_snapshot(error = TRUE, affine_from_points(src, dst))
})

# ── perspective_from_points ───────────────────────────────────────────────────

test_that("perspective_from_points returns a 3x3 numeric matrix", {
  src <- matrix(c(1, 1,  10, 1,  10, 10,  1, 10), nrow = 4, ncol = 2, byrow = TRUE)
  dst <- matrix(c(2, 2,  11, 2,  11, 11,  2, 11), nrow = 4, ncol = 2, byrow = TRUE)
  m <- perspective_from_points(src, dst)
  expect_true(is.matrix(m))
  expect_equal(dim(m), c(3L, 3L))
})

test_that("perspective_from_points identity mapping returns identity-like matrix", {
  src <- matrix(c(1, 1,  10, 1,  10, 10,  1, 10), nrow = 4, ncol = 2, byrow = TRUE)
  m <- perspective_from_points(src, src)
  m_norm <- m / m[3, 3]
  # Full normalized 3x3 identity check
  expect_equal(m_norm[1, 1], 1, tolerance = 1e-5)
  expect_equal(m_norm[2, 2], 1, tolerance = 1e-5)
  expect_equal(m_norm[3, 3], 1, tolerance = 1e-5)
  expect_equal(m_norm[1, 2], 0, tolerance = 1e-5)
  expect_equal(m_norm[2, 1], 0, tolerance = 1e-5)
  expect_equal(m_norm[1, 3], 0, tolerance = 1e-5)
  expect_equal(m_norm[2, 3], 0, tolerance = 1e-5)
  expect_equal(m_norm[3, 1], 0, tolerance = 1e-5)
  expect_equal(m_norm[3, 2], 0, tolerance = 1e-5)
})

test_that("perspective_from_points errors on wrong src shape", {
  src <- matrix(1:6, nrow = 3, ncol = 2)
  dst <- matrix(c(1, 1,  10, 1,  10, 10,  1, 10), nrow = 4, ncol = 2, byrow = TRUE)
  expect_snapshot(error = TRUE, perspective_from_points(src, dst))
})

# ── warp_affine ───────────────────────────────────────────────────────────────

img_10x10 <- function() {
  arr <- array(seq_len(300L), dim = c(10L, 10L, 3L))
  storage.mode(arr) <- "integer"
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

test_that("warp_affine with identity matrix preserves dimensions", {
  m <- cbind(diag(2), c(0, 0))
  result <- img_10x10()$warp_affine(m)
  expect_equal(result$ncol, 10L)
  expect_equal(result$nrow, 10L)
})

test_that("warp_affine with explicit width/height produces correct output size", {
  m <- cbind(diag(2), c(0, 0))
  result <- img_10x10()$warp_affine(m, width = 20L, height = 5L)
  expect_equal(result$ncol, 20L)
  expect_equal(result$nrow, 5L)
})

test_that("warp_affine errors on wrong matrix shape (3x3)", {
  expect_snapshot(error = TRUE, img_10x10()$warp_affine(diag(3)))
})

test_that("warp_affine errors on non-matrix input", {
  expect_snapshot(error = TRUE, img_10x10()$warp_affine(1:6))
})

test_that("warp_affine preserves colorspace", {
  m <- cbind(diag(2), c(0, 0))
  expect_equal(img_10x10()$warp_affine(m)$colorspace, "BGR")
})

test_that("warp_affine_ modifies image in place and returns self", {
  img <- img_10x10()
  m <- cbind(diag(2), c(0, 0))
  result <- img$warp_affine_(m)
  expect_identical(result, img)
  expect_equal(img$ncol, 10L)
  expect_equal(img$nrow, 10L)
})

test_that("warp_affine with translation shifts pixels correctly", {
  # 4x4 single-channel image: column 1 = 200, rest = 0
  arr <- array(0L, dim = c(4L, 4L, 1L))
  arr[, 1, 1] <- 200L
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  # Translate right by 2 pixels: column 1 content should appear at column 3
  m <- affine_translate(2, 0)
  result <- img$warp_affine(m)
  out <- rt_image_to_integer_array(result$.__enclos_env__$private$.ptr)
  # Column 1 of result should be 0 (content moved right)
  expect_true(all(out[, 1, 1] == 0L))
  # Column 3 of result should be 200
  expect_true(all(out[, 3, 1] == 200L))
})

test_that("warp_affine() with non-default interpolation and border_type runs without error", {
  m <- cbind(diag(2), c(0, 0))
  expect_no_error(
    img_10x10()$warp_affine(m, interpolation = "nearest", border_type = "constant")
  )
})

# ── warp_perspective ──────────────────────────────────────────────────────────

test_that("warp_perspective with identity matrix preserves dimensions", {
  result <- img_10x10()$warp_perspective(diag(3))
  expect_equal(result$ncol, 10L)
  expect_equal(result$nrow, 10L)
})

test_that("warp_perspective with explicit width/height produces correct output size", {
  result <- img_10x10()$warp_perspective(diag(3), width = 20L, height = 5L)
  expect_equal(result$ncol, 20L)
  expect_equal(result$nrow, 5L)
})

test_that("warp_perspective errors on wrong matrix shape (2x3)", {
  m <- cbind(diag(2), c(0, 0))
  expect_snapshot(error = TRUE, img_10x10()$warp_perspective(m))
})

test_that("warp_perspective errors on non-matrix input", {
  expect_snapshot(error = TRUE, img_10x10()$warp_perspective(1:9))
})

test_that("warp_perspective preserves colorspace", {
  expect_equal(img_10x10()$warp_perspective(diag(3))$colorspace, "BGR")
})

test_that("warp_perspective_ modifies image in place and returns self", {
  img <- img_10x10()
  result <- img$warp_perspective_(diag(3))
  expect_identical(result, img)
  expect_equal(img$ncol, 10L)
  expect_equal(img$nrow, 10L)
})

test_that("warp_perspective with perspective_from_points returns correct dimensions and colorspace", {
  # 4x4 GRAY image, all zeros except top-left 2x2 = 200
  arr <- array(0L, dim = c(4L, 4L, 1L))
  arr[1:2, 1:2, 1] <- 200L
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  # Identity transform via perspective_from_points should preserve content
  src <- matrix(c(1,1, 4,1, 4,4, 1,4), nrow = 4, ncol = 2, byrow = TRUE)
  m <- perspective_from_points(src, src)
  result <- img$warp_perspective(m)
  expect_equal(result$ncol, 4L)
  expect_equal(result$nrow, 4L)
  expect_equal(result$colorspace, "GRAY")
})
