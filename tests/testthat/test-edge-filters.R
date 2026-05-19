img_gray_uniform <- function() {
  arr <- array(100L, dim = c(10L, 10L, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

# ── canny ─────────────────────────────────────────────────────────────────────

test_that("canny() on uniform grayscale image returns all-zero output", {
  result <- img_gray_uniform()$canny(10, 50)
  arr <- result$to_array()
  expect_true(all(arr == 0L))
})

test_that("canny() output is single-channel CV_8U", {
  result <- img_gray_uniform()$canny(10, 50)
  expect_equal(result$nchan, 1L)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("canny() returns Image with same nrow and ncol", {
  img <- img_gray_uniform()
  result <- img$canny(10, 50)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
})

test_that("canny_() modifies in place and returns self", {
  img <- img_gray_uniform()
  result <- img$canny_(10, 50)
  expect_identical(result, img)
  expect_equal(img$depth_name, "CV_8U")
})

test_that("canny() throws for multi-channel image", {
  img <- Image$new(array(100L, dim = c(10L, 10L, 3L)), depth = "CV_8U")
  expect_snapshot(error = TRUE, img$canny(10, 50))
})

test_that("canny() throws for negative low_threshold", {
  expect_snapshot(error = TRUE, img_gray_uniform()$canny(-1, 50))
})

test_that("canny() accepts zero low_threshold", {
  expect_no_error(img_gray_uniform()$canny(0, 50))
})

test_that("canny() throws for non-positive high_threshold", {
  expect_snapshot(error = TRUE, img_gray_uniform()$canny(10, -1))
})

test_that("canny() throws when low_threshold > high_threshold", {
  expect_snapshot(error = TRUE, img_gray_uniform()$canny(100, 50))
})

test_that("canny() throws for invalid aperture_size", {
  expect_snapshot(error = TRUE, img_gray_uniform()$canny(10, 50, aperture_size = 4))
})

test_that("canny() throws for non-logical L2_gradient", {
  expect_snapshot(error = TRUE, img_gray_uniform()$canny(10, 50, L2_gradient = "yes"))
})
