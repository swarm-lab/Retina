img_uniform <- function() {
  arr <- array(100L, dim = c(10L, 10L, 3L))
  Image$new(arr, depth = "CV_8U")
}

img_impulse <- function() {
  arr <- array(0L, dim = c(10L, 10L, 3L))
  arr[5, 5, ] <- 255L
  Image$new(arr, depth = "CV_8U")
}

# ── filter2D ──────────────────────────────────────────────────────────────────

test_that("filter2D() with identity kernel returns unchanged pixel values", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img_uniform()$filter2D(k)
  expect_equal(result$to_array()[5, 5, 1], 100L)
})

test_that("filter2D() with box kernel matches blur() on impulse image", {
  k <- matrix(rep(1 / 9, 9), nrow = 3L)
  result <- img_impulse()$filter2D(k)
  blur_result <- img_impulse()$blur(c(3L, 3L))
  expect_equal(result$to_array()[5, 5, 1], blur_result$to_array()[5, 5, 1])
})

test_that("filter2D() ddepth = NULL preserves input depth", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img_uniform()$filter2D(k)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("filter2D() explicit ddepth changes output depth", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img_uniform()$filter2D(k, ddepth = "CV_32F")
  expect_equal(result$depth_name, "CV_32F")
})

test_that("filter2D() delta shifts output pixel values", {
  img <- Image$new(array(0L, dim = c(10L, 10L, 1L)), depth = "CV_8U")
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img$filter2D(k, delta = 50)
  expect_equal(result$to_array()[5, 5, 1], 50L)
})

test_that("filter2D() returns Image with same dimensions and colorspace", {
  img <- img_uniform()
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img$filter2D(k)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("filter2D_() modifies in place and returns self", {
  img <- img_uniform()
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  result <- img$filter2D_(k)
  expect_identical(result, img)
  expect_equal(img$to_array()[5, 5, 1], 100L)
})

test_that("filter2D() throws for non-matrix kernel", {
  expect_snapshot(error = TRUE, img_uniform()$filter2D(c(0, 0, 0, 0, 1, 0, 0, 0, 0)))
})

test_that("filter2D() throws for kernel with NA", {
  k <- matrix(c(0, 0, 0, NA, 1, 0, 0, 0, 0), nrow = 3L)
  expect_snapshot(error = TRUE, img_uniform()$filter2D(k))
})

test_that("filter2D() throws for out-of-bounds anchor", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  expect_snapshot(error = TRUE, img_uniform()$filter2D(k, anchor = c(5L, 1L)))
})

test_that("filter2D() throws for invalid border_type", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  expect_snapshot(error = TRUE, img_uniform()$filter2D(k, border_type = "invalid"))
})

test_that("filter2D() throws for invalid ddepth", {
  k <- matrix(c(0, 0, 0, 0, 1, 0, 0, 0, 0), nrow = 3L)
  expect_snapshot(error = TRUE, img_uniform()$filter2D(k, ddepth = "CV_99"))
})

# ── sep_filter2D ──────────────────────────────────────────────────────────────

test_that("sep_filter2D() box kernels match blur() on uniform image", {
  result <- img_uniform()$sep_filter2D(rep(1 / 3, 3), rep(1 / 3, 3))
  blur_result <- img_uniform()$blur(c(3L, 3L))
  expect_equal(result$to_array()[5, 5, 1], blur_result$to_array()[5, 5, 1])
})

test_that("sep_filter2D() ddepth = NULL preserves input depth", {
  result <- img_uniform()$sep_filter2D(rep(1 / 3, 3), rep(1 / 3, 3))
  expect_equal(result$depth_name, "CV_8U")
})

test_that("sep_filter2D() returns Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$sep_filter2D(rep(1 / 3, 3), rep(1 / 3, 3))
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("sep_filter2D_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$sep_filter2D_(rep(1 / 3, 3), rep(1 / 3, 3))
  expect_identical(result, img)
})

test_that("sep_filter2D() throws for non-numeric kernel_x", {
  expect_snapshot(error = TRUE, img_uniform()$sep_filter2D("a", rep(1 / 3, 3)))
})

test_that("sep_filter2D() throws for kernel_y with NA", {
  expect_snapshot(error = TRUE,
    img_uniform()$sep_filter2D(rep(1 / 3, 3), c(1 / 3, NA_real_, 1 / 3)))
})

test_that("sep_filter2D() throws for out-of-bounds anchor", {
  expect_snapshot(error = TRUE,
    img_uniform()$sep_filter2D(rep(1 / 3, 3), rep(1 / 3, 3), anchor = c(5L, 1L)))
})
