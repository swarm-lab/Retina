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
  expect_error(Retina:::rt_image_get_pixel(ptr, 0L, 1L), "out of bounds")
  expect_error(Retina:::rt_image_get_pixel(ptr, 4L, 1L), "out of bounds")
})

test_that("rt_image_get_pixel errors on out-of-bounds col", {
  ptr <- img_3x4()$.__enclos_env__$private$.ptr
  expect_error(Retina:::rt_image_get_pixel(ptr, 1L, 0L), "out of bounds")
  expect_error(Retina:::rt_image_get_pixel(ptr, 1L, 5L), "out of bounds")
})

test_that("rt_image_set_pixel errors when values length < nchan", {
  ptr <- img_3x4()$.__enclos_env__$private$.ptr
  expect_error(Retina:::rt_image_set_pixel(ptr, 1L, 1L, c(1, 2)), "channel")
})
