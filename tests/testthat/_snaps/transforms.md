# affine_from_points errors on wrong src shape

    Code
      affine_from_points(src, dst)
    Condition
      Error:
      ! src must be a 3x2 numeric matrix

# perspective_from_points errors on wrong src shape

    Code
      perspective_from_points(src, dst)
    Condition
      Error:
      ! src must be a 4x2 numeric matrix

# warp_affine errors on wrong matrix shape (3x3)

    Code
      img_10x10()$warp_affine(diag(3))
    Condition
      Error:
      ! m must be a 2x3 numeric matrix

# warp_affine errors on non-matrix input

    Code
      img_10x10()$warp_affine(1:6)
    Condition
      Error:
      ! m must be a 2x3 numeric matrix

# warp_perspective errors on wrong matrix shape (2x3)

    Code
      img_10x10()$warp_perspective(m)
    Condition
      Error:
      ! m must be a 3x3 numeric matrix

# warp_perspective errors on non-matrix input

    Code
      img_10x10()$warp_perspective(1:9)
    Condition
      Error:
      ! m must be a 3x3 numeric matrix

