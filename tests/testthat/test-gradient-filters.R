img_uniform <- function() {
  arr <- array(100L, dim = c(10L, 10L, 3L))
  Image$new(arr, depth = "CV_8U")
}

# ── sobel ─────────────────────────────────────────────────────────────────────

test_that("sobel() on uniform image returns all-zero output", {
  result <- img_uniform()$sobel(1, 0)
  arr <- result$to_array()
  expect_true(all(arr == 0))
})

test_that("sobel() returns Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$sobel(1, 0)
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("sobel() default output depth is CV_32F", {
  result <- img_uniform()$sobel(1, 0)
  expect_equal(result$depth_name, "CV_32F")
})

test_that("sobel() with ddepth = CV_16S gives CV_16S output", {
  result <- img_uniform()$sobel(1, 0, ddepth = "CV_16S")
  expect_equal(result$depth_name, "CV_16S")
})

test_that("sobel_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$sobel_(1, 0)
  expect_identical(result, img)
  expect_equal(img$depth_name, "CV_32F")
})

test_that("sobel() throws for dx = 0 and dy = 0", {
  expect_snapshot(error = TRUE, img_uniform()$sobel(0, 0))
})

test_that("sobel() throws for even ksize", {
  expect_snapshot(error = TRUE, img_uniform()$sobel(1, 0, ksize = 4))
})

test_that("sobel() throws for unsupported ddepth", {
  expect_snapshot(error = TRUE, img_uniform()$sobel(1, 0, ddepth = "CV_8U"))
})

test_that("sobel() throws for non-positive scale", {
  expect_snapshot(error = TRUE, img_uniform()$sobel(1, 0, scale = -1))
})

test_that("sobel() throws for invalid border_type", {
  expect_snapshot(error = TRUE, img_uniform()$sobel(1, 0, border_type = "foo"))
})

test_that("sobel() with border_type = 'replicate' runs without error", {
  expect_no_error(img_uniform()$sobel(1, 0, border_type = "replicate"))
})

# ── laplacian ─────────────────────────────────────────────────────────────────

test_that("laplacian() on uniform image returns all-zero output", {
  result <- img_uniform()$laplacian()
  arr <- result$to_array()
  expect_true(all(arr == 0))
})

test_that("laplacian() returns Image with same dimensions and colorspace", {
  img <- img_uniform()
  result <- img$laplacian()
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("laplacian() default output depth is CV_32F", {
  result <- img_uniform()$laplacian()
  expect_equal(result$depth_name, "CV_32F")
})

test_that("laplacian() with ddepth = CV_16S gives CV_16S output", {
  result <- img_uniform()$laplacian(ddepth = "CV_16S")
  expect_equal(result$depth_name, "CV_16S")
})

test_that("laplacian_() modifies in place and returns self", {
  img <- img_uniform()
  result <- img$laplacian_()
  expect_identical(result, img)
  expect_equal(img$depth_name, "CV_32F")
})

test_that("laplacian() throws for even ksize", {
  expect_snapshot(error = TRUE, img_uniform()$laplacian(ksize = 4))
})

test_that("laplacian() throws for unsupported ddepth", {
  expect_snapshot(error = TRUE, img_uniform()$laplacian(ddepth = "CV_8U"))
})

test_that("laplacian() with border_type = 'reflect' runs without error", {
  expect_no_error(img_uniform()$laplacian(border_type = "reflect"))
})
