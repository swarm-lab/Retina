test_that("rt_image_to_native_raster() returns correct nativeRaster dimensions", {
  img <- make_test_image()
  nr <- Retina:::rt_image_to_native_raster(img$.__enclos_env__$private$.ptr)
  expect_true(inherits(nr, "nativeRaster"))
  expect_equal(dim(nr), c(10L, 10L))
})

test_that("rt_image_to_native_raster() preserves orientation (non-square)", {
  # 6 rows x 4 cols; top-left pixel is red (0,0,255 in BGR)
  arr <- array(0L, dim = c(6L, 4L, 3L))
  arr[1, 1, 3] <- 255L  # R channel — red pixel at [row=1, col=1]
  img <- Image$new(arr)
  nr <- Retina:::rt_image_to_native_raster(img$.__enclos_env__$private$.ptr)
  expect_equal(dim(nr), c(6L, 4L))  # height x width, not transposed
  # Top-left pixel in nativeRaster (offset 0) must be red (0xFFFF0000)
  expect_equal(nr[1L], -65536L)  # 0xFFFF0000 as signed int
})

test_that("plot() renders without error", {
  img <- make_test_image()
  f <- tempfile(fileext = ".pdf")
  on.exit({
    dev.off()
    unlink(f)
  })
  pdf(f)
  expect_no_error(img$plot())
})

test_that("plot() returns self invisibly", {
  img <- make_test_image()
  f <- tempfile(fileext = ".pdf")
  on.exit({
    dev.off()
    unlink(f)
  })
  pdf(f)
  result <- img$plot()
  expect_identical(result, img)
})

test_that("display() renders without error", {
  img <- make_test_image()
  f <- tempfile(fileext = ".pdf")
  on.exit({
    dev.off()
    unlink(f)
  })
  pdf(f)
  expect_no_error(display(img))
})
