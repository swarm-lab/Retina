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

# hist_match() throws for multi-channel image

    Code
      img_bgr_flat()$hist_match(ref_hist)
    Condition
      Error:
      ! hist_match() requires a single-channel image

# hist_match() throws for non-CV_8U image

    Code
      img$hist_match(ref_hist)
    Condition
      Error:
      ! hist_match() requires a CV_8U image

# hist_match() throws for ref without required columns

    Code
      img_gray_flat()$hist_match(bad_ref)
    Condition
      Error:
      ! ref must be a data frame with columns bin_center, channel, count (as produced by $hist())

# hist_match() throws for ref with wrong number of rows

    Code
      img_gray_flat()$hist_match(bad_ref)
    Condition
      Error:
      ! ref must have exactly 256 rows; compute with $hist(bins = 256L)

# hist_match() throws for ref with negative counts

    Code
      img_gray_flat()$hist_match(ref_hist)
    Condition
      Error:
      ! ref$count must be non-negative

# CLAHE() throws for multi-channel image

    Code
      img_bgr_flat()$CLAHE()
    Condition
      Error:
      ! CLAHE() requires a single-channel image; use split_channels() + lapply() for multi-channel images

# CLAHE() throws for non-CV_8U/CV_16U depth

    Code
      img$CLAHE()
    Condition
      Error:
      ! CLAHE() requires a CV_8U or CV_16U image

# CLAHE() throws for non-positive clip_limit

    Code
      img_gray_flat()$CLAHE(clip_limit = 0)
    Condition
      Error:
      ! clip_limit must be a single positive finite numeric

# CLAHE() throws for invalid tile_grid_size

    Code
      img_gray_flat()$CLAHE(tile_grid_size = 0L)
    Condition
      Error:
      ! tile_grid_size must be a length-1 or length-2 positive integer vector

# minmax_loc() throws for multi-channel image

    Code
      img_bgr_flat()$minmax_loc()
    Condition
      Error:
      ! minmax_loc() requires a single-channel image; use split_channels() for multi-channel images

# count_nonzero() throws for multi-channel image

    Code
      img_bgr_flat()$count_nonzero()
    Condition
      Error:
      ! count_nonzero() requires a single-channel image; use split_channels() + lapply() for multi-channel images

# find_nonzero() throws for multi-channel image

    Code
      img_bgr_flat()$find_nonzero()
    Condition
      Error:
      ! find_nonzero() requires a single-channel image; use split_channels() + lapply() for multi-channel images

