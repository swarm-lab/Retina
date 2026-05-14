test_that("img$depth_name returns 'CV_8U' for a standard 8-bit image", {
  img <- make_test_image()
  expect_equal(img$depth_name, "CV_8U")
})
