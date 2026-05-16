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
  expect_true(is.numeric(m))
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
  expect_error(affine_from_points(src, dst), "src must be a 3x2 numeric matrix")
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
  expect_error(perspective_from_points(src, dst), "src must be a 4x2 numeric matrix")
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
  expect_error(img_10x10()$warp_affine(diag(3)),
               "m must be a 2x3 numeric matrix")
})

test_that("warp_affine errors on non-matrix input", {
  expect_error(img_10x10()$warp_affine(1:6),
               "m must be a 2x3 numeric matrix")
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
