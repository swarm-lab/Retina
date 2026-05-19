# blur() throws for non-length-2 ksize

    Code
      img_uniform()$blur(5)
    Condition
      Error:
      ! ksize must be a length-2 vector of positive integers

# blur() throws for non-positive ksize

    Code
      img_uniform()$blur(c(-1, 3))
    Condition
      Error:
      ! ksize must be a length-2 vector of positive integers

# gaussian_blur() throws for even ksize element

    Code
      img_uniform()$gaussian_blur(c(3, 4), 1.5)
    Condition
      Error:
      ! ksize elements must each be odd and positive, or 0

# gaussian_blur() throws for wrong-length sigma

    Code
      img_uniform()$gaussian_blur(c(3, 3), c(1, 2, 3))
    Condition
      Error:
      ! sigma must be length 1 or 2

# gaussian_blur() throws for non-positive sigma

    Code
      img_uniform()$gaussian_blur(c(3, 3), -1)
    Condition
      Error:
      ! sigma values must be positive

# median_blur() throws for even ksize

    Code
      img_uniform()$median_blur(4)
    Condition
      Error:
      ! ksize must be a single positive odd integer

# median_blur() throws for length-2 ksize

    Code
      img_uniform()$median_blur(c(3, 3))
    Condition
      Error:
      ! ksize must be a single positive odd integer

# bilateral_filter() throws for non-scalar d

    Code
      img_uniform()$bilateral_filter(c(5, 5), 75, 75)
    Condition
      Error:
      ! d must be a single integer

# bilateral_filter() throws for non-positive sigma_color

    Code
      img_uniform()$bilateral_filter(5, -1, 75)
    Condition
      Error:
      ! sigma_color and sigma_space must each be a single positive numeric value

