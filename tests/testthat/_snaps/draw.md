# col2bgr numeric wrong length errors

    Code
      col2bgr(c(0, 0))
    Condition
      Error:
      ! color must be a numeric vector of length 3 or 4

# col2bgr numeric out-of-range errors

    Code
      col2bgr(c(0, 0, 300))
    Condition
      Error:
      ! numeric color values must be in [0, 255]

# draw_line() errors on invalid thickness

    Code
      img_black()$draw_line(1, 1, 10, 10, color = "red", thickness = 0L)
    Condition
      Error:
      ! thickness must be a single positive integer

# draw_line() errors on invalid line_type

    Code
      img_black()$draw_line(1, 1, 10, 10, color = "red", line_type = "solid")
    Condition
      Error:
      ! line_type must be one of: line_4, line_8, aa

# draw_rectangle() errors on negative thickness

    Code
      img_black()$draw_rectangle(10, 10, 90, 90, color = "red", thickness = -1L)
    Condition
      Error:
      ! thickness must be a single positive integer

# draw_circle() errors on negative radius

    Code
      img_black()$draw_circle(50, 50, -1L, color = "red")
    Condition
      Error:
      ! radius must be a single non-negative integer

# draw_ellipse() errors on rx < 1

    Code
      img_black()$draw_ellipse(50, 50, 0L, 20L, color = "red")
    Condition
      Error:
      ! rx and ry must be single positive integers

# draw_polyline() errors on non-matrix pts

    Code
      img_black()$draw_polyline(c(1, 2, 3, 4), color = "red")
    Condition
      Error:
      ! pts must be a numeric matrix

# draw_polyline() errors on pts with wrong ncol

    Code
      img_black()$draw_polyline(matrix(1:9, nrow = 3, ncol = 3), color = "red")
    Condition
      Error:
      ! pts must have exactly 2 columns (x, y)

# draw_polyline() errors on pts with fewer than 2 rows

    Code
      img_black()$draw_polyline(pts, color = "red")
    Condition
      Error:
      ! pts must have at least 2 rows

# fill_poly() errors on pts with fewer than 3 rows

    Code
      img_black()$fill_poly(pts, color = "red")
    Condition
      Error:
      ! pts must have at least 3 rows

# draw_text() errors on invalid font

    Code
      img_black()$draw_text("x", 10, 50, color = "red", font = "arial")
    Condition
      Error:
      ! font must be one of: simplex, plain, duplex, complex, triplex, complex_small, script_simplex, script_complex

# draw_text() errors on invalid line_type

    Code
      img_black()$draw_text("x", 10, 50, color = "red", line_type = "dashed")
    Condition
      Error:
      ! line_type must be one of: line_4, line_8, aa

# get_text_size() errors on invalid font

    Code
      get_text_size("x", font = "times")
    Condition
      Error:
      ! font must be one of: simplex, plain, duplex, complex, triplex, complex_small, script_simplex, script_complex

# get_text_size() errors on invalid thickness

    Code
      get_text_size("x", thickness = 0L)
    Condition
      Error:
      ! thickness must be a single positive integer

