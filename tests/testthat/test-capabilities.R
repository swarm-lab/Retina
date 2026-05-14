test_that(".rt_caps is populated after package load", {
  expect_true(exists("cuda", envir = Retina:::.rt_caps))
  expect_type(Retina:::.rt_caps$cuda, "logical")
})

test_that("require_module() stops with informative error for absent module", {
  expect_error(
    Retina:::require_module("__nonexistent_module__"),
    regexp = "__nonexistent_module__"
  )
})

test_that("require_module() is silent for a present module (core)", {
  # "imgproc" is always present in OpenCV core builds
  expect_no_error(Retina:::require_module("imgproc"))
})
