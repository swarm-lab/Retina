img_gray <- function() {
  arr <- array(c(rep(0L, 50L), rep(255L, 50L)), dim = c(10L, 10L, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

# ── structural checks ─────────────────────────────────────────────────────────

test_that("morph_open() returns correct dimensions and depth", {
  img <- img_gray()
  result <- morph_open(img)
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("morph_close() returns correct dimensions and depth", {
  img <- img_gray()
  result <- morph_close(img)
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("morph_tophat() returns correct dimensions", {
  result <- morph_tophat(img_gray())
  expect_equal(result$nrow, 10L)
  expect_equal(result$ncol, 10L)
})

test_that("morph_blackhat() returns correct dimensions", {
  result <- morph_blackhat(img_gray())
  expect_equal(result$nrow, 10L)
  expect_equal(result$ncol, 10L)
})

# ── semantic checks ───────────────────────────────────────────────────────────

test_that("morph_erode() shrinks bright region (lower mean)", {
  img <- img_gray()
  result <- morph_erode(img)
  expect_lt(mean(result$to_array()), mean(img$to_array()))
})

test_that("morph_dilate() expands bright region (higher mean)", {
  img <- img_gray()
  result <- morph_dilate(img)
  expect_gt(mean(result$to_array()), mean(img$to_array()))
})

test_that("morph_gradient() produces non-zero output near edge", {
  result <- morph_gradient(img_gray())
  expect_gt(max(result$to_array()), 0L)
})

# ── iterations ────────────────────────────────────────────────────────────────

test_that("iterations = 2 erodes more than iterations = 1", {
  img <- img_gray()
  r1 <- morph_erode(img, iterations = 1L)
  r2 <- morph_erode(img, iterations = 2L)
  expect_lt(mean(r2$to_array()), mean(r1$to_array()))
})

# ── custom kernel ─────────────────────────────────────────────────────────────

test_that("custom kernel matrix is accepted and produces output", {
  img <- img_gray()
  k <- matrix(c(0L, 1L, 0L, 1L, 1L, 1L, 0L, 1L, 0L), nrow = 3L, ncol = 3L)
  expect_no_error(result <- img$morph("dilate", kernel = k))
  expect_equal(result$nrow, img$nrow)
})

# ── in-place ──────────────────────────────────────────────────────────────────

test_that("morph_() in-place gives same result as morph()", {
  img <- img_gray()
  expected <- img$morph("erode")
  img$morph_("erode")
  expect_equal(img$to_array(), expected$to_array())
})

# ── validation errors ─────────────────────────────────────────────────────────

test_that("invalid operation errors", {
  expect_error(img_gray()$morph("blur"),
               "operation must be one of")
})

test_that("invalid shape errors", {
  expect_error(img_gray()$morph("erode", shape = "diamond"),
               "shape must be one of")
})

test_that("even size errors", {
  expect_error(img_gray()$morph("erode", size = 4L),
               "size must be a single positive odd integer")
})

test_that("non-matrix kernel errors", {
  expect_error(img_gray()$morph("erode", kernel = c(1, 0, 1)),
               "kernel must be a numeric matrix")
})

test_that("invalid border_type errors", {
  expect_error(img_gray()$morph("erode", border_type = "padded"),
               "border_type must be one of")
})

test_that("non-Image input to morph_erode() errors", {
  expect_error(morph_erode(42))
})
