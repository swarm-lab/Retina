test_that("Image$new() from a file path works", {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f))
  # Write a small PNG using base R to avoid circular dependency on Retina's write
  png(f, width = 8, height = 6)
  par(mar = c(0, 0, 0, 0))
  plot.new()
  dev.off()
  expect_no_error(img <- Image$new(f))
  expect_s3_class(img, "Image")
})

test_that("Image properties return correct values", {
  img <- make_test_image()
  expect_equal(img$nrow,  10L)
  expect_equal(img$ncol,  10L)
  expect_equal(img$nchan,  3L)
  expect_equal(img$colorspace, "BGR")
  expect_false(img$gpu)
})

test_that("copy() produces an independent deep copy", {
  img1 <- make_test_image()
  img2 <- img1$copy()

  expect_false(identical(img1, img2))
  expect_equal(img1$nrow,  img2$nrow)
  expect_equal(img1$ncol,  img2$ncol)
  expect_equal(img1$nchan, img2$nchan)

  img2$colorspace <- "RGB"
  expect_equal(img1$colorspace, "BGR")
  expect_equal(img2$colorspace, "RGB")
})

test_that("assignment does NOT copy (reference semantics)", {
  img1 <- make_test_image()
  img2 <- img1
  img2$colorspace <- "RGB"
  expect_equal(img1$colorspace, "RGB")
})

test_that("dim() returns c(nrow, ncol, nchan)", {
  img <- make_test_image()
  expect_equal(dim(img), c(10L, 10L, 3L))
})

test_that("nrow() and ncol() work via dim()", {
  img <- Image$new(array(0L, dim = c(6L, 4L, 3L)), depth = "CV_8U")
  expect_equal(nrow(img), 6L)
  expect_equal(ncol(img), 4L)
})

test_that("to_array() recovers original pixel values from array-constructed image", {
  arr <- array(0L, dim = c(10L, 10L, 3L))
  arr[,,1] <- 100L; arr[,,2] <- 150L; arr[,,3] <- 200L
  img <- Image$new(arr, depth = "CV_8U")
  result <- img$to_array()
  expect_equal(dim(result), c(10L, 10L, 3L))
  expect_equal(result[1, 1, 1], 100L)
  expect_equal(result[1, 1, 2], 150L)
  expect_equal(result[1, 1, 3], 200L)
})

test_that("to_gpu() and to_cpu() toggle gpu property", {
  skip_if_not(Retina:::.rt_caps$cuda, "No CUDA-capable GPU available")
  img <- make_test_image()
  expect_false(img$gpu)
  img$to_gpu()
  expect_true(img$gpu)
  img$to_cpu()
  expect_false(img$gpu)
})

test_that("to_gpu() returns self invisibly for chaining", {
  skip_if_not(Retina:::.rt_caps$cuda, "No CUDA-capable GPU available")
  img <- make_test_image()
  result <- img$to_gpu()
  expect_identical(result, img)
})

# ── Depth support ─────────────────────────────────────────────────────────────

test_that("Image$new() with integer array emits depth message when depth not set", {
  expect_message(
    Image$new(array(100L, dim = c(5L, 5L, 3L))),
    "Depth not specified. Defaulting to CV_8U."
  )
})

test_that("Image$new() with integer array and explicit CV_8U emits no message", {
  expect_no_message(
    Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  )
})

test_that("Image$new() with integer array and CV_16S gives correct depth", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_16S")
  expect_equal(img$depth_name, "CV_16S")
})

test_that("Image$new() with double array emits depth message when depth not set", {
  expect_message(
    Image$new(array(0.5, dim = c(5L, 5L, 3L))),
    "Depth not specified. Defaulting to CV_32F."
  )
})

test_that("Image$new() with double array and explicit CV_64F gives correct depth", {
  img <- Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_64F")
  expect_equal(img$depth_name, "CV_64F")
})

test_that("Image$new() throws for integer array with float depth", {
  expect_error(
    Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_32F"),
    "use a double array for float depths"
  )
})

test_that("Image$new() throws for double array with integer depth", {
  expect_error(
    Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_8U"),
    "use an integer array for integer depths"
  )
})

test_that("Image$new() throws for unsupported depth string", {
  expect_error(
    Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_99X"),
    "depth must be one of"
  )
})

test_that("to_array() returns integer array for CV_16S with correct values", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_16S")
  arr <- img$to_array()
  expect_type(arr, "integer")
  expect_equal(arr[1, 1, 1], 100L)
})

test_that("to_array() returns double array for CV_32F with correct values", {
  img <- Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_32F")
  arr <- img$to_array()
  expect_type(arr, "double")
  expect_equal(arr[1, 1, 1], 0.5, tolerance = 1e-6)
})

test_that("to_array() returns double array for CV_64F with correct values", {
  img <- Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_64F")
  arr <- img$to_array()
  expect_type(arr, "double")
  expect_equal(arr[1, 1, 1], 0.5, tolerance = 1e-15)
})

test_that("plot() works without error for CV_32F image", {
  img <- Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_32F")
  expect_no_error(img$plot())
})

test_that("convert_depth() returns new Image with target depth", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  result <- img$convert_depth("CV_32F")
  expect_s3_class(result, "Image")
  expect_equal(result$depth_name, "CV_32F")
  expect_false(identical(result, img))
})

test_that("convert_depth_() modifies in place and returns self", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  result <- img$convert_depth_("CV_32F")
  expect_identical(result, img)
  expect_equal(img$depth_name, "CV_32F")
})

test_that("convert_depth() throws for unsupported depth", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  expect_error(img$convert_depth("CV_99X"), "depth must be one of")
})

test_that("add() throws for images with different depths", {
  img_8u  <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  img_16s <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_16S")
  expect_error(img_8u$add(img_16s), "images must have the same depth")
})

test_that("bilateral_filter() throws for non-CV_8U/CV_32F image", {
  img <- Image$new(array(100L, dim = c(10L, 10L, 3L)), depth = "CV_16S")
  expect_error(img$bilateral_filter(9, 75, 75),
               "bilateral_filter requires a CV_8U or CV_32F image")
})

test_that("to_array() round-trips negative values for CV_16S", {
  arr <- array(-100L, dim = c(5L, 5L, 3L))
  img <- Image$new(arr, depth = "CV_16S")
  result <- img$to_array()
  expect_type(result, "integer")
  expect_equal(result[1, 1, 1], -100L)
})

test_that("convert_depth() preserves pixel values without scaling", {
  img <- Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_8U")
  result <- img$convert_depth("CV_32F")
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100.0, tolerance = 1e-6)
})
