img_bgr <- function() {
  arr <- array(rep(1L:100L, 3L), dim = c(10L, 10L, 3L))
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

# ── resize ────────────────────────────────────────────────────────────────────

test_that("resize(width=20, height=5) produces 20x5 image", {
  result <- img_bgr()$resize(width = 20L, height = 5L)
  expect_equal(result$ncol, 20L)
  expect_equal(result$nrow, 5L)
})

test_that("resize(fx=2, fy=0.5) produces 20x5 image", {
  result <- img_bgr()$resize(fx = 2, fy = 0.5)
  expect_equal(result$ncol, 20L)
  expect_equal(result$nrow, 5L)
})

test_that("resize errors if both dimensions and scale supplied", {
  expect_error(img_bgr()$resize(width = 5L, height = 5L, fx = 2, fy = 2),
               "supply either width/height or fx/fy, not both")
})

test_that("resize errors if neither supplied", {
  expect_error(img_bgr()$resize(),
               "supply either width/height or fx/fy")
})

test_that("resize errors on non-positive width", {
  expect_error(img_bgr()$resize(width = 0L, height = 5L),
               "width and height must be single positive integers")
})

test_that("resize preserves colorspace", {
  expect_equal(img_bgr()$resize(fx = 2, fy = 2)$colorspace, "BGR")
})

# ── rotate ────────────────────────────────────────────────────────────────────

test_that("rotate(90) preserves dimensions", {
  result <- img_bgr()$rotate(90)
  expect_equal(result$ncol, 10L)
  expect_equal(result$nrow, 10L)
})

test_that("rotate with explicit cx/cy runs without error", {
  expect_no_error(img_bgr()$rotate(45, cx = 5, cy = 5))
})

test_that("rotate preserves colorspace", {
  expect_equal(img_bgr()$rotate(90)$colorspace, "BGR")
})

# ── flip ──────────────────────────────────────────────────────────────────────

test_that("flip(flip_h=TRUE) reverses columns", {
  img <- img_bgr()
  result <- img$flip(flip_h = TRUE)
  arr_orig <- img$to_array()
  arr_flip <- result$to_array()
  expect_equal(arr_flip[, 1L, ], arr_orig[, 10L, ])
  expect_equal(arr_flip[, 10L, ], arr_orig[, 1L, ])
})

test_that("flip(flip_v=TRUE) reverses rows", {
  img <- img_bgr()
  result <- img$flip(flip_v = TRUE)
  arr_orig <- img$to_array()
  arr_flip <- result$to_array()
  expect_equal(arr_flip[1L, , ], arr_orig[10L, , ])
  expect_equal(arr_flip[10L, , ], arr_orig[1L, , ])
})

test_that("flip(flip_h=TRUE, flip_v=TRUE) reverses both", {
  img <- img_bgr()
  result <- img$flip(flip_h = TRUE, flip_v = TRUE)
  arr_orig <- img$to_array()
  arr_flip <- result$to_array()
  expect_equal(arr_flip[1L, 1L, ], arr_orig[10L, 10L, ])
})

test_that("flip errors when both FALSE", {
  expect_error(img_bgr()$flip(),
               "at least one of flip_h or flip_v must be TRUE")
})

test_that("flip preserves colorspace", {
  expect_equal(img_bgr()$flip(flip_h = TRUE)$colorspace, "BGR")
})

# ── crop ──────────────────────────────────────────────────────────────────────

test_that("crop(1,1,5,5) produces 5x5 image", {
  result <- img_bgr()$crop(1L, 1L, 5L, 5L)
  expect_equal(result$ncol, 5L)
  expect_equal(result$nrow, 5L)
})

test_that("crop(1,1,10,10) on 10x10 image recovers original", {
  img <- img_bgr()
  result <- img$crop(1L, 1L, 10L, 10L)
  expect_equal(result$to_array(), img$to_array())
})

test_that("crop errors on out-of-bounds coordinates", {
  expect_error(img_bgr()$crop(1L, 1L, 11L, 5L),
               "crop coordinates exceed image dimensions")
})

test_that("crop errors when x1 >= x2", {
  expect_error(img_bgr()$crop(5L, 1L, 5L, 10L),
               "x1 must be less than x2")
})

test_that("crop preserves colorspace", {
  expect_equal(img_bgr()$crop(1L, 1L, 5L, 5L)$colorspace, "BGR")
})

# ── in-place ──────────────────────────────────────────────────────────────────

test_that("resize_() modifies image in place", {
  img <- img_bgr()
  expected <- img$resize(fx = 2, fy = 2)
  img$resize_(fx = 2, fy = 2)
  expect_equal(img$ncol, expected$ncol)
  expect_equal(img$nrow, expected$nrow)
})
