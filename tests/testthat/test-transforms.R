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
