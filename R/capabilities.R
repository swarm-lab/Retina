.rt_caps <- new.env(parent = emptyenv())

require_module <- function(module) {
  if (!isTRUE(.rt_caps[[module]])) {
    stop(
      "This function requires the '", module, "' OpenCV module, ",
      "which is not available in your current OpenCV installation.\n",
      "See ?retina_install for instructions on installing optional modules.",
      call. = FALSE
    )
  }
}
