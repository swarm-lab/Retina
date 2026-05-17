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
