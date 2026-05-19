img_gray <- function() {
  arr <- array(c(rep(0L, 50L), rep(255L, 50L)), dim = c(10L, 10L, 1L))
  Image$new(arr, colorspace = "GRAY", depth = "CV_8U")
}

# ── structural checks ─────────────────────────────────────────────────────────

test_that("morph('open') returns correct dimensions and depth", {
  img <- img_gray()
  result <- img$morph("open")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$nchan, img$nchan)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("morph('close') returns correct dimensions and depth", {
  img <- img_gray()
  result <- img$morph("close")
  expect_equal(result$nrow, img$nrow)
  expect_equal(result$ncol, img$ncol)
  expect_equal(result$depth_name, "CV_8U")
})

test_that("morph('tophat') returns correct dimensions", {
  result <- img_gray()$morph("tophat")
  expect_equal(result$nrow, 10L)
  expect_equal(result$ncol, 10L)
})

test_that("morph('blackhat') returns correct dimensions", {
  result <- img_gray()$morph("blackhat")
  expect_equal(result$nrow, 10L)
  expect_equal(result$ncol, 10L)
})

test_that("morph() with border_type = 'constant' runs without error", {
  expect_no_error(img_gray()$morph("erode", border_type = "constant"))
})

test_that("morph() rejects 'wrap' border_type (unsupported by OpenCV)", {
  expect_snapshot(error = TRUE, img_gray()$morph("erode", border_type = "wrap"))
})

# ── semantic checks ───────────────────────────────────────────────────────────

test_that("morph('erode') shrinks bright region (lower mean)", {
  img <- img_gray()
  result <- img$morph("erode")
  expect_lt(mean(result$to_array()), mean(img$to_array()))
})

test_that("morph('dilate') expands bright region (higher mean)", {
  img <- img_gray()
  result <- img$morph("dilate")
  expect_gt(mean(result$to_array()), mean(img$to_array()))
})

test_that("morph('gradient') produces non-zero output near edge", {
  result <- img_gray()$morph("gradient")
  expect_gt(max(result$to_array()), 0L)
})

# ── iterations ────────────────────────────────────────────────────────────────

test_that("iterations = 2 erodes more than iterations = 1", {
  img <- img_gray()
  r1 <- img$morph("erode", iterations = 1L)
  r2 <- img$morph("erode", iterations = 2L)
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
  expect_snapshot(error = TRUE, img_gray()$morph("blur"))
})

test_that("invalid shape errors", {
  expect_snapshot(error = TRUE, img_gray()$morph("erode", shape = "diamond"))
})

test_that("even size errors", {
  expect_snapshot(error = TRUE, img_gray()$morph("erode", size = 4L))
})

test_that("non-matrix kernel errors", {
  expect_snapshot(error = TRUE, img_gray()$morph("erode", kernel = c(1, 0, 1)))
})

test_that("invalid border_type errors", {
  expect_snapshot(error = TRUE, img_gray()$morph("erode", border_type = "padded"))
})

test_that("morph() with kernel skips shape validation", {
  k <- matrix(c(0L, 1L, 0L, 1L, 1L, 1L, 0L, 1L, 0L), nrow = 3L)
  expect_no_error(img_gray()$morph("erode", shape = "diamond", kernel = k))
})

test_that("morph() with kernel skips size validation", {
  k <- matrix(c(0L, 1L, 0L, 1L, 1L, 1L, 0L, 1L, 0L), nrow = 3L)
  expect_no_error(img_gray()$morph("erode", size = 4L, kernel = k))
})

test_that("morph_() with kernel skips shape validation", {
  k <- matrix(c(0L, 1L, 0L, 1L, 1L, 1L, 0L, 1L, 0L), nrow = 3L)
  img <- img_gray()
  expect_no_error(img$morph_("erode", shape = "diamond", kernel = k))
})
