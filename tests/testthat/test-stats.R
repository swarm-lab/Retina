# make_test_image() → 10x10 BGR, all pixels = (B=100, G=150, R=200)

# ── Uniform image ────────────────────────────────────────────────────────────

test_that("mean() returns named per-channel means", {
  img <- make_test_image()
  expect_equal(img$mean(), c(B = 100, G = 150, R = 200))
})

test_that("min() returns named per-channel minimums", {
  img <- make_test_image()
  expect_equal(img$min(), c(B = 100, G = 150, R = 200))
})

test_that("max() returns named per-channel maximums", {
  img <- make_test_image()
  expect_equal(img$max(), c(B = 100, G = 150, R = 200))
})

test_that("sd() returns near-zero for uniform image", {
  img <- make_test_image()
  expect_equal(img$sd(), c(B = 0, G = 0, R = 0), tolerance = 1e-5)
})

test_that("var() returns near-zero for uniform image", {
  img <- make_test_image()
  expect_equal(img$var(), c(B = 0, G = 0, R = 0), tolerance = 1e-5)
})

test_that("sum() returns pixel count times channel value", {
  img <- make_test_image()  # 10x10 = 100 pixels
  expect_equal(img$sum(), c(B = 10000, G = 15000, R = 20000))
})

test_that("median() returns named per-channel medians", {
  img <- make_test_image()
  expect_equal(img$median(), c(B = 100, G = 150, R = 200))
})

test_that("quantile() with multiple probs returns correctly shaped matrix", {
  img <- make_test_image()
  result <- img$quantile(c(0, 0.5, 1))
  expect_true(is.matrix(result))
  expect_equal(dim(result), c(3L, 3L))
  expect_equal(rownames(result), c("0%", "50%", "100%"))
  expect_equal(colnames(result), c("B", "G", "R"))
  expect_equal(result["0%",   ], c(B = 100, G = 150, R = 200))
  expect_equal(result["50%",  ], c(B = 100, G = 150, R = 200))
  expect_equal(result["100%", ], c(B = 100, G = 150, R = 200))
})

# ── Non-uniform image (1x2 BGR) ──────────────────────────────────────────────
# B: pixels = 0, 100  → mean=50, sd=50 (population), var=2500
# G: pixels = 50, 150 → mean=100
# R: pixels = 100, 200 → mean=150

make_nonuniform <- function() {
  arr <- array(0L, dim = c(1L, 2L, 3L))
  arr[1, 1, 1] <- 0L;   arr[1, 2, 1] <- 100L  # B
  arr[1, 1, 2] <- 50L;  arr[1, 2, 2] <- 150L  # G
  arr[1, 1, 3] <- 100L; arr[1, 2, 3] <- 200L  # R
  Image$new(arr)
}

test_that("mean() is correct for non-uniform image", {
  img <- make_nonuniform()
  expect_equal(img$mean(), c(B = 50, G = 100, R = 150))
})

test_that("sd() uses population standard deviation", {
  img <- make_nonuniform()
  expect_equal(img$sd(), c(B = 50, G = 50, R = 50))
})

test_that("var() equals sd squared", {
  img <- make_nonuniform()
  expect_equal(img$var(), c(B = 2500, G = 2500, R = 2500))
})

test_that("quantile(0.25) interpolates correctly", {
  # B: [0, 100], idx=0.25*(2-1)=0.25 → 0 + 0.25*100 = 25
  # G: [50, 150], idx=0.25 → 50 + 0.25*100 = 75
  # R: [100, 200], idx=0.25 → 100 + 0.25*100 = 125
  img <- make_nonuniform()
  result <- img$quantile(0.25)
  expect_equal(dim(result), c(1L, 3L))
  expect_equal(result["25%", "B"], 25)
  expect_equal(result["25%", "G"], 75)
  expect_equal(result["25%", "R"], 125)
})

# ── Named outputs ────────────────────────────────────────────────────────────

test_that("all stat methods return names matching BGR colorspace", {
  img <- make_test_image()
  expect_equal(names(img$mean()),   c("B", "G", "R"))
  expect_equal(names(img$min()),    c("B", "G", "R"))
  expect_equal(names(img$max()),    c("B", "G", "R"))
  expect_equal(names(img$sd()),     c("B", "G", "R"))
  expect_equal(names(img$var()),    c("B", "G", "R"))
  expect_equal(names(img$sum()),    c("B", "G", "R"))
  expect_equal(names(img$median()), c("B", "G", "R"))
})

test_that("stat methods return 'Y' name for grayscale image", {
  img <- make_test_image()$to_gray()
  expect_equal(names(img$mean()), "Y")
})

test_that("quantile() rownames are formatted as percentages", {
  img <- make_test_image()
  result <- img$quantile(c(0.25, 0.75))
  expect_equal(rownames(result), c("25%", "75%"))
  expect_equal(colnames(result), c("B", "G", "R"))
})

test_that("quantile() throws for probs > 1", {
  img <- make_test_image()
  expect_snapshot(error = TRUE, img$quantile(1.1))
})

test_that("quantile() throws for probs < 0", {
  img <- make_test_image()
  expect_snapshot(error = TRUE, img$quantile(-0.1))
})
