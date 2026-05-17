test_that("Image$zeros() returns correct dimensions, depth, colorspace, and all-zero pixels", {
  img <- Image$zeros(3L, 4L, 3L, "CV_8U", "BGR")
  expect_equal(img$nrow, 3L)
  expect_equal(img$ncol, 4L)
  expect_equal(img$nchan, 3L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "BGR")
  expect_equal(img[1, 1], c(B = 0, G = 0, R = 0))
  expect_equal(img[3, 4], c(B = 0, G = 0, R = 0))
})

test_that("Image$zeros() default arguments produce 1-channel CV_8U GRAY image", {
  img <- Image$zeros(5L, 5L)
  expect_equal(img$nchan, 1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img$colorspace, "GRAY")
})

test_that("Image$ones() fills all pixels with value 1 (not depth maximum)", {
  img <- Image$ones(2L, 2L, 1L, "CV_8U", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
  expect_equal(img[2, 2], c(Y = 1))
})

test_that("Image$ones() works for CV_32F", {
  img <- Image$ones(2L, 2L, 1L, "CV_32F", "GRAY")
  expect_equal(img[1, 1], c(Y = 1))
})

test_that("Image$randu() values are within [low, high]", {
  img <- Image$randu(100L, 100L, 1L, "CV_32F", "GRAY", low = 0, high = 1)
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 1)
  expect_equal(img$nrow, 100L)
  expect_equal(img$ncol, 100L)
  expect_equal(img$nchan, 1L)
})

test_that("Image$randu() emits message and uses [0,255] default for CV_8U", {
  expect_message(
    { img <- Image$randu(50L, 50L) },
    "Using default range \\[0, 255\\] for CV_8U"
  )
  expect_equal(img$depth_name, "CV_8U")
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 255)
})

test_that("Image$randn() produces a roughly normal distribution", {
  img <- Image$randn(300L, 300L, 1L, "CV_32F", "GRAY", mean = 0, sd = 1)
  arr <- as.numeric(img$to_array())
  expect_lt(abs(mean(arr)), 0.1)
  expect_lt(abs(stats::sd(arr) - 1), 0.1)
})

test_that("Image$zeros() errors on nrow < 1", {
  expect_error(Image$zeros(0L, 4L), "nrow must be a single positive integer")
})

test_that("Image$zeros() errors on nchan > 4", {
  expect_error(Image$zeros(3L, 4L, nchan = 5L), "nchan must be a single positive integer <= 4")
})

test_that("Image$zeros() errors on invalid depth", {
  expect_error(Image$zeros(3L, 4L, depth = "CV_128U"), "depth must be one of")
})

test_that("Image$randu() errors when low >= high", {
  expect_error(Image$randu(3L, 3L, low = 5, high = 5), "low must be strictly less than high")
})

test_that("Image$randn() errors when sd <= 0", {
  expect_error(Image$randn(3L, 3L, sd = -1), "sd must be a single positive finite numeric")
})

test_that("Image$ones() errors on invalid ncol", {
  expect_error(Image$ones(3L, 0L), "ncol must be a single positive integer")
})

test_that("Image$zeros() returns an Image object", {
  expect_s3_class(Image$zeros(2L, 2L), "Image")
})

test_that("Image$ones() returns an Image object", {
  expect_s3_class(Image$ones(2L, 2L), "Image")
})

test_that("Image$randu() returns an Image object and handles 3 channels", {
  img <- Image$randu(10L, 10L, 3L, "CV_8U", "BGR")
  expect_s3_class(img, "Image")
  expect_equal(img$nchan, 3L)
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 255)
})

test_that("Image$randn() returns an Image object and handles 3 channels", {
  img <- Image$randn(50L, 50L, 3L, "CV_8U", "BGR", mean = 128, sd = 20)
  expect_s3_class(img, "Image")
  expect_equal(img$nchan, 3L)
})

test_that("border() adds correct pixel counts on all sides", {
  img <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
  b <- img$border(top = 1L, bottom = 2L, left = 3L, right = 4L,
                  type = "constant", value = 255)
  expect_equal(b$nrow, 6L)   # 3 + 1 + 2
  expect_equal(b$ncol, 11L)  # 4 + 3 + 4
  expect_equal(b[1, 1], c(Y = 255))   # border pixel
  expect_equal(b[2, 4], c(Y = 0))     # interior pixel
})

test_that("border() symmetric shorthand: border(2) adds 2 on all sides", {
  img <- Image$zeros(3L, 3L, 1L, "CV_8U", "GRAY")
  b <- img$border(2L)
  expect_equal(b$nrow, 7L)
  expect_equal(b$ncol, 7L)
})

test_that("border() preserves colorspace", {
  img <- Image$zeros(3L, 3L, 3L, "CV_8U", "BGR")
  b <- img$border(1L)
  expect_equal(b$colorspace, "BGR")
  expect_s3_class(b, "Image")
})

test_that("border() constant value applies per channel", {
  img <- Image$zeros(2L, 2L, 3L, "CV_8U", "BGR")
  b <- img$border(1L, type = "constant", value = c(10, 20, 30))
  expect_equal(b[1, 1], c(B = 10, G = 20, R = 30))
})

