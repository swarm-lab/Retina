# tests/testthat/test-histogram.R

# ── helpers ───────────────────────────────────────────────────────────────────

img_gray_flat <- function(val = 100L) {
  Image$new(array(val, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_8U")
}

img_bgr_flat <- function() {
  Image$new(array(100L, dim = c(10L, 10L, 3L)), depth = "CV_8U")
}

# ── $hist() ───────────────────────────────────────────────────────────────────

test_that("hist() returns a data frame with correct columns", {
  h <- img_gray_flat()$hist(bins = 256L, range = c(0, 256))
  expect_s3_class(h, "data.frame")
  expect_named(h, c("bin_center", "channel", "count"))
})

test_that("hist() returns bins * nchan rows", {
  h_gray <- img_gray_flat()$hist(bins = 64L, range = c(0, 255))
  expect_equal(nrow(h_gray), 64L)

  h_bgr <- img_bgr_flat()$hist(bins = 32L, range = c(0, 255))
  expect_equal(nrow(h_bgr), 96L)  # 32 * 3
})

test_that("hist() bin_center values are correct", {
  h <- img_gray_flat()$hist(bins = 4L, range = c(0, 256))
  # bin_width = 256/4 = 64; centers = 32, 96, 160, 224
  expected <- c(0 + 0.5 * (256 / 4),
                0 + 1.5 * (256 / 4),
                0 + 2.5 * (256 / 4),
                0 + 3.5 * (256 / 4))
  expect_equal(h$bin_center, expected)
})

test_that("hist() counts sum to nrow * ncol", {
  img <- img_gray_flat()
  h <- img$hist(bins = 256L, range = c(0, 256))
  expect_equal(sum(h$count), img$nrow * img$ncol)
})

test_that("hist() all pixels in correct bin for uniform image", {
  # All pixels = 100; bin 100 should have all 100 counts, others 0
  h <- img_gray_flat(100L)$hist(bins = 256L, range = c(0, 255))
  # bin_width = 255/256; bin containing 100 has index floor(100 / (255/256)) = 100
  expect_equal(h$count[101], 100)   # 1-based index 101 = bin index 100 (0-based)
  expect_equal(sum(h$count[h$count != h$count[101]]), 0)
})

test_that("hist() channel names match colorspace", {
  h <- img_bgr_flat()$hist(bins = 8L, range = c(0, 255))
  expect_equal(sort(unique(h$channel)), c("B", "G", "R"))
})

test_that("hist() freq = FALSE: counts sum to ~1 per channel", {
  # range c(0, 256) -> bin_width = 1; integral = sum(density * 1) = sum(density)
  h <- img_gray_flat()$hist(bins = 256L, range = c(0, 256), freq = FALSE)
  expect_equal(sum(h$count), 1, tolerance = 1e-6)
})

test_that("hist() emits message when range = NULL", {
  expect_message(img_gray_flat()$hist(), "range not specified")
})

test_that("hist() throws for bins < 1", {
  expect_snapshot(error = TRUE, img_gray_flat()$hist(bins = 0L, range = c(0, 255)))
})

test_that("hist() throws for invalid range", {
  expect_snapshot(error = TRUE, img_gray_flat()$hist(bins = 8L, range = c(100, 50)))
})

test_that("hist() throws for non-logical freq", {
  expect_snapshot(error = TRUE, img_gray_flat()$hist(bins = 8L, range = c(0, 255), freq = "yes"))
})
