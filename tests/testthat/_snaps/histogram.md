# hist() throws for bins < 1

    Code
      img_gray_flat()$hist(bins = 0L, range = c(0, 255))
    Condition
      Error:
      ! bins must be a single positive integer

# hist() throws for invalid range

    Code
      img_gray_flat()$hist(bins = 8L, range = c(100, 50))
    Condition
      Error:
      ! range must be a length-2 finite numeric vector with range[1] < range[2]

# hist() throws for non-logical freq

    Code
      img_gray_flat()$hist(bins = 8L, range = c(0, 255), freq = "yes")
    Condition
      Error:
      ! freq must be a single logical value

# hist_eq() throws for multi-channel image

    Code
      img_bgr_flat()$hist_eq()
    Condition
      Error:
      ! hist_eq() requires a single-channel image; use split_channels() + lapply() for multi-channel images

# hist_eq() throws for non-CV_8U depth

    Code
      img$hist_eq()
    Condition
      Error:
      ! hist_eq() requires a CV_8U image

