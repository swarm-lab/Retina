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
