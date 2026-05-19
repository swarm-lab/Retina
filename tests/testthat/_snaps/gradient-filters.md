# sobel() throws for dx = 0 and dy = 0

    Code
      img_uniform()$sobel(0, 0)
    Condition
      Error:
      ! dx and dy must be non-negative integers with dx + dy >= 1

# sobel() throws for even ksize

    Code
      img_uniform()$sobel(1, 0, ksize = 4)
    Condition
      Error:
      ! ksize must be 1, 3, 5, or 7

# sobel() throws for unsupported ddepth

    Code
      img_uniform()$sobel(1, 0, ddepth = "CV_8U")
    Condition
      Error:
      ! ddepth must be one of: CV_16S, CV_32F, CV_64F

# sobel() throws for non-positive scale

    Code
      img_uniform()$sobel(1, 0, scale = -1)
    Condition
      Error:
      ! scale must be a single positive numeric value

# sobel() throws for invalid border_type

    Code
      img_uniform()$sobel(1, 0, border_type = "foo")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# laplacian() throws for even ksize

    Code
      img_uniform()$laplacian(ksize = 4)
    Condition
      Error:
      ! ksize must be 1, 3, 5, or 7

# laplacian() throws for unsupported ddepth

    Code
      img_uniform()$laplacian(ddepth = "CV_8U")
    Condition
      Error:
      ! ddepth must be one of: CV_16S, CV_32F, CV_64F

# scharr() throws when dx = dy = 0

    Code
      img_uniform()$scharr(0L, 0L, ddepth = "CV_16S")
    Condition
      Error:
      ! dx and dy must each be 0 or 1, and exactly one must be 1

# scharr() throws when dx = dy = 1

    Code
      img_uniform()$scharr(1L, 1L, ddepth = "CV_16S")
    Condition
      Error:
      ! dx and dy must each be 0 or 1, and exactly one must be 1

# scharr() throws for wrap border_type

    Code
      img_uniform()$scharr(1L, 0L, ddepth = "CV_16S", border_type = "wrap")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# scharr() throws for invalid ddepth

    Code
      img_uniform()$scharr(1L, 0L, ddepth = "CV_8U")
    Condition
      Error:
      ! ddepth must be one of: CV_16S, CV_32F, CV_64F

