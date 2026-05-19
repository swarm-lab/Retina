# ── fixtures ──────────────────────────────────────────────────────────────────

bimodal_gray_8u <- function() {
  arr <- array(c(rep(50L, 50L), rep(200L, 50L)), dim = c(10L, 10L, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

bimodal_gray_32f <- function() {
  arr <- array(c(rep(0.2, 50), rep(0.8, 50)), dim = c(10L, 10L, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_32F")
}

# ── autothreshold_value() ─────────────────────────────────────────────────────

test_that("autothreshold_value('otsu') returns value between the two levels", {
  val <- autothreshold_value(bimodal_gray_8u(), "otsu")
  expect_true(is.numeric(val) && length(val) == 1L)
  expect_gte(val, 50)
  expect_lt(val, 200)
})

test_that("all 17 methods return a numeric scalar on bimodal CV_8U gray", {
  img <- bimodal_gray_8u()
  methods <- c("imagej","huang","huang2","intermodes","isodata","li",
                "maxentropy","mean","minerrori","minimum","moments","otsu",
                "percentile","renyientropy","shanbhag","triangle","yen")
  for (m in methods) {
    val <- autothreshold_value(img, m)
    expect_true(is.numeric(val) && length(val) == 1L,
                label = paste0("method=", m))
  }
})

test_that("autothreshold_value() on CV_32F bimodal returns value in [0.2, 0.8]", {
  val <- autothreshold_value(bimodal_gray_32f(), "otsu", bins = 256L)
  expect_gt(val, 0.19)
  expect_lt(val, 0.81)
})

test_that("autothreshold_value() errors on multi-channel image", {
  bgr <- make_test_image()
  expect_snapshot(error = TRUE, autothreshold_value(bgr, "otsu"))
})

test_that("autothreshold_value() errors on unknown method", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, autothreshold_value(img, "bogus"))
})

test_that("autothreshold_value() errors on non-Image input", {
  expect_snapshot(error = TRUE, autothreshold_value(matrix(1:9, 3, 3), "otsu"))
})

test_that("autothreshold_value() errors when bins < 2", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, autothreshold_value(img, "otsu", bins = 1L))
})

# ── $threshold() ──────────────────────────────────────────────────────────────

test_that("$threshold(127, type='binary') separates two levels", {
  img <- bimodal_gray_8u()
  result <- img$threshold(127)
  arr <- result$to_array()
  expect_equal(sort(unique(as.integer(arr))), c(0L, 255L))
  # pixels that were 50 -> 0, pixels that were 200 -> 255
  expect_equal(sum(arr == 0),   50L)
  expect_equal(sum(arr == 255), 50L)
})

test_that("$threshold(127, type='binary_inv') inverts binary result", {
  img <- bimodal_gray_8u()
  result <- img$threshold(127, type = "binary_inv")
  arr <- result$to_array()
  expect_equal(sum(arr == 255), 50L) # pixels that were 50 -> 255
  expect_equal(sum(arr == 0),   50L) # pixels that were 200 -> 0
})

test_that("$threshold(127, type='trunc') clips above-threshold pixels", {
  img <- bimodal_gray_8u()
  result <- img$threshold(127, type = "trunc")
  arr <- result$to_array()
  expect_equal(sort(unique(as.integer(arr))), c(50L, 127L))
})

test_that("$threshold(127, type='tozero') zeros below-threshold pixels", {
  img <- bimodal_gray_8u()
  result <- img$threshold(127, type = "tozero")
  arr <- result$to_array()
  expect_equal(sort(unique(as.integer(arr))), c(0L, 200L))
})

test_that("$threshold(127, type='tozero_inv') zeros above-threshold pixels", {
  img <- bimodal_gray_8u()
  result <- img$threshold(127, type = "tozero_inv")
  arr <- result$to_array()
  expect_equal(sort(unique(as.integer(arr))), c(0L, 50L))
})

test_that("$threshold('otsu') on bimodal CV_8U gives binary output", {
  img <- bimodal_gray_8u()
  result <- img$threshold("otsu")
  arr <- result$to_array()
  expect_equal(sort(unique(as.integer(arr))), c(0L, 255L))
})

test_that("$threshold('otsu') on bimodal CV_32F gives binary-like output", {
  img <- bimodal_gray_32f()
  result <- img$threshold("otsu", maxval = 1.0)
  arr <- result$to_array()
  vals <- sort(unique(round(as.numeric(arr), 6)))
  expect_length(vals, 2L)
  expect_equal(vals[1], 0)
  expect_equal(vals[2], 1)
})

test_that("$threshold() returns a new Image (non-mutating)", {
  img    <- bimodal_gray_8u()
  before <- img$to_array()
  result <- img$threshold(127)
  expect_false(identical(result, img))
  expect_equal(img$to_array(), before)
})

test_that("$threshold_() modifies in place and returns self", {
  img <- bimodal_gray_8u()
  result <- img$threshold_(127)
  expect_identical(result, img)
  expect_equal(sort(unique(as.integer(img$to_array()))), c(0L, 255L))
})

test_that("$threshold_() errors on non-finite thresh", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$threshold_(Inf))
  expect_snapshot(error = TRUE, img$threshold_(NA_real_))
})

