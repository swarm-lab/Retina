test_that("depth_name() translates all known codes", {
  expect_equal(depth_name(0L), "CV_8U")
  expect_equal(depth_name(1L), "CV_8S")
  expect_equal(depth_name(2L), "CV_16U")
  expect_equal(depth_name(3L), "CV_16S")
  expect_equal(depth_name(4L), "CV_32S")
  expect_equal(depth_name(5L), "CV_32F")
  expect_equal(depth_name(6L), "CV_64F")
  expect_equal(depth_name(7L), "CV_16F")
})

test_that("depth_name() errors on unknown codes", {
  expect_error(depth_name(-1L), "Unknown depth code")
  expect_error(depth_name(8L),  "Unknown depth code")
})

test_that("img$depth_name returns 'CV_8U' for a standard 8-bit image", {
  img <- make_test_image()
  expect_equal(img$depth_name, "CV_8U")
})
