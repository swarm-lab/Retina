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