test_that("$threshold() errors on auto method with multi-channel image", {
  bgr <- make_test_image()
  expect_snapshot(error = TRUE, bgr$threshold("otsu"))
})

test_that("$threshold() errors on unknown type string", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$threshold(127, type = "bogus"))
})

test_that("$threshold() errors on non-finite thresh", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$threshold(Inf))
  expect_snapshot(error = TRUE, img$threshold(NA_real_))
})

# ── $adaptive_threshold() ────────────────────────────────────────────────────

test_that("$adaptive_threshold() default args return single-channel CV_8U", {
  img <- bimodal_gray_8u()
  result <- img$adaptive_threshold()
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$nchan,      1L)
  expect_equal(result$depth_name, "CV_8U")
  expect_equal(result$colorspace, "GRAY")
})

test_that("$adaptive_threshold() output pixels are only 0 or 255", {
  img <- bimodal_gray_8u()
  arr <- img$adaptive_threshold()$to_array()
  expect_true(all(arr == 0L | arr == 255L))
})

test_that("$adaptive_threshold(method='gaussian') produces valid output", {
  img <- bimodal_gray_8u()
  result <- img$adaptive_threshold(method = "gaussian")
  arr <- result$to_array()
  expect_true(all(arr == 0L | arr == 255L))
})

test_that("$adaptive_threshold(type='binary_inv') flips relative to 'binary'", {
  img <- bimodal_gray_8u()
  a_bin     <- img$adaptive_threshold(type = "binary")$to_array()
  a_bin_inv <- img$adaptive_threshold(type = "binary_inv")$to_array()
  expect_true(all((a_bin == 0L & a_bin_inv == 255L) | (a_bin == 255L & a_bin_inv == 0L)))
})

test_that("$adaptive_threshold_() modifies in place and returns self", {
  img <- bimodal_gray_8u()
  result <- img$adaptive_threshold_()
  expect_identical(result, img)
  expect_equal(img$nchan,      1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "GRAY")
})

test_that("$adaptive_threshold() errors on multi-channel image", {
  bgr <- make_test_image()
  expect_snapshot(error = TRUE, bgr$adaptive_threshold())
})

test_that("$adaptive_threshold() errors on non-CV_8U image", {
  img <- bimodal_gray_32f()
  expect_snapshot(error = TRUE, img$adaptive_threshold())
})

test_that("$adaptive_threshold() errors when block_size is even", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$adaptive_threshold(block_size = 10L))
})

test_that("$adaptive_threshold() errors when block_size < 3", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$adaptive_threshold(block_size = 1L))
})

test_that("$adaptive_threshold() errors on non-finite offset", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$adaptive_threshold(offset = Inf))
})

# ── $in_range() ───────────────────────────────────────────────────────────────

test_that("$in_range() output is single-channel CV_8U GRAY", {
  img <- bimodal_gray_8u()
  result <- img$in_range(40, 100)
  expect_equal(result$nchan,      1L)
  expect_equal(result$depth_name, "CV_8U")
  expect_equal(result$colorspace, "GRAY")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
})

test_that("$in_range() marks in-range pixels as 255, others as 0", {
  img <- bimodal_gray_8u()  # 50 pixels at 50, 50 pixels at 200
  result <- img$in_range(40, 100)
  arr <- result$to_array()
  expect_equal(sum(arr == 255L), 50L) # pixels at 50 are in [40, 100]
  expect_equal(sum(arr == 0L),   50L) # pixels at 200 are not
})

test_that("$in_range() per-channel bounds on BGR image", {
  bgr <- make_test_image()  # all pixels (B=100, G=150, R=200)
  # range that includes B and G but excludes R
  result <- bgr$in_range(lower = c(90, 140, 210), upper = c(110, 160, 220))
  arr <- result$to_array()
  expect_equal(sum(arr == 255L), 0L)  # R=200 is outside [210, 220]
  result2 <- bgr$in_range(lower = c(90, 140, 190), upper = c(110, 160, 210))
  arr2 <- result2$to_array()
  expect_equal(sum(arr2 == 255L), 100L)  # all pixels in range
})

test_that("$in_range() scalar bounds are recycled to nchan", {
  bgr <- make_test_image()  # B=100, G=150, R=200
  # scalar that covers only B channel (90-110) — G and R are outside
  result <- bgr$in_range(90, 110)
  arr <- result$to_array()
  expect_equal(sum(arr == 255L), 0L)  # G=150 and R=200 outside [90, 110]
})

test_that("$in_range_() modifies in place and returns self", {
  img <- bimodal_gray_8u()
  result <- img$in_range_(40, 100)
  expect_identical(result, img)
  expect_equal(img$nchan,      1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "GRAY")
})

test_that("$in_range() errors when lower > upper for any channel", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$in_range(200, 100))
})

test_that("$in_range() errors when lower/upper length is not 1 or nchan", {
  bgr <- make_test_image()  # nchan = 3
  expect_snapshot(error = TRUE, bgr$in_range(c(0, 0), c(255, 255, 255)))
})

test_that("$in_range() errors on NA in lower or upper", {
  img <- bimodal_gray_8u()
  expect_snapshot(error = TRUE, img$in_range(NA_real_, 200))
  expect_snapshot(error = TRUE, img$in_range(0, NA_real_))
})
