.onLoad <- function(libname, pkgname) {
  .rt_caps$imgproc    <- rt_has_module("imgproc")
  .rt_caps$features2d <- rt_has_module("features2d")
  .rt_caps$calib3d    <- rt_has_module("calib3d")
  .rt_caps$ximgproc   <- rt_has_module("ximgproc")
  .rt_caps$cuda       <- rt_has_cuda()
}
