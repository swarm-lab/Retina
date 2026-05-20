# Helper: 10×10 single-channel CV_32F image with all pixels = val
img_float <- function(val = 4.0, nchan = 1L, cs = "GRAY") {
  arr <- array(val, dim = c(10L, 10L, nchan))
  Image$new(arr, colorspace = cs, depth = "CV_32F")
}

# ── $pow() ────────────────────────────────────────────────────────────────────

test_that("$pow() raises pixels to the given power", {
  result <- img_float(4.0)$pow(2.0)
  expect_equal(result$to_array()[1, 1, 1], 16.0, tolerance = 1e-5)
})

test_that("$pow() with exponent 0 produces all-ones image", {
  result <- img_float(4.0)$pow(0.0)
  expect_equal(result$to_array()[1, 1, 1], 1.0, tolerance = 1e-5)
})

test_that("$pow() with fractional exponent on non-negative pixels", {
  result <- img_float(4.0)$pow(0.5)
  expect_equal(result$to_array()[1, 1, 1], 2.0, tolerance = 1e-5)
})

test_that("$pow() errors on integer-depth image", {
  expect_error(make_test_image()$pow(2.0), "CV_32F")
})

test_that("$pow_() modifies self in place", {
  img <- img_float(4.0)
  img$pow_(2.0)
  expect_equal(img$to_array()[1, 1, 1], 16.0, tolerance = 1e-5)
})

test_that("$pow() preserves colorspace", {
  img <- img_float(4.0, nchan = 3L, cs = "BGR")
  expect_equal(img$pow(2.0)$colorspace, "BGR")
})

test_that("$pow() preserves CV_64F depth", {
  arr <- array(4.0, dim = c(10L, 10L, 1L))
  img64 <- Image$new(arr, colorspace = "GRAY", depth = "CV_64F")
  expect_equal(img64$pow(2.0)$depth_name, "CV_64F")
})

# ── $exp() ────────────────────────────────────────────────────────────────────

test_that("$exp() raises e to each pixel", {
  result <- img_float(1.0)$exp()
  expect_equal(result$to_array()[1, 1, 1], exp(1), tolerance = 1e-5)
})

test_that("$exp() errors on integer-depth image", {
  expect_error(make_test_image()$exp(), "CV_32F")
})

test_that("$exp_() modifies self in place", {
  img <- img_float(1.0)
  img$exp_()
  expect_equal(img$to_array()[1, 1, 1], exp(1), tolerance = 1e-5)
})

test_that("$exp() preserves colorspace", {
  img <- img_float(1.0, nchan = 3L, cs = "BGR")
  expect_equal(img$exp()$colorspace, "BGR")
})

# ── $log() ────────────────────────────────────────────────────────────────────

test_that("$log() takes natural log of each pixel", {
  result <- img_float(exp(1))$log()
  expect_equal(result$to_array()[1, 1, 1], 1.0, tolerance = 1e-5)
})

test_that("$log() errors on integer-depth image", {
  expect_error(make_test_image()$log(), "CV_32F")
})

test_that("$log_() modifies self in place", {
  img <- img_float(exp(1))
  img$log_()
  expect_equal(img$to_array()[1, 1, 1], 1.0, tolerance = 1e-5)
})

test_that("$log() preserves colorspace", {
  img <- img_float(exp(1), nchan = 3L, cs = "BGR")
  expect_equal(img$log()$colorspace, "BGR")
})

# ── $sqrt() ───────────────────────────────────────────────────────────────────

test_that("$sqrt() takes square root of each pixel", {
  result <- img_float(9.0)$sqrt()
  expect_equal(result$to_array()[1, 1, 1], 3.0, tolerance = 1e-5)
})

test_that("$sqrt() errors on integer-depth image", {
  expect_error(make_test_image()$sqrt(), "CV_32F")
})

test_that("$sqrt_() modifies self in place", {
  img <- img_float(9.0)
  img$sqrt_()
  expect_equal(img$to_array()[1, 1, 1], 3.0, tolerance = 1e-5)
})

test_that("$sqrt() preserves colorspace", {
  img <- img_float(4.0, nchan = 3L, cs = "BGR")
  expect_equal(img$sqrt()$colorspace, "BGR")
})

test_that("math methods preserve CV_64F depth", {
  arr <- array(4.0, dim = c(10L, 10L, 1L))
  img64 <- Image$new(arr, colorspace = "GRAY", depth = "CV_64F")
  expect_equal(img64$pow(2.0)$depth_name, "CV_64F")
  expect_equal(img64$exp()$depth_name, "CV_64F")
  expect_equal(img64$log()$depth_name, "CV_64F")
  expect_equal(img64$sqrt()$depth_name, "CV_64F")
})
