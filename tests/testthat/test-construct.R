test_that("Image$zeros() returns correct dimensions, depth, colorspace, and all-zero pixels", {
  img <- Image$zeros(3L, 4L, 3L, "CV_8U", "BGR")
  expect_equal(img$nrow, 3L)
  expect_equal(img$ncol, 4L)
  expect_equal(img$nchan, 3L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "BGR")
  expect_equal(img[1, 1], c(B = 0, G = 0, R = 0))
  expect_equal(img[3, 4], c(B = 0, G = 0, R = 0))
})

test_that("Image$zeros() default arguments produce 1-channel CV_8U GRAY image", {
  img <- Image$zeros(5L, 5L)
  expect_equal(img$nchan, 1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "GRAY")
})

test_that("Image$ones() fills all pixels with value 1 (not depth maximum)", {
  img <- Image$ones(2L, 2L, 1L, "CV_8U", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
  expect_equal(img[2, 2], c(Y = 1))
})

test_that("Image$ones() works for CV_32F", {
  img <- Image$ones(2L, 2L, 1L, "CV_32F", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
})

test_that("Image$randu() values are within [low, high]", {
  img <- Image$randu(100L, 100L, 1L, "CV_32F", "GRAY", low = 0, high = 1)
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 1)
  expect_equal(img$nrow, 100L)
  expect_equal(img$ncol, 100L)
  expect_equal(img$nchan, 1L)
})

test_that("Image$randu() default range 0-255 for CV_8U", {
  img <- Image$randu(50L, 50L)
  expect_equal(img$depth_name, "CV_8U")
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 255)
})

test_that("Image$randn() produces a roughly normal distribution", {
  img <- Image$randn(300L, 300L, 1L, "CV_32F", "GRAY", mean = 0, sd = 1)
  arr <- as.numeric(img$to_array())
  expect_lt(abs(mean(arr)), 0.1)
  expect_lt(abs(stats::sd(arr) - 1), 0.1)
})

test_that("Image$zeros() errors on nrow < 1", {
  expect_error(Image$zeros(0L, 4L), "nrow must be a single positive integer")
})

test_that("Image$zeros() errors on nchan > 4", {
  expect_error(Image$zeros(3L, 4L, nchan = 5L), "nchan must be a single positive integer <= 4")
})

test_that("Image$zeros() errors on invalid depth", {
  expect_error(Image$zeros(3L, 4L, depth = "CV_128U"), "depth must be one of")
})

test_that("Image$randu() errors when low >= high", {
  expect_error(Image$randu(3L, 3L, low = 5, high = 5), "low must be strictly less than high")
})

test_that("Image$randn() errors when sd <= 0", {
  expect_error(Image$randn(3L, 3L, sd = -1), "sd must be a single positive finite numeric")
})

test_that("Image$ones() errors on invalid ncol", {
  expect_error(Image$ones(3L, 0L), "ncol must be a single positive integer")
})

test_that("Image$zeros() returns an Image object", {
  expect_s3_class(Image$zeros(2L, 2L), "Image")
})

test_that("Image$ones() returns an Image object", {
  expect_s3_class(Image$ones(2L, 2L), "Image")
})

test_that("Image$randu() returns an Image object and handles 3 channels", {
  img <- Image$randu(10L, 10L, 3L, "CV_8U", "BGR")
  expect_s3_class(img, "Image")
  expect_equal(img$nchan, 3L)
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 255)
})

test_that("Image$randn() returns an Image object and handles 3 channels", {
  img <- Image$randn(50L, 50L, 3L, "CV_8U", "BGR", mean = 128, sd = 20)
  expect_s3_class(img, "Image")
  expect_equal(img$nchan, 3L)
})

test_that("border() adds correct pixel counts on all sides", {
  img <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
  b <- img$border(top = 1L, bottom = 2L, left = 3L, right = 4L,
                  type = "constant", value = 255)
  expect_equal(b$nrow, 6L)   # 3 + 1 + 2
  expect_equal(b$ncol, 11L)  # 4 + 3 + 4
  expect_equal(b[1, 1], c(Y = 255))   # border pixel
  expect_equal(b[2, 4], c(Y = 0))     # interior pixel
})

test_that("border() symmetric shorthand: border(2) adds 2 on all sides", {
  img <- Image$zeros(3L, 3L, 1L, "CV_8U", "GRAY")
  b <- img$border(2L)
  expect_equal(b$nrow, 7L)
  expect_equal(b$ncol, 7L)
})

test_that("border() preserves colorspace", {
  img <- Image$zeros(3L, 3L, 3L, "CV_8U", "BGR")
  b <- img$border(1L)
  expect_equal(b$colorspace, "BGR")
  expect_s3_class(b, "Image")
})

test_that("border() constant value applies per channel", {
  img <- Image$zeros(2L, 2L, 3L, "CV_8U", "BGR")
  b <- img$border(1L, type = "constant", value = c(10, 20, 30))
  expect_equal(b[1, 1], c(B = 10, G = 20, R = 30))
})

test_that("border_() modifies in place and returns self invisibly", {
  img <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
  result <- img$border_(1L, type = "replicate")
  expect_identical(result, img)
  expect_equal(img$nrow, 5L)
  expect_equal(img$ncol, 6L)
})

test_that("border() errors on invalid type", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(1L, type = "invalid"),
               "type must be one of")
})

test_that("border() errors on negative width", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(-1L), "top must be a single non-negative integer")
})

test_that("border() errors on empty value vector", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(1L, value = numeric(0)),
               "value must be a non-empty numeric vector with no NAs")
})

test_that("border_() errors on invalid type", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border_(1L, type = "bad"),
               "type must be one of")
})

test_that("border() accepts 'default' as a valid type", {
  img <- Image$zeros(3L, 3L, 1L, "CV_8U", "GRAY")
  b <- img$border(1L, type = "default")
  expect_equal(b$nrow, 5L)
  expect_s3_class(b, "Image")
})
