# canny() throws for multi-channel image

    Code
      img$canny(10, 50)
    Condition
      Error:
      ! canny requires a single-channel (grayscale) image — use convert_color('GRAY') first

# canny() throws for negative low_threshold

    Code
      img_gray_uniform()$canny(-1, 50)
    Condition
      Error:
      ! low_threshold must be a single non-negative numeric value

# canny() throws for non-positive high_threshold

    Code
      img_gray_uniform()$canny(10, -1)
    Condition
      Error:
      ! high_threshold must be a single positive numeric value

# canny() throws when low_threshold > high_threshold

    Code
      img_gray_uniform()$canny(100, 50)
    Condition
      Error:
      ! low_threshold must be <= high_threshold

# canny() throws for invalid aperture_size

    Code
      img_gray_uniform()$canny(10, 50, aperture_size = 4)
    Condition
      Error:
      ! aperture_size must be 3, 5, or 7

# canny() throws for non-logical L2_gradient

    Code
      img_gray_uniform()$canny(10, 50, L2_gradient = "yes")
    Condition
      Error:
      ! L2_gradient must be a single logical value

