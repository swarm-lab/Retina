# resize errors if both dimensions and scale supplied

    Code
      img_bgr()$resize(width = 5L, height = 5L, fx = 2, fy = 2)
    Condition
      Error:
      ! supply either width/height or fx/fy, not both

# resize errors if neither supplied

    Code
      img_bgr()$resize()
    Condition
      Error:
      ! supply either width/height or fx/fy

# resize errors on non-positive width

    Code
      img_bgr()$resize(width = 0L, height = 5L)
    Condition
      Error:
      ! width and height must be single positive integers

# flip errors when both FALSE

    Code
      img_bgr()$flip()
    Condition
      Error:
      ! at least one of flip_h or flip_v must be TRUE

# crop errors on out-of-bounds coordinates

    Code
      img_bgr()$crop(1L, 1L, 11L, 5L)
    Condition
      Error:
      ! crop coordinates exceed image dimensions

# crop errors when x1 >= x2

    Code
      img_bgr()$crop(5L, 1L, 5L, 10L)
    Condition
      Error:
      ! x1 must be less than x2

# rotate() rejects 'default' as border_type

    Code
      img_bgr()$rotate(45, border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant, wrap

