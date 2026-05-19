rt_channel_names <- function(colorspace, nchan) {
  nm <- switch(colorspace,
    BGR   = c("B", "G", "R"),
    BGRA  = c("B", "G", "R", "A"),
    RGB   = c("R", "G", "B"),
    RGBA  = c("R", "G", "B", "A"),
    HSV   = c("H", "S", "V"),
    LAB   = c("L", "A", "B"),
    HLS   = c("H", "L", "S"),
    GRAY  = "Y",
    YCrCb = c("Y", "Cr", "Cb"),
    as.character(seq_len(nchan))
  )
  nm[seq_len(nchan)]
}

.rt_ptr <- function(img) img$.__enclos_env__$private$.ptr

.rt_arith <- function(ptr, other, nchan, self_depth, img_fn, scalar_fn) {
  if (inherits(other, "Image")) {
    if (other$depth != self_depth)
      stop("images must have the same depth", call. = FALSE)
    img_fn(ptr, .rt_ptr(other))
  } else if (is.numeric(other)) {
    if (length(other) != 1L && length(other) != nchan)
      stop("values must be length 1 or length nchan", call. = FALSE)
    scalar_fn(ptr, as.double(other))
  } else {
    stop("other must be an Image or a numeric vector", call. = FALSE)
  }
}

.rt_infer_ddepth <- function(depth_name) {
  switch(depth_name,
    CV_8U  = "CV_16S",
    CV_16U = "CV_32F",
    CV_16S = "CV_32F",
    CV_32F = "CV_32F",
    CV_64F = "CV_64F",
    stop("No ddepth inference for depth '", depth_name, "'", call. = FALSE)
  )
}