test_that("border_() modifies in place and returns self invisibly", {
  img <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
  result <- img$border_(1L, type = "replicate")
  expect_identical(result, img)
  expect_equal(img$nrow, 5L)
  expect_equal(img$ncol, 6L)
})

test_that("border() errors on invalid type", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(1L, type = "invalid"),
               "type must be one of")
})

test_that("border() errors on negative width", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(-1L), "top must be a single non-negative integer")
})

test_that("border() errors on empty value vector", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border(1L, value = numeric(0)),
               "value must be a non-empty numeric vector with no NAs")
})

test_that("border_() errors on invalid type", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border_(1L, type = "bad"),
               "type must be one of")
})

test_that("border() rejects 'default' as a type", {
  img <- Image$zeros(3L, 3L, 1L, "CV_8U", "GRAY")
  expect_error(img$border(1L, type = "default"), "type must be one of")
})

# ── Image$fill() ──────────────────────────────────────────────────────────────

test_that("Image$fill() creates image with scalar value on all pixels", {
  img <- Image$fill(128, 3L, 4L, 1L, "CV_8U", "GRAY")
  expect_equal(img$nrow, 3L)
  expect_equal(img$ncol, 4L)
  expect_equal(img$nchan, 1L)
  expect_equal(img$depth_name, "CV_8U")
  expect_equal(img[1, 1], c(Y = 128))
  expect_equal(img[3, 4], c(Y = 128))
})

test_that("Image$fill() with vector value fills each channel correctly", {
  img <- Image$fill(c(10, 20, 30), 3L, 4L, 3L, "CV_8U", "BGR")
  expect_equal(img[1, 1], c(B = 10, G = 20, R = 30))
  expect_equal(img[3, 4], c(B = 10, G = 20, R = 30))
})

test_that("Image$fill() scalar recycles to all channels", {
  img <- Image$fill(50, 2L, 2L, 3L, "CV_8U", "BGR")
  expect_equal(img[1, 1], c(B = 50, G = 50, R = 50))
})

test_that("Image$fill() returns an Image", {
  expect_s3_class(Image$fill(0, 2L, 2L), "Image")
})

test_that("Image$zeros() delegates to Image$fill()", {
  z <- Image$zeros(3L, 4L, 3L, "CV_8U", "BGR")
  f <- Image$fill(0, 3L, 4L, 3L, "CV_8U", "BGR")
  expect_equal(z$to_array(), f$to_array())
})

test_that("Image$ones() delegates to Image$fill()", {
  o <- Image$ones(2L, 2L, 1L, "CV_8U", "GRAY")
  f <- Image$fill(1, 2L, 2L, 1L, "CV_8U", "GRAY")
  expect_equal(o$to_array(), f$to_array())
})

test_that("Image$fill() errors on mismatched value length", {
  expect_error(
    Image$fill(c(1, 2), 3L, 3L, 3L),
    "value length.*must equal nchan"
  )
})

test_that("Image$fill() errors on NA value", {
  expect_error(Image$fill(NA_real_, 3L, 3L), "value must be")
})

test_that("Image$fill() errors on empty value", {
  expect_error(Image$fill(numeric(0), 3L, 3L), "value must be")
})

test_that("Image$fill() errors on non-finite value (Inf)", {
  expect_error(Image$fill(Inf, 3L, 3L), "value must be")
})

test_that("Image$fill() works with 4-channel BGRA image", {
  img <- Image$fill(c(10, 20, 30, 40), 2L, 2L, 4L, "CV_8U", "BGRA")
  expect_equal(img$nchan, 4L)
  expect_equal(img[1, 1], c(B = 10, G = 20, R = 30, A = 40))
})

test_that("Image$fill() works with float depth CV_32F", {
  img <- Image$fill(0.5, 2L, 2L, 1L, "CV_32F", "GRAY")
  expect_equal(img$depth_name, "CV_32F")
  expect_equal(img[1, 1], c(Y = 0.5))
})

# ── randu/randn depth-aware defaults ──────────────────────────────────────────

test_that("Image$randu() emits message with correct values for CV_32F", {
  expect_message(
    suppressWarnings(Image$randu(10L, 10L, depth = "CV_32F")),
    "Using default range \\[0, 1\\] for CV_32F"
  )
})

test_that("Image$randu() emits message with correct values for CV_16S", {
  expect_message(
    suppressWarnings(Image$randu(10L, 10L, depth = "CV_16S")),
    "Using default range \\[-32768, 32767\\] for CV_16S"
  )
})

test_that("Image$randu() emits no message when low and high are provided", {
  expect_no_message(Image$randu(10L, 10L, low = 0, high = 100))
})

test_that("Image$randu() CV_32F default produces values in [0, 1]", {
  suppressMessages(img <- Image$randu(100L, 100L, depth = "CV_32F"))
  arr <- img$to_array()
  expect_gte(min(arr), 0)
  expect_lte(max(arr), 1)
})

