# filter2D() throws for non-matrix kernel

    Code
      img_uniform()$filter2D(c(0, 0, 0, 0, 1, 0, 0, 0, 0))
    Condition
      Error:
      ! kernel must be a numeric matrix

# filter2D() throws for kernel with NA

    Code
      img_uniform()$filter2D(k)
    Condition
      Error:
      ! kernel must not contain NA or infinite values

# filter2D() throws for out-of-bounds anchor

    Code
      img_uniform()$filter2D(k, anchor = c(5L, 1L))
    Condition
      Error:
      ! anchor values are out of kernel bounds (0-based)

# filter2D() throws for invalid border_type

    Code
      img_uniform()$filter2D(k, border_type = "invalid")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant, wrap

# filter2D() throws for invalid ddepth

    Code
      img_uniform()$filter2D(k, ddepth = "CV_99")
    Condition
      Error:
      ! ddepth must be NULL or one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F

