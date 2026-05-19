# add() throws for non-Image non-numeric other

    Code
      img$add("foo")
    Condition
      Error:
      ! other must be an Image or a numeric vector

# add() throws for wrong-length scalar

    Code
      img$add(c(1, 2))
    Condition
      Error:
      ! values must be length 1 or length nchan

# add_weighted() throws for non-scalar w1

    Code
      img$add_weighted(make_img2(), c(0.5, 0.5), 0.5, 0)
    Condition
      Error:
      ! w1, w2, and gamma must each be a single numeric value

