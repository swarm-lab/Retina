make_img2 <- function() {
  arr <- array(0L, dim = c(10L, 10L, 3L))
  arr[,,1] <- 50L; arr[,,2] <- 50L; arr[,,3] <- 50L
  Image$new(arr, depth = "CV_8U")
}

# ── Image-image operations ───────────────────────────────────────────────────

test_that("add() image+image returns correct pixel values", {
  result <- make_test_image()$add(make_img2())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 150L)  # B: 100+50
  expect_equal(arr[1, 1, 2], 200L)  # G: 150+50
  expect_equal(arr[1, 1, 3], 250L)  # R: 200+50
})

test_that("subtract() image-image returns correct pixel values", {
  result <- make_test_image()$subtract(make_img2())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 50L)   # B: 100-50
  expect_equal(arr[1, 1, 2], 100L)  # G: 150-50
  expect_equal(arr[1, 1, 3], 150L)  # R: 200-50
})

test_that("absdiff() returns absolute difference", {
  result <- make_test_image()$absdiff(make_img2())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 50L)
  expect_equal(arr[1, 1, 2], 100L)
  expect_equal(arr[1, 1, 3], 150L)
})

test_that("add_weighted() blends two images correctly", {
  result <- make_test_image()$add_weighted(make_img2(), 0.5, 0.5, 0)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 75L)   # B: 0.5*100 + 0.5*50
  expect_equal(arr[1, 1, 2], 100L)  # G: 0.5*150 + 0.5*50
  expect_equal(arr[1, 1, 3], 125L)  # R: 0.5*200 + 0.5*50
})

test_that("bitwise_and() with self returns identical values", {
  img <- make_test_image()
  result <- img$bitwise_and(img$copy())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)
  expect_equal(arr[1, 1, 2], 150L)
  expect_equal(arr[1, 1, 3], 200L)
})

test_that("bitwise_not() inverts all bits", {
  result <- make_test_image()$bitwise_not()
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 155L)  # ~100 = 255-100 = 155
  expect_equal(arr[1, 1, 2], 105L)  # ~150 = 255-150 = 105
  expect_equal(arr[1, 1, 3], 55L)   # ~200 = 255-200 = 55
})

# ── Scalar operations ────────────────────────────────────────────────────────

test_that("add() with single scalar adds to all channels", {
  result <- make_test_image()$add(10)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 110L)
  expect_equal(arr[1, 1, 2], 160L)
  expect_equal(arr[1, 1, 3], 210L)
})

test_that("subtract() with single scalar subtracts from all channels", {
  result <- make_test_image()$subtract(10)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 90L)
  expect_equal(arr[1, 1, 2], 140L)
  expect_equal(arr[1, 1, 3], 190L)
})

test_that("add() with per-channel scalar adds to each channel independently", {
  result <- make_test_image()$add(c(0, 0, 55))
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 100L)  # B unchanged
  expect_equal(arr[1, 1, 2], 150L)  # G unchanged
  expect_equal(arr[1, 1, 3], 255L)  # R: 200+55 = 255
})

# ── Operators ────────────────────────────────────────────────────────────────

test_that("+ operator gives same result as add()", {
  img1 <- make_test_image()
  img2 <- make_img2()
  expect_equal((img1 + img2)$to_array(), img1$add(img2)$to_array())
})

test_that("+ operator works with scalar", {
  img <- make_test_image()
  expect_equal((img + 10)$to_array(), img$add(10)$to_array())
})

test_that("- operator gives same result as subtract()", {
  img1 <- make_test_image()
  img2 <- make_img2()
  expect_equal((img1 - img2)$to_array(), img1$subtract(img2)$to_array())
})

test_that("* operator gives same result as multiply()", {
  img1 <- make_test_image()
  img2 <- make_img2()
  expect_equal((img1 * img2)$to_array(), img1$multiply(img2)$to_array())
})

test_that("/ operator gives same result as divide()", {
  img1 <- make_test_image()
  img2 <- make_img2()
  expect_equal((img1 / img2)$to_array(), img1$divide(img2)$to_array())
})

# ── Bitwise S3 dispatch ──────────────────────────────────────────────────────

test_that("bitwAnd() dispatches to bitwise_and() for Image", {
  img <- make_test_image()
  expect_equal(bitwAnd(img, img$copy())$to_array(), img$bitwise_and(img$copy())$to_array())
})

test_that("bitwNot() dispatches to bitwise_not() for Image", {
  img <- make_test_image()
  expect_equal(bitwNot(img)$to_array(), img$bitwise_not()$to_array())
})

test_that("bitwAnd() still works for integers", {
  expect_equal(bitwAnd(12L, 10L), bitwAnd(12L, 10L))
})

# ── In-place operations ──────────────────────────────────────────────────────

test_that("add_() modifies in place and returns self", {
  img <- make_test_image()
  result <- img$add_(make_img2())
  expect_identical(result, img)
  expect_equal(img$to_array()[1, 1, 1], 150L)
})

test_that("bitwise_not_() modifies in place and returns self", {
  img <- make_test_image()
  result <- img$bitwise_not_()
  expect_identical(result, img)
  expect_equal(img$to_array()[1, 1, 1], 155L)
})

# ── Error handling ───────────────────────────────────────────────────────────

test_that("add() throws for non-Image non-numeric other", {
  img <- make_test_image()
  expect_snapshot(error = TRUE, img$add("foo"))
})

test_that("add() throws for wrong-length scalar", {
  img <- make_test_image()  # nchan = 3
  expect_snapshot(error = TRUE, img$add(c(1, 2)))
})

test_that("add_weighted() throws for non-scalar w1", {
  img <- make_test_image()
  expect_snapshot(error = TRUE, {
    img$add_weighted(make_img2(), c(0.5, 0.5), 0.5, 0)
  })
})
