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
  expect_error(autothreshold_value(bgr, "otsu"), "single-channel")
})

test_that("autothreshold_value() errors on unknown method", {
  img <- bimodal_gray_8u()
  expect_error(autothreshold_value(img, "bogus"), "method must be one of")
})

test_that("autothreshold_value() errors on non-Image input", {
  expect_error(autothreshold_value(matrix(1:9, 3, 3), "otsu"), "Image")
})

test_that("autothreshold_value() errors when bins < 2", {
  img <- bimodal_gray_8u()
  expect_error(autothreshold_value(img, "otsu", bins = 1L), "bins")
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
  expect_error(img$threshold_(Inf))
  expect_error(img$threshold_(NA_real_))
})

test_that("$threshold() errors on auto method with multi-channel image", {
  bgr <- make_test_image()
  expect_error(bgr$threshold("otsu"), "single-channel")
})

test_that("$threshold() errors on unknown type string", {
  img <- bimodal_gray_8u()
  expect_error(img$threshold(127, type = "bogus"))
})

test_that("$threshold() errors on non-finite thresh", {
  img <- bimodal_gray_8u()
  expect_error(img$threshold(Inf))
  expect_error(img$threshold(NA_real_))
})
