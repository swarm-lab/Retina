img_bgr <- function() {
  arr <- array(c(rep(10L, 100L), rep(20L, 100L), rep(30L, 100L)),
               dim = c(10L, 10L, 3L))
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

# ── split_channels ────────────────────────────────────────────────────────────

test_that("split_channels() on BGR image returns list of length 3", {
  result <- split_channels(img_bgr())
  expect_length(result, 3L)
})

test_that("split_channels() names are c('B', 'G', 'R') for BGR", {
  result <- split_channels(img_bgr())
  expect_equal(names(result), c("B", "G", "R"))
})

test_that("split_channels() each channel is single-channel CV_8U", {
  result <- split_channels(img_bgr())
  for (ch in result) {
    expect_equal(ch$nchan, 1L)
    expect_equal(ch$depth_name, "CV_8U")
  }
})

test_that("split_channels() each channel has correct nrow and ncol", {
  img <- img_bgr()
  result <- split_channels(img)
  for (ch in result) {
    expect_equal(ch$nrow, img$nrow)
    expect_equal(ch$ncol, img$ncol)
  }
})

test_that("split_channels() on GRAY image returns list named 'Y'", {
  arr <- array(100L, dim = c(10L, 10L, 1L))
  img <- Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
  result <- split_channels(img)
  expect_length(result, 1L)
  expect_equal(names(result), "Y")
})

# ── merge_channels ────────────────────────────────────────────────────────────

test_that("merge_channels() roundtrip recovers original BGR image", {
  img <- img_bgr()
  result <- merge_channels(split_channels(img))
  expect_equal(result$to_array(), img$to_array())
})

test_that("merge_channels() infers colorspace 'BGR' from names", {
  result <- merge_channels(split_channels(img_bgr()))
  expect_equal(result$colorspace, "BGR")
})

test_that("merge_channels() warns and sets 'UNKNOWN' for unrecognised names", {
  chs <- split_channels(img_bgr())
  names(chs) <- c("X", "Y", "Z")
  expect_warning(
    result <- merge_channels(chs),
    "channel names do not match a known colorspace"
  )
  expect_equal(result$colorspace, "UNKNOWN")
})

test_that("merge_channels() errors on mismatched dimensions", {
  a <- Image$new(array(10L, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_8U")
  b <- Image$new(array(10L, dim = c(5L, 10L, 1L)), colorspace = "GRAY", depth = "CV_8U")
  expect_error(merge_channels(list(a, b)), "all channels must have the same dimensions")
})

test_that("merge_channels() errors on mismatched depth", {
  a <- Image$new(array(10L, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_8U")
  b <- Image$new(array(10L, dim = c(10L, 10L, 1L)), colorspace = "GRAY", depth = "CV_16U")
  expect_error(merge_channels(list(a, b)), "all channels must have the same depth")
})

test_that("merge_channels() errors on multi-channel input element", {
  expect_error(
    merge_channels(list(img_bgr())),
    "channels must be a non-empty list of single-channel Image objects"
  )
})

test_that("split_channels() errors on non-Image input", {
  expect_error(split_channels(42), "img must be an Image object")
})
