# Helper -----------------------------------------------------------------------
img_3x4 <- function() {
  arr <- array(0L, dim = c(3L, 4L, 3L))  # nrow=3, ncol=4, nchan=3
  for (i in 1:3) for (j in 1:4) arr[i, j, ] <- c(i * 10L, j * 10L, 0L)
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}

# ── C++ smoke tests ───────────────────────────────────────────────────────────

test_that("rt_image_get_pixel returns doubles of length nchan", {
  px <- Retina:::rt_image_get_pixel(img_3x4()$.__enclos_env__$private$.ptr, 2L, 3L)
  expect_type(px, "double")
  expect_length(px, 3L)
})

test_that("rt_image_get_pixel returns correct channel values", {
  # pixel (2,3): B = 2*10 = 20, G = 3*10 = 30, R = 0
  px <- Retina:::rt_image_get_pixel(img_3x4()$.__enclos_env__$private$.ptr, 2L, 3L)
  expect_equal(px[[1L]], 20)
  expect_equal(px[[2L]], 30)
  expect_equal(px[[3L]], 0)
})

test_that("rt_image_set_pixel modifies the pixel in place", {
  img <- img_3x4()
  Retina:::rt_image_set_pixel(img$.__enclos_env__$private$.ptr, 2L, 3L,
                              c(99, 88, 77))
  px <- Retina:::rt_image_get_pixel(img$.__enclos_env__$private$.ptr, 2L, 3L)
  expect_equal(as.integer(px[[1L]]), 99L)
  expect_equal(as.integer(px[[2L]]), 88L)
  expect_equal(as.integer(px[[3L]]), 77L)
})

test_that("rt_image_extract_region returns Image of correct dimensions", {
  result <- Retina:::rt_image_extract_region(
    img_3x4()$.__enclos_env__$private$.ptr, 1L, 2L, 2L, 4L)
  out <- Image$new(result)
  expect_equal(out$nrow, 2L)
  expect_equal(out$ncol, 3L)
})

test_that("rt_image_extract_region supports single-row extraction", {
  result <- Retina:::rt_image_extract_region(
    img_3x4()$.__enclos_env__$private$.ptr, 2L, 1L, 2L, 4L)
  out <- Image$new(result)
  expect_equal(out$nrow, 1L)
  expect_equal(out$ncol, 4L)
})

test_that("rt_image_copy_roi pastes src into dst", {
  dst <- img_3x4()
  src_arr <- array(99L, dim = c(2L, 2L, 3L))
  src <- Image$new(src_arr, colorspace = "BGR", depth = "CV_8U")
  Retina:::rt_image_copy_roi(dst$.__enclos_env__$private$.ptr,
                             src$.__enclos_env__$private$.ptr,
                             1L, 1L)
  # Top-left 2x2 region should now be all 99
  px <- Retina:::rt_image_get_pixel(dst$.__enclos_env__$private$.ptr, 1L, 1L)
  expect_equal(as.integer(px[[1L]]), 99L)
})

test_that("rt_image_get_pixel errors on out-of-bounds row", {
  ptr <- img_3x4()$.__enclos_env__$private$.ptr
  expect_snapshot(error = TRUE, Retina:::rt_image_get_pixel(ptr, 0L, 1L))
  expect_snapshot(error = TRUE, Retina:::rt_image_get_pixel(ptr, 4L, 1L))
})

test_that("rt_image_get_pixel errors on out-of-bounds col", {
  ptr <- img_3x4()$.__enclos_env__$private$.ptr
  expect_snapshot(error = TRUE, Retina:::rt_image_get_pixel(ptr, 1L, 0L))
  expect_snapshot(error = TRUE, Retina:::rt_image_get_pixel(ptr, 1L, 5L))
})

test_that("rt_image_set_pixel errors when values length < nchan", {
  ptr <- img_3x4()$.__enclos_env__$private$.ptr
  expect_snapshot(error = TRUE, Retina:::rt_image_set_pixel(ptr, 1L, 1L, c(1, 2)))
})

# ── [.Image read operator ─────────────────────────────────────────────────────

test_that("[.Image returns named numeric vector for single pixel", {
  px <- img_3x4()[1L, 1L]
  expect_type(px, "double")
  expect_length(px, 3L)
  expect_named(px, c("B", "G", "R"))
})

test_that("[.Image returns correct channel values for single pixel", {
  # pixel (2,3): B = 2*10 = 20, G = 3*10 = 30, R = 0
  px <- img_3x4()[2L, 3L]
  expect_equal(px[["B"]], 20)
  expect_equal(px[["G"]], 30)
  expect_equal(px[["R"]], 0)
})

test_that("[.Image with k returns single scalar", {
  # channel 2 (G) at (1,1): j=1, so G = 1*10 = 10
  val <- img_3x4()[1L, 1L, 2L]
  expect_length(val, 1L)
  expect_equal(val, 10)
})

test_that("[.Image range returns Image with correct dimensions", {
  result <- img_3x4()[1:2, 1:3]
  expect_s3_class(result, "Image")
  expect_equal(result$nrow, 2L)
  expect_equal(result$ncol, 3L)
})

test_that("[.Image range preserves colorspace", {
  expect_equal(img_3x4()[1:2, 1:3]$colorspace, "BGR")
})

test_that("[.Image missing i returns full-column strip", {
  result <- img_3x4()[, 2L]
  expect_equal(result$nrow, 3L)
  expect_equal(result$ncol, 1L)
})

