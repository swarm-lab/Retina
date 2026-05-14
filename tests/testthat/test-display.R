test_that("rt_image_to_native_raster() returns correct nativeRaster dimensions", {
  img <- make_test_image()
  nr <- Retina:::rt_image_to_native_raster(img$.__enclos_env__$private$.ptr)
  expect_true(inherits(nr, "nativeRaster"))
  expect_equal(dim(nr), c(10L, 10L))
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
