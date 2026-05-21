# Helper: 10×10 BGR CV_8U image with B=10, G=20, R=30
img_bgr3 <- function() {
  arr <- array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
               dim = c(10L, 10L, 3L))
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

# ── $extract_channel() ────────────────────────────────────────────────────────

test_that("$extract_channel() returns single-channel image", {
  expect_equal(img_bgr3()$extract_channel(1L)$nchan, 1L)
})

test_that("$extract_channel() k=1 returns first channel values (B=10)", {
  ch <- img_bgr3()$extract_channel(1L)
  expect_equal(ch$to_array()[1, 1, 1], 10L)
})

test_that("$extract_channel() k=2 returns second channel values (G=20)", {
  ch <- img_bgr3()$extract_channel(2L)
  expect_equal(ch$to_array()[1, 1, 1], 20L)
})

test_that("$extract_channel() k=3 returns third channel values (R=30)", {
  ch <- img_bgr3()$extract_channel(3L)
  expect_equal(ch$to_array()[1, 1, 1], 30L)
})

test_that("$extract_channel() matches split_channels() for each channel", {
  img <- img_bgr3()
  parts <- split_channels(img)
  for (k in 1:3) {
    expect_equal(img$extract_channel(k)$to_array(), parts[[k]]$to_array())
  }
})

test_that("$extract_channel() returns GRAY colorspace", {
  expect_equal(img_bgr3()$extract_channel(1L)$colorspace, "GRAY")
})

test_that("$extract_channel() errors on k = 0", {
  expect_error(img_bgr3()$extract_channel(0L), "nchan")
})

test_that("$extract_channel() errors on k > nchan", {
  expect_error(img_bgr3()$extract_channel(4L), "nchan")
})

# ── $insert_channel() / $insert_channel_() ────────────────────────────────────

make_single_ch <- function(val, nrow = 10L, ncol = 10L, depth = "CV_8U") {
  arr <- array(as.integer(val), dim = c(nrow, ncol, 1L))
  Image$new(arr, colorspace = "GRAY", depth = depth)
}

test_that("$insert_channel() extract-insert round-trip preserves pixel values", {
  img <- img_bgr3()
  ch1 <- img$extract_channel(1L)
  result <- img$insert_channel(ch1, 1L)
  expect_equal(result$to_array()[1, 1, 1], 10L)
})

test_that("$insert_channel() changes the correct channel", {
  img <- img_bgr3()
  new_ch <- make_single_ch(99L)
  result <- img$insert_channel(new_ch, 2L)
  arr <- result$to_array()
  expect_equal(arr[1, 1, 1], 10L)   # B unchanged
  expect_equal(arr[1, 1, 2], 99L)   # G replaced
  expect_equal(arr[1, 1, 3], 30L)   # R unchanged
})

test_that("$insert_channel() preserves self colorspace", {
  img <- img_bgr3()
  result <- img$insert_channel(make_single_ch(0L), 1L)
  expect_equal(result$colorspace, "BGR")
})

test_that("$insert_channel() does not modify self", {
  img <- img_bgr3()
  orig_arr <- img$to_array()
  img$insert_channel(make_single_ch(99L), 2L)
  expect_equal(img$to_array(), orig_arr)
})

test_that("$insert_channel_() modifies self in place", {
  img <- img_bgr3()
  img$insert_channel_(make_single_ch(99L), 2L)
  expect_equal(img$to_array()[1, 1, 2], 99L)
  expect_equal(img$to_array()[1, 1, 1], 10L)  # other channels unchanged
})

test_that("$insert_channel() errors if ch has multiple channels", {
  expect_error(img_bgr3()$insert_channel(img_bgr3(), 1L), "single-channel")
})

test_that("$insert_channel() errors if ch depth differs", {
  ch32f <- Image$new(array(1.0, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_32F")
  expect_error(img_bgr3()$insert_channel(ch32f, 1L), "depth")
})

test_that("$insert_channel() errors if ch dimensions differ", {
  small <- make_single_ch(0L, nrow = 5L, ncol = 5L)
  expect_error(img_bgr3()$insert_channel(small, 1L), "dimensions")
})

test_that("$insert_channel() errors on k = 0", {
  expect_error(img_bgr3()$insert_channel(make_single_ch(0L), 0L), "nchan")
})

test_that("$insert_channel() errors on k > nchan", {
  expect_error(img_bgr3()$insert_channel(make_single_ch(0L), 4L), "nchan")
})
