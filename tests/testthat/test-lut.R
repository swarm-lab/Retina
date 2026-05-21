# ── $LUT() — CV_8U ────────────────────────────────────────────────────────────

test_that("$LUT() identity LUT leaves CV_8U image unchanged", {
  img <- make_test_image()  # B=100, G=150, R=200
  result <- img$LUT(0:255)
  expect_equal(result$to_array(), img$to_array())
})

test_that("$LUT() inversion LUT inverts CV_8U pixel values", {
  img <- make_test_image()  # B=100, G=150, R=200
  result <- img$LUT(as.integer(255:0))
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 155L)  # 255-100
  expect_equal(arr[1, 1, 2], 105L)  # 255-150
  expect_equal(arr[1, 1, 3],  55L)  # 255-200
})

test_that("$LUT() broadcast vector applies same LUT to all channels", {
  img <- make_test_image()  # all channels different
  result <- img$LUT(0:255)   # identity
  expect_equal(result$to_array(), img$to_array())
})

test_that("$LUT() per-channel matrix applies different LUT per channel", {
  img <- make_test_image()  # B=100, G=150, R=200
  lut_mat <- matrix(0L, nrow = 256L, ncol = 3L)
  lut_mat[, 1] <- 0:255              # identity for B
  lut_mat[, 2] <- as.integer(255:0)  # invert for G
  lut_mat[, 3] <- 0:255              # identity for R
  result <- img$LUT(lut_mat)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)  # B unchanged
  expect_equal(arr[1, 1, 2], 105L)  # G inverted: 255-150=105
  expect_equal(arr[1, 1, 3], 200L)  # R unchanged
})

test_that("$LUT() on single-channel CV_8U image", {
  arr <- array(100L, dim = c(10L, 10L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  result <- img$LUT(as.integer(255:0))
  expect_equal(result$to_array()[1, 1, 1], 155L)  # 255-100
})

# ── $LUT() — CV_16U ───────────────────────────────────────────────────────────

test_that("$LUT() identity LUT on CV_16U image leaves values unchanged", {
  arr <- array(1000L, dim = c(5L, 5L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_16U")
  result <- img$LUT(0:65535)
  expect_equal(result$to_array()[1, 1, 1], 1000L)
})

# ── $LUT() — in-place ─────────────────────────────────────────────────────────

test_that("$LUT_() modifies self in place", {
  img <- make_test_image()  # B=100
  img$LUT_(as.integer(255:0))
  expect_equal(img$to_array()[1, 1, 1], 155L)
})

# ── $LUT() — error handling ───────────────────────────────────────────────────

test_that("$LUT() errors on CV_32F image", {
  img <- Image$new(array(0.5, dim = c(5L, 5L, 1L)), colorspace = "GRAY", depth = "CV_32F")
  expect_error(img$LUT(0:255), "CV_8U")
})

test_that("$LUT() errors on wrong vector length for CV_8U", {
  expect_error(make_test_image()$LUT(0:100), "256")
})

test_that("$LUT() errors on wrong matrix nrow", {
  lut_mat <- matrix(0L, nrow = 100L, ncol = 3L)
  expect_error(make_test_image()$LUT(lut_mat), "256")
})

test_that("$LUT() errors on wrong matrix ncol", {
  lut_mat <- matrix(0L, nrow = 256L, ncol = 2L)  # wrong: img has 3 channels
  expect_error(make_test_image()$LUT(lut_mat), "nchan")
})

test_that("$LUT() preserves colorspace", {
  expect_equal(make_test_image()$LUT(0:255)$colorspace, "BGR")
})

# ── output depth assertions ───────────────────────────────────────────────────

test_that("$LUT() on CV_8U produces CV_8U output", {
  expect_equal(make_test_image()$LUT(0:255)$depth_name, "CV_8U")
})

test_that("$LUT() on CV_16U produces CV_16U output", {
  arr <- array(1000L, dim = c(5L, 5L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_16U")
  expect_equal(img$LUT(0:65535)$depth_name, "CV_16U")
})

# ── CV_16S ────────────────────────────────────────────────────────────────────

test_that("$LUT() identity on CV_16S: pixel 0 -> LUT index 32768 -> value 0, output CV_16U", {
  arr <- array(0L, dim = c(5L, 5L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_16S")
  # Identity-ish: map every index i -> i - 32768 clamped to 0, but simpler:
  # map index 32768 (= pixel 0) to value 100
  lut <- integer(65536L)
  lut[32768 + 1L] <- 100L  # 1-based: index 32768 (0-based) = lut[32769]
  result <- img$LUT(lut)
  expect_equal(result$depth_name, "CV_16U")
  expect_equal(result$to_array()[1, 1, 1], 100L)
})

# ── $hist_match() regression ──────────────────────────────────────────────────

test_that("$hist_match() still works after rt_lut signature update", {
  arr <- array(as.integer(rep(0:99, each = 1L)), dim = c(10L, 10L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  ref_hist <- img$hist(bins = 256L)
  result <- img$hist_match(ref_hist)
  expect_true(inherits(result, "Image"))
  expect_equal(result$depth_name, "CV_8U")
})
