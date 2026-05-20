# ── helpers ───────────────────────────────────────────────────────────────────

make_all_ones_mask <- function(nrow = 10L, ncol = 10L) {
  arr <- array(255L, dim = c(nrow, ncol, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

make_all_zeros_mask <- function(nrow = 10L, ncol = 10L) {
  arr <- array(0L, dim = c(nrow, ncol, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

# Left 5 columns = 255, right 5 columns = 0
make_half_mask <- function() {
  arr <- array(0L, dim = c(10L, 10L, 1L))
  arr[, 1:5, 1] <- 255L
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

# ── .rt_valid_mask() ──────────────────────────────────────────────────────────

test_that(".rt_valid_mask() is a no-op when mask is NULL", {
  img <- make_test_image()
  expect_null(.rt_valid_mask(NULL, img))
})

test_that(".rt_valid_mask() errors when mask is not an Image", {
  expect_error(.rt_valid_mask("bad", make_test_image()),
               "CV_8U")
})

test_that(".rt_valid_mask() errors when mask has multiple channels", {
  mask <- make_test_image()  # 3-channel BGR image
  expect_error(.rt_valid_mask(mask, make_test_image()), "CV_8U")
})

test_that(".rt_valid_mask() errors when mask depth is not CV_8U", {
  arr <- array(1L, dim = c(10L, 10L, 1L))
  mask <- Image$new(arr, colorspace = "GRAY", depth = "CV_16U")
  expect_error(.rt_valid_mask(mask, make_test_image()), "CV_8U")
})

test_that(".rt_valid_mask() errors when mask dimensions differ", {
  arr <- array(255L, dim = c(5L, 5L, 1L))
  mask <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  expect_error(.rt_valid_mask(mask, make_test_image()), "dimensions")
})

# ── $set_to() mask ────────────────────────────────────────────────────────────

test_that("$set_to() with all-ones mask sets all pixels", {
  img <- make_test_image()
  result_masked   <- img$set_to(0, make_all_ones_mask())
  result_unmasked <- img$set_to(0)
  expect_equal(result_masked$to_array(), result_unmasked$to_array())
})

test_that("$set_to() with all-zeros mask leaves image unchanged", {
  img <- make_test_image()
  result <- img$set_to(0, make_all_zeros_mask())
  expect_equal(result$to_array(), img$to_array())
})

test_that("$set_to() with partial mask updates only masked pixels", {
  img <- make_test_image()  # B=100 everywhere
  result <- img$set_to(0, make_half_mask())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  0L)   # col 1 (masked): set to 0
  expect_equal(arr[1, 10, 1], 100L) # col 10 (unmasked): unchanged
})

test_that("$set_to_() with mask modifies self in place", {
  img <- make_test_image()
  img$set_to_(0, make_all_ones_mask())
  expect_equal(img$to_array()[1, 1, 1], 0L)
})

test_that("$set_to() without mask still works after refactor", {
  img <- make_test_image()
  result <- img$set_to(0)
  expect_equal(result$to_array()[1, 1, 1], 0L)
})

# ── arithmetic mask helpers ───────────────────────────────────────────────────

# 10×10 BGR CV_8U image with all channels = 50
make_img_50 <- function() {
  arr <- array(50L, dim = c(10L, 10L, 3L))
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

# ── $add() mask ───────────────────────────────────────────────────────────────

test_that("$add() with all-ones mask equals unmasked add", {
  img <- make_test_image()
  other <- make_img_50()
  expect_equal(img$add(other, make_all_ones_mask())$to_array(),
               img$add(other)$to_array())
})

test_that("$add() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  result <- img$add(make_img_50(), make_all_zeros_mask())
  expect_equal(result$to_array(), img$to_array())
})

test_that("$add() with partial mask updates only masked pixels", {
  img <- make_test_image()  # B=100 everywhere
  result <- img$add(make_img_50(), make_half_mask())  # add B=50
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  150L)  # col 1 (masked): 100+50
  expect_equal(arr[1, 10, 1], 100L)  # col 10 (unmasked): unchanged
})

test_that("$add_() with mask modifies self in place", {
  img <- make_test_image()
  img$add_(make_img_50(), make_all_ones_mask())
  expect_equal(img$to_array()[1, 1, 1], 150L)
})

test_that("$add() with scalar and mask", {
  img <- make_test_image()
  result <- img$add(50, make_half_mask())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  150L)  # masked: added
  expect_equal(arr[1, 10, 1], 100L)  # unmasked: unchanged
})

# ── $subtract() mask ──────────────────────────────────────────────────────────

test_that("$subtract() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$subtract(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

test_that("$subtract() with partial mask updates only masked pixels", {
  img <- make_test_image()  # B=100
  result <- img$subtract(make_img_50(), make_half_mask())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  50L)   # masked: 100-50
  expect_equal(arr[1, 10, 1], 100L)  # unmasked: unchanged
})

# ── $multiply() mask ──────────────────────────────────────────────────────────

test_that("$multiply() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$multiply(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

# ── $divide() mask ────────────────────────────────────────────────────────────

test_that("$divide() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$divide(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

# ── $absdiff() mask ───────────────────────────────────────────────────────────

test_that("$absdiff() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$absdiff(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

test_that("$absdiff() with partial mask updates only masked pixels", {
  img <- make_test_image()  # B=100
  result <- img$absdiff(make_img_50(), make_half_mask())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  50L)   # masked: |100-50|=50
  expect_equal(arr[1, 10, 1], 100L)  # unmasked: unchanged
})

# ── $add_weighted() mask ──────────────────────────────────────────────────────

test_that("$add_weighted() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  result <- img$add_weighted(make_img_50(), 0.5, 0.5, 0, make_all_zeros_mask())
  expect_equal(result$to_array(), img$to_array())
})

test_that("$add_weighted() with all-ones mask equals unmasked", {
  img <- make_test_image()
  other <- make_img_50()
  expect_equal(
    img$add_weighted(other, 0.5, 0.5, 0, make_all_ones_mask())$to_array(),
    img$add_weighted(other, 0.5, 0.5, 0)$to_array()
  )
})

# ── $bitwise_and() mask ───────────────────────────────────────────────────────

test_that("$bitwise_and() with all-ones mask equals unmasked", {
  img <- make_test_image()
  expect_equal(img$bitwise_and(img$copy(), make_all_ones_mask())$to_array(),
               img$bitwise_and(img$copy())$to_array())
})

test_that("$bitwise_and() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$bitwise_and(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

# ── $bitwise_or() mask ────────────────────────────────────────────────────────

test_that("$bitwise_or() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$bitwise_or(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

# ── $bitwise_xor() mask ───────────────────────────────────────────────────────

test_that("$bitwise_xor() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$bitwise_xor(make_img_50(), make_all_zeros_mask())$to_array(),
               img$to_array())
})

# ── $bitwise_not() mask ───────────────────────────────────────────────────────

test_that("$bitwise_not() with all-ones mask equals unmasked", {
  img <- make_test_image()
  expect_equal(img$bitwise_not(make_all_ones_mask())$to_array(),
               img$bitwise_not()$to_array())
})

test_that("$bitwise_not() with all-zeros mask leaves self unchanged", {
  img <- make_test_image()
  expect_equal(img$bitwise_not(make_all_zeros_mask())$to_array(),
               img$to_array())
})

test_that("$bitwise_not() with partial mask inverts only masked pixels", {
  img <- make_test_image()  # B=100 everywhere
  result <- img$bitwise_not(make_half_mask())
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1],  155L)  # masked: ~100 = 155
  expect_equal(arr[1, 10, 1], 100L)  # unmasked: unchanged
})

test_that("$bitwise_not_() with mask modifies self in place", {
  img <- make_test_image()
  img$bitwise_not_(make_all_ones_mask())
  expect_equal(img$to_array()[1, 1, 1], 155L)
})

# ── mask validation propagates through arithmetic ─────────────────────────────

test_that("$add() with invalid mask errors", {
  expect_error(make_test_image()$add(make_img_50(), "bad"), "CV_8U")
})

test_that("$subtract() with wrong-size mask errors", {
  small_mask <- Image$new(array(255L, dim = c(5L, 5L, 1L)),
                          colorspace = "GRAY", depth = "CV_8U")
  expect_error(make_test_image()$subtract(make_img_50(), small_mask), "dimensions")
})
