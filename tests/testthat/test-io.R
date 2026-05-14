test_that("write() saves a PNG and read() reloads it correctly", {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f))

  original <- make_test_image()
  original$write(f)

  expect_true(file.exists(f))

  reloaded <- Image$new(f)
  expect_equal(reloaded$nrow,  original$nrow)
  expect_equal(reloaded$ncol,  original$ncol)
  expect_equal(reloaded$nchan, original$nchan)
})

test_that("write() returns self invisibly for chaining", {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f))
  img <- make_test_image()
  result <- img$write(f)
  expect_identical(result, img)
})
