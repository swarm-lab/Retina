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
