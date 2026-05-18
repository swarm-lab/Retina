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

# ── draw_rectangle ────────────────────────────────────────────────────────────

test_that("draw_rectangle() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_rectangle(10, 10, 90, 90, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_rectangle() filled=TRUE sets center pixel to fill color", {
  img    <- img_black()
  result <- img$draw_rectangle(10, 10, 90, 90, color = c(0, 255, 0), filled = TRUE)
  arr    <- result$to_array()
  # center pixel (row=50, col=50): BGR green = (0, 255, 0)
  expect_equal(arr[50, 50, 1], 0)
  expect_equal(arr[50, 50, 2], 255)
  expect_equal(arr[50, 50, 3], 0)
})

test_that("draw_rectangle_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_rectangle(10, 10, 90, 90, color = "white")
  result   <- img$draw_rectangle_(10, 10, 90, 90, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_rectangle() errors on negative thickness", {
  expect_error(
    img_black()$draw_rectangle(10, 10, 90, 90, color = "red", thickness = -1L),
    "thickness must be a single positive integer"
  )
})

# ── draw_circle ───────────────────────────────────────────────────────────────

test_that("draw_circle() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_circle(50, 50, 30, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_circle() filled=TRUE sets center pixel to fill color", {
  img    <- img_black()
  result <- img$draw_circle(50, 50, 30, color = c(255, 0, 0), filled = TRUE)
  arr    <- result$to_array()
  # center pixel (row=50, col=50): BGR blue = (255, 0, 0)
  expect_equal(arr[50, 50, 1], 255)
  expect_equal(arr[50, 50, 2], 0)
  expect_equal(arr[50, 50, 3], 0)
})

test_that("draw_circle_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_circle(50, 50, 20, color = "white")
  result   <- img$draw_circle_(50, 50, 20, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_circle() errors on negative radius", {
  expect_error(img_black()$draw_circle(50, 50, -1L, color = "red"),
               "radius must be a single non-negative integer")
})

# ── draw_ellipse ──────────────────────────────────────────────────────────────

test_that("draw_ellipse() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_ellipse(50, 50, 30L, 20L, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_ellipse() filled=TRUE sets center pixel to fill color", {
  img    <- img_black()
  result <- img$draw_ellipse(50, 50, 30L, 20L,
                             color = c(0, 255, 0), filled = TRUE)
  arr    <- result$to_array()
  expect_equal(arr[50, 50, 2], 255)  # green channel
})

test_that("draw_ellipse_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_ellipse(50, 50, 30L, 20L, color = "white")
  result   <- img$draw_ellipse_(50, 50, 30L, 20L, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_ellipse() errors on rx < 1", {
  expect_error(img_black()$draw_ellipse(50, 50, 0L, 20L, color = "red"),
               "rx and ry must be single positive integers")
})

# ── draw_arc ──────────────────────────────────────────────────────────────────

test_that("draw_arc() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_arc(50, 50, 30L, 20L, start_angle = 0, end_angle = 180,
                         color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_arc() changes at least one pixel", {
  img    <- img_black()
  result <- img$draw_arc(50, 50, 30L, 20L, start_angle = 0, end_angle = 180,
                         color = "white")
  expect_false(all(result$to_array() == img$to_array()))
})

test_that("draw_arc_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_arc(50, 50, 30L, 20L, start_angle = 0, end_angle = 90,
                           color = "white")
  result   <- img$draw_arc_(50, 50, 30L, 20L, start_angle = 0, end_angle = 90,
                            color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

# ── draw_polyline ─────────────────────────────────────────────────────────────

test_that("draw_polyline() returns Image with same dimensions and colorspace", {
  img  <- img_black()
  pts  <- matrix(c(10, 50, 90, 50, 90, 90), nrow = 3L, ncol = 2L, byrow = TRUE)
  result <- img$draw_polyline(pts, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_polyline() changes at least one pixel", {
  img  <- img_black()
  pts  <- matrix(c(10, 50, 90, 50, 90, 90), nrow = 3L, ncol = 2L, byrow = TRUE)
  result <- img$draw_polyline(pts, color = "white")
  expect_false(all(result$to_array() == img$to_array()))
})

test_that("draw_polyline_() modifies in place and returns self", {
  img      <- img_black()
  pts      <- matrix(c(10, 50, 90, 50, 90, 90), nrow = 3L, ncol = 2L, byrow = TRUE)
  expected <- img$draw_polyline(pts, color = "white")
  result   <- img$draw_polyline_(pts, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_polyline() errors on non-matrix pts", {
  expect_error(img_black()$draw_polyline(c(1, 2, 3, 4), color = "red"),
               "pts must be a numeric matrix")
})

test_that("draw_polyline() errors on pts with wrong ncol", {
  expect_error(img_black()$draw_polyline(matrix(1:9, nrow = 3, ncol = 3), color = "red"),
               "pts must have exactly 2 columns")
})

test_that("draw_polyline() errors on pts with fewer than 2 rows", {
  pts <- matrix(c(10, 50), nrow = 1L, ncol = 2L)
  expect_error(img_black()$draw_polyline(pts, color = "red"),
               "pts must have at least 2 rows")
})

# ── fill_poly ─────────────────────────────────────────────────────────────────

test_that("fill_poly() sets interior pixel to fill color", {
  img  <- img_black()
  # large triangle with center near (50, 50)
  pts  <- matrix(c(10, 10,  90, 10,  50, 90), nrow = 3L, ncol = 2L, byrow = TRUE)
  result <- img$fill_poly(pts, color = c(0, 255, 0))
  arr    <- result$to_array()
  # (row=30, col=50) is well inside the triangle
  expect_equal(arr[30, 50, 2], 255)
})

test_that("fill_poly_() modifies in place and returns self", {
  img      <- img_black()
  pts      <- matrix(c(10, 10, 90, 10, 50, 90), nrow = 3L, ncol = 2L, byrow = TRUE)
  expected <- img$fill_poly(pts, color = "white")
  result   <- img$fill_poly_(pts, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("fill_poly() errors on pts with fewer than 3 rows", {
  pts <- matrix(c(10, 10, 90, 10), nrow = 2L, ncol = 2L)
  expect_error(img_black()$fill_poly(pts, color = "red"),
               "pts must have at least 3 rows")
})

# ── draw_text ─────────────────────────────────────────────────────────────────

test_that("draw_text() returns Image with same dimensions and colorspace", {
  img    <- img_black()
  result <- img$draw_text("Hello", 10, 50, color = "white")
  expect_s3_class(result, "Image")
  expect_equal(result$nrow,       img$nrow)
  expect_equal(result$ncol,       img$ncol)
  expect_equal(result$colorspace, img$colorspace)
})

test_that("draw_text() changes at least one pixel", {
  img    <- img_black()
  result <- img$draw_text("Hello", 10, 50, color = "white")
  expect_false(all(result$to_array() == img$to_array()))
})

test_that("draw_text_() modifies in place and returns self", {
  img      <- img_black()
  expected <- img$draw_text("Hi", 10, 50, color = "white")
  result   <- img$draw_text_("Hi", 10, 50, color = "white")
  expect_identical(result, img)
  expect_equal(img$to_array(), expected$to_array())
})

test_that("draw_text() errors on invalid font", {
  expect_error(img_black()$draw_text("x", 10, 50, color = "red",
                                     font = "arial"),
               "font must be one of")
})

test_that("draw_text() errors on invalid line_type", {
  expect_error(img_black()$draw_text("x", 10, 50, color = "red",
                                     line_type = "dashed"),
               "line_type must be one of")
})
