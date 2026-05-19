# Image$new() throws for integer array with float depth

    Code
      Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_32F")
    Condition
      Error:
      ! use a double array for float depths (CV_32F, CV_64F)

# Image$new() throws for double array with integer depth

    Code
      Image$new(array(0.5, dim = c(5L, 5L, 3L)), depth = "CV_8U")
    Condition
      Error:
      ! use an integer array for integer depths (CV_8U, CV_16U, CV_16S)

# Image$new() throws for unsupported depth string

    Code
      Image$new(array(100L, dim = c(5L, 5L, 3L)), depth = "CV_99X")
    Condition
      Error:
      ! depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F

# convert_depth() throws for unsupported depth

    Code
      img$convert_depth("CV_99X")
    Condition
      Error:
      ! depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F

# add() throws for images with different depths

    Code
      img_8u$add(img_16s)
    Condition
      Error:
      ! images must have the same depth

# bilateral_filter() throws for non-CV_8U/CV_32F image

    Code
      img$bilateral_filter(9, 75, 75)
    Condition
      Error:
      ! bilateral_filter requires a CV_8U or CV_32F image

