# morph() rejects 'wrap' border_type (unsupported by OpenCV)

    Code
      img_gray()$morph("erode", border_type = "wrap")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# invalid operation errors

    Code
      img_gray()$morph("blur")
    Condition
      Error:
      ! operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat

# invalid shape errors

    Code
      img_gray()$morph("erode", shape = "diamond")
    Condition
      Error:
      ! shape must be one of: rect, cross, ellipse

# even size errors

    Code
      img_gray()$morph("erode", size = 4L)
    Condition
      Error:
      ! size must be a single positive odd integer

# non-matrix kernel errors

    Code
      img_gray()$morph("erode", kernel = c(1, 0, 1))
    Condition
      Error:
      ! kernel must be a numeric matrix

# invalid border_type errors

    Code
      img_gray()$morph("erode", border_type = "padded")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

