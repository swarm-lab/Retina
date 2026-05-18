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

# ── draw_line ─────────────────────────────────────────────────────────────────

test_that("draw_line() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_line(10, 10, 90, 10, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_line() horizontal line sets interior pixel to line color", {
  img    <- img_black()
  result <- img$draw_line(10, 50, 90, 50, color = c(0, 0, 255),
                          line_type = "line_8")
  arr    <- result$to_array()
  # row=50, col=50 (interior of horizontal line) must be red (BGR: 0,0,255)
  expect_equal(arr[50, 50, 1], 0)
  expect_equal(arr[50, 50, 2], 0)
  expect_equal(arr[50, 50, 3], 255)
})

test_that("draw_line_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_line(10, 10, 90, 10, color = "white")
  result   <- img$draw_line_(10, 10, 90, 10, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_line() errors on invalid thickness", {
  expect_error(img_black()$draw_line(1, 1, 10, 10, color = "red", thickness = 0L),
               "thickness must be a single positive integer")
})

test_that("draw_line() errors on invalid line_type", {
  expect_error(img_black()$draw_line(1, 1, 10, 10, color = "red", line_type = "solid"),
               "line_type must be one of")
})

# ── draw_arrow ────────────────────────────────────────────────────────────────

test_that("draw_arrow() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_arrow(10, 50, 90, 50, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_arrow() changes at least one pixel", {
  img    <- img_black()
  result <- img$draw_arrow(10, 50, 90, 50, color = "white")
  expect_false(all(result$to_array() == img$to_array()))
})

test_that("draw_arrow_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_arrow(10, 50, 90, 50, color = "white")
  result   <- img$draw_arrow_(10, 50, 90, 50, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})
