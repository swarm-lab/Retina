# ── helpers ───────────────────────────────────────────────────────────────────

img_black <- function(nrow = 100L, ncol = 100L) {
  Image$new(array(0L, dim = c(nrow, ncol, 3L)),
            colorspace = "BGR", depth = "CV_8U")
}

img_black_gray <- function(nrow = 100L, ncol = 100L) {
  Image$new(array(0L, dim = c(nrow, ncol, 1L)),
            colorspace = "GRAY", depth = "CV_8U")
}

# ── col2bgr ───────────────────────────────────────────────────────────────────

test_that("col2bgr('red') returns c(B=0, G=0, R=255)", {
  expect_equal(col2bgr("red"), c(B = 0, G = 0, R = 255))
})

test_that("col2bgr('#0000FF') returns c(B=255, G=0, R=0)", {
  expect_equal(col2bgr("#0000FF"), c(B = 255, G = 0, R = 0))
})

test_that("col2bgr numeric passthrough returns named BGR vector", {
  expect_equal(col2bgr(c(10, 20, 30)), c(B = 10, G = 20, R = 30))
})

test_that("col2bgr with alpha=TRUE returns 4-element BGRA with A=255 for opaque color", {
  result <- col2bgr("red", alpha = TRUE)
  expect_length(result, 4L)
  expect_equal(result[["R"]], 255)
  expect_equal(result[["A"]], 255)
})

test_that("col2bgr numeric length-4 accepted regardless of alpha flag", {
  expect_equal(col2bgr(c(0, 128, 255, 200)), c(B = 0, G = 128, R = 255, A = 200))
})

test_that("col2bgr numeric wrong length errors", {
  expect_error(col2bgr(c(0, 0)), "must be a numeric vector of length")
})

test_that("col2bgr numeric out-of-range errors", {
  expect_error(col2bgr(c(0, 0, 300)), "must be in \\[0, 255\\]")
})
