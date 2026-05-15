# Synthetic 10x10 BGR image, all pixels = (100, 150, 200)
make_test_image <- function() {
  arr <- array(0L, dim = c(10L, 10L, 3L))
  arr[,,1] <- 100L  # B
  arr[,,2] <- 150L  # G
  arr[,,3] <- 200L  # R
  Image$new(arr, colorspace = "BGR", depth = "CV_8U")
}
