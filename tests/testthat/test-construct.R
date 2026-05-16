test_that("zeros() returns correct dimensions, depth, colorspace, and all-zero pixels", {
  img <- zeros(3L, 4L, 3L, "CV_8U", "BGR")
  expect_equal(img$nrow, 3L)
  expect_equal(img$ncol, 4L)
  expect_equal(img$nchan, 3L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "BGR")
  expect_equal(img[1, 1], c(B = 0, G = 0, R = 0))
  expect_equal(img[3, 4], c(B = 0, G = 0, R = 0))
})

test_that("zeros() default arguments produce 1-channel CV_8U GRAY image", {
  img <- zeros(5L, 5L)
  expect_equal(img$nchan, 1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "GRAY")
})

test_that("ones() fills all pixels with value 1 (not depth maximum)", {
  img <- ones(2L, 2L, 1L, "CV_8U", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
  expect_equal(img[2, 2], c(Y = 1))
})

test_that("ones() works for CV_32F", {
  img <- ones(2L, 2L, 1L, "CV_32F", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
})

test_that("randu() values are within [low, high]", {
  img <- randu(100L, 100L, 1L, "CV_32F", "GRAY", low = 0, high = 1)
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 1)
  expect_equal(img$nrow, 100L)
  expect_equal(img$ncol, 100L)
})

test_that("randu() default range 0-255 for CV_8U", {
  img <- randu(50L, 50L)
  expect_equal(img$depth_name, "CV_8U")
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 255)
})

test_that("randn() produces a roughly normal distribution", {
  img <- randn(300L, 300L, 1L, "CV_32F", "GRAY", mean = 0, sd = 1)
  arr <- as.numeric(img$to_array())
  expect_lt(abs(mean(arr)), 0.1)
  expect_lt(abs(stats::sd(arr) - 1), 0.1)
})

test_that("zeros() errors on nrow < 1", {
  expect_error(zeros(0L, 4L), "nrow")
})

test_that("zeros() errors on nchan > 4", {
  expect_error(zeros(3L, 4L, nchan = 5L), "nchan")
})

test_that("zeros() errors on invalid depth", {
  expect_error(zeros(3L, 4L, depth = "CV_128U"), "depth")
})

test_that("randu() errors when low >= high", {
  expect_error(randu(3L, 3L, low = 5, high = 5), "low")
})

test_that("randn() errors when sd <= 0", {
  expect_error(randn(3L, 3L, sd = -1), "sd")
})