test_that("Image$randn() emits message and uses [128, 30] default for CV_8U", {
  expect_message(
    { img <- Image$randn(10L, 10L) },
    "Using default mean/sd \\[128, 30\\] for CV_8U"
  )
  expect_s3_class(img, "Image")
})

test_that("Image$randn() emits message with correct values for CV_16S", {
  expect_message(
    suppressWarnings(Image$randn(10L, 10L, depth = "CV_16S")),
    "Using default mean/sd \\[0, 10000\\] for CV_16S"
  )
})

test_that("Image$randn() emits no message when mean and sd are provided", {
  expect_no_message(Image$randn(10L, 10L, mean = 128, sd = 30))
})

test_that("Image$randu() applies only missing default when low is supplied", {
  expect_message(
    Image$randu(10L, 10L, low = 5),
    "Using default range \\[5, 255\\] for CV_8U"
  )
})

test_that("Image$randn() applies only missing default when mean is supplied", {
  expect_message(
    Image$randn(10L, 10L, mean = 100),
    "Using default mean/sd \\[100, 30\\] for CV_8U"
  )
})

# ── border() argument order ────────────────────────────────────────────────────

test_that("border() 2-arg form: first=vertical (top+bottom), second=horizontal (left+right)", {
  img <- Image$zeros(3L, 3L, 1L, "CV_8U", "GRAY")
  b <- img$border(1L, 3L)    # top=1, left=3, bottom=top=1, right=left=3
  expect_equal(b$nrow, 5L)   # 3 + 1 + 1
  expect_equal(b$ncol, 9L)   # 3 + 3 + 3
})

test_that("border_() rejects 'default' as a type", {
  img <- Image$zeros(3L, 3L)
  expect_error(img$border_(1L, type = "default"), "type must be one of")
})

# ── "default" border_type rejected in all methods ─────────────────────────────

test_that("$sobel() rejects 'default' as border_type", {
  img <- Image$zeros(5L, 5L, 1L, "CV_32F", "GRAY")
  expect_error(img$sobel(1L, 0L, border_type = "default"),
               "border_type must be one of")
})

test_that("$laplacian() rejects 'default' as border_type", {
  img <- Image$zeros(5L, 5L, 1L, "CV_32F", "GRAY")
  expect_error(img$laplacian(border_type = "default"),
               "border_type must be one of")
})

test_that("$morph() rejects 'default' as border_type", {
  img <- Image$zeros(5L, 5L, 1L, "CV_8U", "GRAY")
  expect_error(img$morph("erode", border_type = "default"),
               "border_type must be one of")
})

test_that("$warp_affine() rejects 'default' as border_type", {
  img <- Image$zeros(10L, 10L, 1L, "CV_8U", "GRAY")
  m <- matrix(c(1, 0, 0, 0, 1, 0), nrow = 2, byrow = TRUE)
  expect_error(img$warp_affine(m, border_type = "default"),
               "border_type must be one of")
})

test_that("$warp_perspective() rejects 'default' as border_type", {
  img <- Image$zeros(10L, 10L, 1L, "CV_8U", "GRAY")
  m <- diag(3)
  expect_error(img$warp_perspective(m, border_type = "default"),
               "border_type must be one of")
})

# ── $tile() / $tile_() ────────────────────────────────────────────────────────

test_that("$tile() with nrow and ncol multiplies dimensions", {
  img <- Image$zeros(3L, 4L, 1L, "CV_8U", "GRAY")
  t <- img$tile(2L, 3L)
  expect_equal(t$nrow, 6L)    # 3 * 2
  expect_equal(t$ncol, 12L)   # 4 * 3
})

test_that("$tile() with single arg tiles equally in both directions", {
  img <- Image$zeros(2L, 3L, 1L, "CV_8U", "GRAY")
  t <- img$tile(3L)
  expect_equal(t$nrow, 6L)    # 2 * 3
  expect_equal(t$ncol, 9L)    # 3 * 3
})

test_that("$tile() preserves colorspace and depth", {
  img <- Image$zeros(2L, 2L, 3L, "CV_8U", "BGR")
  t <- img$tile(2L)
  expect_equal(t$colorspace, "BGR")
  expect_equal(t$depth_name, "CV_8U")
  expect_s3_class(t, "Image")
})

test_that("$tile() preserves pixel values across the tiled pattern", {
  img <- Image$fill(100, 1L, 1L, 1L, "CV_8U", "GRAY")
  t <- img$tile(3L, 3L)
  arr <- t$to_array()
  expect_true(all(arr == 100))
})

test_that("$tile_() modifies in place and returns self invisibly", {
  img <- Image$zeros(2L, 2L, 1L, "CV_8U", "GRAY")
  result <- img$tile_(3L, 4L)
  expect_identical(result, img)
  expect_equal(img$nrow, 6L)    # 2 * 3
  expect_equal(img$ncol, 8L)    # 2 * 4
})

test_that("$tile() errors on nrow < 1", {
  img <- Image$zeros(2L, 2L)
  expect_error(img$tile(0L), "nrow must be a single positive integer")
})

test_that("$tile() errors on ncol < 1", {
  img <- Image$zeros(2L, 2L)
  expect_error(img$tile(2L, 0L), "ncol must be a single positive integer")
})
