# make_test_image() is defined in helper-images.R:
#   10x10 BGR image, all pixels = (B=100, G=150, R=200)

test_that("convert_color BGR->GRAY returns 1-channel image with colorspace GRAY", {
  img <- make_test_image()
  gray <- img$convert_color("BGR", "GRAY")
  expect_equal(gray$nchan, 1L)
  expect_equal(gray$colorspace, "GRAY")
})

test_that("convert_color_ modifies in place and returns self", {
  img <- make_test_image()
  result <- img$convert_color_("BGR", "GRAY")
  expect_identical(result, img)
  expect_equal(img$nchan, 1L)
  expect_equal(img$colorspace, "GRAY")
})

test_that("to_gray() matches convert_color(BGR, GRAY)", {
  img <- make_test_image()
  gray1 <- img$convert_color("BGR", "GRAY")
  gray2 <- img$to_gray()
  expect_equal(gray1$to_array(), gray2$to_array())
})

test_that("to_bgr() on GRAY image returns 3-channel BGR", {
  img <- make_test_image()$to_gray()
  bgr <- img$to_bgr()
  expect_equal(bgr$nchan, 3L)
  expect_equal(bgr$colorspace, "BGR")
})

test_that("to_gray_ modifies in place and returns self", {
  img <- make_test_image()
  result <- img$to_gray_()
  expect_identical(result, img)
  expect_equal(img$nchan, 1L)
  expect_equal(img$colorspace, "GRAY")
})

test_that("to_bgr_ modifies in place and returns self", {
  img <- make_test_image()$to_gray()
  result <- img$to_bgr_()
  expect_identical(result, img)
  expect_equal(img$nchan, 3L)
  expect_equal(img$colorspace, "BGR")
})

test_that("to_hsv() returns 3-channel image with colorspace HSV", {
  img <- make_test_image()
  hsv <- img$to_hsv()
  expect_equal(hsv$nchan, 3L)
  expect_equal(hsv$colorspace, "HSV")
})

test_that("to_lab() returns 3-channel image with colorspace LAB", {
  img <- make_test_image()
  lab <- img$to_lab()
  expect_equal(lab$nchan, 3L)
  expect_equal(lab$colorspace, "LAB")
})

test_that("to_hsv_ modifies in place and returns self", {
  img <- make_test_image()
  result <- img$to_hsv_()
  expect_identical(result, img)
  expect_equal(img$nchan, 3L)
  expect_equal(img$colorspace, "HSV")
})

test_that("to_lab_ modifies in place and returns self", {
  img <- make_test_image()
  result <- img$to_lab_()
  expect_identical(result, img)
  expect_equal(img$nchan, 3L)
  expect_equal(img$colorspace, "LAB")
})

test_that("round-trip BGR->HSV->BGR pixel values within tolerance 2", {
  img <- make_test_image()
  arr_orig <- img$to_array()
  arr_rt   <- img$to_hsv()$to_bgr()$to_array()
  expect_true(all(abs(as.integer(arr_orig) - as.integer(arr_rt)) <= 2L))
})

test_that("convert_color with unsupported pair throws informative error", {
  img <- make_test_image()
  expect_error(img$convert_color("BGR", "XYZ"), "unsupported color space conversion")
})