test_that("[.Image missing j returns full-row strip", {
  result <- img_3x4()[1L, ]
  expect_equal(result$nrow, 1L)
  expect_equal(result$ncol, 4L)
})

test_that("[.Image errors when both i and j are missing", {
  expect_snapshot(error = TRUE, img_3x4()[])
})

test_that("[.Image errors on row index out of bounds (low)", {
  expect_snapshot(error = TRUE, img_3x4()[0L, 1L])
})

test_that("[.Image errors on row index out of bounds (high)", {
  expect_snapshot(error = TRUE, img_3x4()[4L, 1L])
})

test_that("[.Image errors on column index out of bounds (high)", {
  expect_snapshot(error = TRUE, img_3x4()[1L, 5L])
})

test_that("[.Image errors on non-contiguous row index", {
  expect_snapshot(error = TRUE, img_3x4()[c(1L, 3L), 1L])
})

test_that("[.Image errors on channel index out of bounds", {
  expect_snapshot(error = TRUE, img_3x4()[1L, 1L, 4L])
})

test_that("[.Image channel names for GRAY image use 'Y'", {
  gray_arr <- array(128L, dim = c(3L, 3L, 1L))
  gray_img <- Image$new(gray_arr, colorspace = "GRAY", depth = "CV_8U")
  px <- gray_img[1L, 1L]
  expect_named(px, "Y")
})

test_that("[.Image channel names for HSV image use H, S, V", {
  hsv_arr <- array(100L, dim = c(3L, 3L, 3L))
  hsv_img <- Image$new(hsv_arr, colorspace = "HSV", depth = "CV_8U")
  px <- hsv_img[1L, 1L]
  expect_named(px, c("H", "S", "V"))
})

test_that("[.Image errors on NA row index", {
  expect_snapshot(error = TRUE, img_3x4()[NA_integer_, 1L])
})

test_that("[.Image errors on zero-length row index", {
  expect_snapshot(error = TRUE, img_3x4()[integer(0), 1L])
})

test_that("[.Image errors when k is supplied with a range", {
  expect_snapshot(error = TRUE, img_3x4()[1:2, 1:3, 1L])
})

test_that("[.Image errors on column index below 1", {
  expect_snapshot(error = TRUE, img_3x4()[1L, 0L])
})

# ── [<-.Image write operator ──────────────────────────────────────────────────

test_that("[<-.Image single-pixel write roundtrip", {
  img <- img_3x4()
  img[2L, 3L] <- c(99L, 88L, 77L)
  px <- img[2L, 3L]
  expect_equal(as.integer(px[["B"]]), 99L)
  expect_equal(as.integer(px[["G"]]), 88L)
  expect_equal(as.integer(px[["R"]]), 77L)
})

test_that("[<-.Image single-channel write roundtrip", {
  img <- img_3x4()
  img[2L, 3L, 1L] <- 55L  # B channel
  expect_equal(as.integer(img[2L, 3L, 1L]), 55L)
  # Other channels unchanged
  expect_equal(as.integer(img[2L, 3L, 2L]), 30L)
})

test_that("[<-.Image single-pixel write does not affect other pixels", {
  img <- img_3x4()
  img[2L, 3L] <- c(99L, 88L, 77L)
  # Adjacent pixel (1,3) should be unchanged: B=10, G=30, R=0
  px <- img[1L, 3L]
  expect_equal(as.integer(px[["B"]]), 10L)
  expect_equal(as.integer(px[["G"]]), 30L)
})

test_that("[<-.Image range write (ROI copy) pastes src into dst", {
  dst <- img_3x4()
  src_arr <- array(42L, dim = c(2L, 2L, 3L))
  src <- Image$new(src_arr, colorspace = "BGR", depth = "CV_8U")
  dst[1:2, 1:2] <- src
  # Pixels in the pasted region should be 42
  expect_equal(as.integer(dst[1L, 1L, 1L]), 42L)
  expect_equal(as.integer(dst[2L, 2L, 1L]), 42L)
  # Pixel outside the region should be unchanged: (3,3) B=30
  expect_equal(as.integer(dst[3L, 3L, 1L]), 30L)
})

test_that("[<-.Image returns the modified image", {
  img <- img_3x4()
  result <- `[<-`(img, 1L, 1L, value = c(1L, 2L, 3L))
  expect_s3_class(result, "Image")
})

test_that("[<-.Image errors when value length mismatches nchan", {
  img <- img_3x4()
  expect_snapshot(error = TRUE, {
    img[1L, 1L] <- c(1L, 2L)
  })
})

test_that("[<-.Image errors when range write value is not an Image", {
  img <- img_3x4()
  expect_snapshot(error = TRUE, {
    img[1:2, 1:2] <- matrix(42L, 2L, 2L)
  })
})

test_that("[<-.Image errors when range write dimensions mismatch", {
  dst <- img_3x4()
  src_arr <- array(42L, dim = c(3L, 2L, 3L))  # 3 rows, not 2
  src <- Image$new(src_arr, colorspace = "BGR", depth = "CV_8U")
  expect_snapshot(error = TRUE, {
    dst[1:2, 1:2] <- src
  })
})

test_that("[<-.Image errors when k is supplied with a range", {
  dst <- img_3x4()
  src_arr <- array(42L, dim = c(2L, 2L, 3L))
  src <- Image$new(src_arr, colorspace = "BGR", depth = "CV_8U")
  expect_snapshot(error = TRUE, {
    dst[1:2, 1:2, 1L] <- src
  })
})
