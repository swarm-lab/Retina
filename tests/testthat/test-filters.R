img_uniform <- function() {
  arr <- array(100L, dim = c(10L, 10L, 3L))
  Image$new(arr, depth = "CV_8U")
}

img_impulse <- function() {
  arr <- array(0L, dim = c(10L, 10L, 3L))
  arr[5, 5, ] <- 255L
  Image$new(arr, depth = "CV_8U")
}

# ── blur ─────────────────────────────────────────────────────────────────────

test_that("blur() on uniform image returns unchanged pixel values", {
  result <- img_uniform()$blur(c(3, 3))
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)
  expect_equal(arr[1, 1, 2], 100L)
  expect_equal(arr[1, 1, 3], 100L)
})

test_that("blur() on impulse image averages correctly at center", {
  result <- img_impulse()$blur(c(3, 3))
  arr <- result$to_array()
  expect_equal(arr[5, 5, 1], 28L)  # floor(255/9) = 28
})

test_that("blur() returns an Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$blur(c(3, 3))
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("blur_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$blur_(c(3, 3))
  expect_identical(result, img)
  expect_equal(img$to_array()[1, 1, 1], 100L)
})

test_that("blur() throws for non-length-2 ksize", {
  expect_snapshot(error = TRUE, img_uniform()$blur(5))
})

test_that("blur() throws for non-positive ksize", {
  expect_snapshot(error = TRUE, img_uniform()$blur(c(-1, 3)))
})

# ── gaussian_blur ─────────────────────────────────────────────────────────────

test_that("gaussian_blur() on uniform image returns unchanged pixel values", {
  result <- img_uniform()$gaussian_blur(c(0, 0), 1.5)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)
})

test_that("gaussian_blur() returns an Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$gaussian_blur(c(0, 0), 1.5)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("gaussian_blur_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$gaussian_blur_(c(0, 0), 1.5)
  expect_identical(result, img)
})

test_that("gaussian_blur() throws for even ksize element", {
  expect_snapshot(error = TRUE, img_uniform()$gaussian_blur(c(3, 4), 1.5))
})

test_that("gaussian_blur() throws for wrong-length sigma", {
  expect_snapshot(error = TRUE, img_uniform()$gaussian_blur(c(3, 3), c(1, 2, 3)))
})

test_that("gaussian_blur() throws for non-positive sigma", {
  expect_snapshot(error = TRUE, img_uniform()$gaussian_blur(c(3, 3), -1))
})

# ── median_blur ───────────────────────────────────────────────────────────────

test_that("median_blur() on impulse image zeroes center pixel", {
  result <- img_impulse()$median_blur(3)
  arr <- result$to_array()
  expect_equal(arr[5, 5, 1], 0L)  # median of 1x255 + 8x0 = 0
})

test_that("median_blur() on uniform image returns unchanged pixel values", {
  result <- img_uniform()$median_blur(3)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)
})

test_that("median_blur() returns an Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$median_blur(3)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("median_blur_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$median_blur_(3)
  expect_identical(result, img)
})

test_that("median_blur() throws for even ksize", {
  expect_snapshot(error = TRUE, img_uniform()$median_blur(4))
})

test_that("median_blur() throws for length-2 ksize", {
  expect_snapshot(error = TRUE, img_uniform()$median_blur(c(3, 3)))
})

# ── bilateral_filter ──────────────────────────────────────────────────────────

test_that("bilateral_filter() on uniform image returns unchanged pixel values", {
  result <- img_uniform()$bilateral_filter(5, 75, 75)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)
})

test_that("bilateral_filter() returns an Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$bilateral_filter(5, 75, 75)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("bilateral_filter_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$bilateral_filter_(5, 75, 75)
  expect_identical(result, img)
})

test_that("bilateral_filter() throws for non-scalar d", {
  expect_snapshot(error = TRUE, img_uniform()$bilateral_filter(c(5, 5), 75, 75))
})

test_that("bilateral_filter() throws for non-positive sigma_color", {
  expect_snapshot(error = TRUE, img_uniform()$bilateral_filter(5, -1, 75))
})
