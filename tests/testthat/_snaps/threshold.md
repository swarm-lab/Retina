# autothreshold_value() errors on multi-channel image

    Code
      autothreshold_value(bgr, "otsu")
    Condition
      Error:
      ! autothreshold_value() requires a single-channel image

# autothreshold_value() errors on unknown method

    Code
      autothreshold_value(img, "bogus")
    Condition
      Error:
      ! method must be one of: imagej, huang, huang2, intermodes, isodata, li, maxentropy, mean, minerrori, minimum, moments, otsu, percentile, renyientropy, shanbhag, triangle, yen

# autothreshold_value() errors on non-Image input

    Code
      autothreshold_value(matrix(1:9, 3, 3), "otsu")
    Condition
      Error:
      ! img must be an Image object

# autothreshold_value() errors when bins < 2

    Code
      autothreshold_value(img, "otsu", bins = 1L)
    Condition
      Error:
      ! bins must be a single integer >= 2

# $threshold_() errors on non-finite thresh

    Code
      img$threshold_(Inf)
    Condition
      Error:
      ! thresh must be a single finite numeric or a method string

---

    Code
      img$threshold_(NA_real_)
    Condition
      Error:
      ! thresh must be a single finite numeric or a method string

# $threshold() errors on auto method with multi-channel image

    Code
      bgr$threshold("otsu")
    Condition
      Error:
      ! auto-threshold methods require a single-channel image

# $threshold() errors on unknown type string

    Code
      img$threshold(127, type = "bogus")
    Condition
      Error:
      ! type must be one of: binary, binary_inv, trunc, tozero, tozero_inv

# $threshold() errors on non-finite thresh

    Code
      img$threshold(Inf)
    Condition
      Error:
      ! thresh must be a single finite numeric or a method string

---

    Code
      img$threshold(NA_real_)
    Condition
      Error:
      ! thresh must be a single finite numeric or a method string

# $adaptive_threshold() errors on multi-channel image

    Code
      bgr$adaptive_threshold()
    Condition
      Error:
      ! adaptive_threshold() requires a single-channel CV_8U image

# $adaptive_threshold() errors on non-CV_8U image

    Code
      img$adaptive_threshold()
    Condition
      Error:
      ! adaptive_threshold() requires a single-channel CV_8U image

# $adaptive_threshold() errors when block_size is even

    Code
      img$adaptive_threshold(block_size = 10L)
    Condition
      Error:
      ! block_size must be a single odd integer >= 3

# $adaptive_threshold() errors when block_size < 3

    Code
      img$adaptive_threshold(block_size = 1L)
    Condition
      Error:
      ! block_size must be a single odd integer >= 3

# $adaptive_threshold() errors on non-finite offset

    Code
      img$adaptive_threshold(offset = Inf)
    Condition
      Error:
      ! offset must be a single finite numeric

# $in_range() errors when lower > upper for any channel

    Code
      img$in_range(200, 100)
    Condition
      Error:
      ! each lower[k] must be <= upper[k]

# $in_range() errors when lower/upper length is not 1 or nchan

    Code
      bgr$in_range(c(0, 0), c(255, 255, 255))
    Condition
      Error:
      ! lower must have length 1 or 3 (nchan)

# $in_range() errors on NA in lower or upper

    Code
      img$in_range(NA_real_, 200)
    Condition
      Error:
      ! lower must be a finite numeric vector with no NAs

---

    Code
      img$in_range(0, NA_real_)
    Condition
      Error:
      ! upper must be a finite numeric vector with no NAs

