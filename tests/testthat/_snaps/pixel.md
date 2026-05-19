# rt_image_get_pixel errors on out-of-bounds row

    Code
      Retina:::rt_image_get_pixel(ptr, 0L, 1L)
    Condition
      Error:
      ! pixel coordinates out of bounds

---

    Code
      Retina:::rt_image_get_pixel(ptr, 4L, 1L)
    Condition
      Error:
      ! pixel coordinates out of bounds

# rt_image_get_pixel errors on out-of-bounds col

    Code
      Retina:::rt_image_get_pixel(ptr, 1L, 0L)
    Condition
      Error:
      ! pixel coordinates out of bounds

---

    Code
      Retina:::rt_image_get_pixel(ptr, 1L, 5L)
    Condition
      Error:
      ! pixel coordinates out of bounds

# rt_image_set_pixel errors when values length < nchan

    Code
      Retina:::rt_image_set_pixel(ptr, 1L, 1L, c(1, 2))
    Condition
      Error:
      ! values must have one element per channel (3 expected, got 2)

# [.Image errors when both i and j are missing

    Code
      img_3x4()[]
    Condition
      Error:
      ! at least one index must be provided

# [.Image errors on row index out of bounds (low)

    Code
      img_3x4()[0L, 1L]
    Condition
      Error:
      ! row index out of bounds

# [.Image errors on row index out of bounds (high)

    Code
      img_3x4()[4L, 1L]
    Condition
      Error:
      ! row index out of bounds

# [.Image errors on column index out of bounds (high)

    Code
      img_3x4()[1L, 5L]
    Condition
      Error:
      ! column index out of bounds

# [.Image errors on non-contiguous row index

    Code
      img_3x4()[c(1L, 3L), 1L]
    Condition
      Error:
      ! index must be a contiguous integer sequence

# [.Image errors on channel index out of bounds

    Code
      img_3x4()[1L, 1L, 4L]
    Condition
      Error:
      ! channel index out of bounds

# [.Image errors on NA row index

    Code
      img_3x4()[NA_integer_, 1L]
    Condition
      Error:
      ! row index must not contain NA

# [.Image errors on zero-length row index

    Code
      img_3x4()[integer(0), 1L]
    Condition
      Error:
      ! row index must not be empty

# [.Image errors when k is supplied with a range

    Code
      img_3x4()[1:2, 1:3, 1L]
    Condition
      Error:
      ! channel index k is not supported for range extraction

# [.Image errors on column index below 1

    Code
      img_3x4()[1L, 0L]
    Condition
      Error:
      ! column index out of bounds

# [<-.Image errors when value length mismatches nchan

    Code
      img[1L, 1L] <- c(1L, 2L)
    Condition
      Error:
      ! value must be a numeric vector of length 3 (matching nchan)

# [<-.Image errors when range write value is not an Image

    Code
      img[1:2, 1:2] <- matrix(42L, 2L, 2L)
    Condition
      Error:
      ! value must be an Image for range assignment

# [<-.Image errors when range write dimensions mismatch

    Code
      dst[1:2, 1:2] <- src
    Condition
      Error:
      ! value dimensions do not match the index range

# [<-.Image errors when k is supplied with a range

    Code
      dst[1:2, 1:2, 1L] <- src
    Condition
      Error:
      ! channel index k is not supported for range assignment

