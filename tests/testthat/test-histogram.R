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

# ── $hist_eq() / $hist_eq_() ──────────────────────────────────────────────────

test_that("hist_eq() returns a CV_8U single-channel Image", {
  img <- img_gray_flat(128L)
  out <- img$hist_eq()
  expect_s3_class(out, "Image")
  expect_equal(out$depth_name, "CV_8U")
  expect_equal(out$nchan, 1L)
  expect_equal(out$colorspace, img$colorspace)
  expect_equal(out$nrow, img$nrow)
  expect_equal(out$ncol, img$ncol)
})

test_that("hist_eq() does not modify self", {
  img  <- img_gray_flat(128L)
  orig <- img$to_array()
  img$hist_eq()
  expect_equal(img$to_array(), orig)
})

test_that("hist_eq_() modifies self and returns self", {
  img    <- img_gray_flat(50L)
  result <- img$hist_eq_()
  expect_identical(result, img)
})

test_that("hist_eq() throws for multi-channel image", {
  expect_snapshot(error = TRUE, img_bgr_flat()$hist_eq())
})

test_that("hist_eq() throws for non-CV_8U depth", {
  img <- Image$new(array(100L, dim = c(10L, 10L, 1L)),
                   colorspace = "GRAY", depth = "CV_16U")
  expect_snapshot(error = TRUE, img$hist_eq())
})

# ── $hist_match() / $hist_match_() ───────────────────────────────────────────

# Build a known reference histogram: all pixels at value 200
img_ref_flat <- function() {
  Image$new(array(200L, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_8U")
}

test_that("hist_match() output histogram approximates reference", {
  src <- img_gray_flat(50L)   # all pixels = 50
  ref <- img_ref_flat()       # all pixels = 200
  ref_hist <- ref$hist(bins = 256L, range = c(0, 256))
  out <- src$hist_match(ref_hist)
  expect_s3_class(out, "Image")
  # After matching to a histogram concentrated at 200, output should be ~200
  expect_true(mean(out$to_array()) > 190)
})

test_that("hist_match() does not modify self", {
  src      <- img_gray_flat(50L)
  ref_hist <- img_ref_flat()$hist(bins = 256L, range = c(0, 255))
  orig     <- src$to_array()
  src$hist_match(ref_hist)
  expect_equal(src$to_array(), orig)
})

test_that("hist_match_() modifies self and returns self", {
  src      <- img_gray_flat(50L)
  ref_hist <- img_ref_flat()$hist(bins = 256L, range = c(0, 255))
  result   <- src$hist_match_(ref_hist)
  expect_identical(result, src)
})

test_that("hist_match() throws for multi-channel image", {
  ref_hist <- img_ref_flat()$hist(bins = 256L, range = c(0, 255))
  expect_snapshot(error = TRUE, img_bgr_flat()$hist_match(ref_hist))
})

test_that("hist_match() throws for non-CV_8U image", {
  img <- Image$new(array(100L, dim = c(10L, 10L, 1L)),
                   colorspace = "GRAY", depth = "CV_16U")
  ref_hist <- img_ref_flat()$hist(bins = 256L, range = c(0, 255))
  expect_snapshot(error = TRUE, img$hist_match(ref_hist))
})

test_that("hist_match() throws for ref without required columns", {
  bad_ref <- data.frame(x = 1:256, y = 1:256)
  expect_snapshot(error = TRUE, img_gray_flat()$hist_match(bad_ref))
})

test_that("hist_match() throws for ref with wrong number of rows", {
  bad_ref <- img_ref_flat()$hist(bins = 64L, range = c(0, 255))
  expect_snapshot(error = TRUE, img_gray_flat()$hist_match(bad_ref))
})

test_that("hist_match() throws for ref with negative counts", {
  ref_hist <- img_ref_flat()$hist(bins = 256L, range = c(0, 255))
  ref_hist$count[1] <- -1
  expect_snapshot(error = TRUE, img_gray_flat()$hist_match(ref_hist))
})

# ── $CLAHE() / $CLAHE_() ──────────────────────────────────────────────────────

test_that("CLAHE() returns an Image with same dimensions and colorspace", {
  img <- img_gray_flat()
  out <- img$CLAHE()
  expect_s3_class(out, "Image")
  expect_equal(out$nrow, img$nrow)
  expect_equal(out$ncol, img$ncol)
  expect_equal(out$nchan, 1L)
  expect_equal(out$depth_name, "CV_8U")
  expect_equal(out$colorspace, img$colorspace)
})

test_that("CLAHE() does not modify self", {
  img  <- img_gray_flat()
  orig <- img$to_array()
  img$CLAHE()
  expect_equal(img$to_array(), orig)
})

test_that("CLAHE_() modifies self and returns self", {
  img    <- img_gray_flat()
  result <- img$CLAHE_()
  expect_identical(result, img)
})

test_that("CLAHE() accepts scalar tile_grid_size (square tiles)", {
  img <- img_gray_flat()
  expect_s3_class(img$CLAHE(tile_grid_size = 4L), "Image")
})

test_that("CLAHE() accepts length-2 tile_grid_size", {
  img <- img_gray_flat()
  expect_s3_class(img$CLAHE(tile_grid_size = c(4L, 8L)), "Image")
})

test_that("CLAHE() works on CV_16U single-channel image", {
  img <- Image$new(array(1000L, dim = c(10L, 10L, 1L)),
                   colorspace = "GRAY", depth = "CV_16U")
  expect_s3_class(img$CLAHE(), "Image")
})

test_that("CLAHE() throws for multi-channel image", {
  expect_snapshot(error = TRUE, img_bgr_flat()$CLAHE())
})

test_that("CLAHE() throws for non-CV_8U/CV_16U depth", {
  img <- Image$new(array(0.5, dim = c(10L, 10L, 1L)),
                   colorspace = "GRAY", depth = "CV_32F")
  expect_snapshot(error = TRUE, img$CLAHE())
})

test_that("CLAHE() throws for non-positive clip_limit", {
  expect_snapshot(error = TRUE, img_gray_flat()$CLAHE(clip_limit = 0))
})

test_that("CLAHE() throws for invalid tile_grid_size", {
  expect_snapshot(error = TRUE, img_gray_flat()$CLAHE(tile_grid_size = 0L))
})
