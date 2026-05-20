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

.rt_arith <- function(ptr, other, nchan, self_depth,
                      img_fn, scalar_fn,
                      img_fn_masked = NULL, scalar_fn_masked = NULL,
                      mask = NULL) {
  if (inherits(other, "Image")) {
    if (other$depth != self_depth)
      stop("images must have the same depth", call. = FALSE)
    if (is.null(mask))
      img_fn(ptr, .rt_ptr(other))
    else
      img_fn_masked(ptr, .rt_ptr(other), .rt_ptr(mask))
  } else if (is.numeric(other)) {
    if (length(other) != 1L && length(other) != nchan)
      stop("values must be length 1 or length nchan", call. = FALSE)
    if (is.null(mask))
      scalar_fn(ptr, as.double(other))
    else
      scalar_fn_masked(ptr, as.double(other), .rt_ptr(mask))
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

.rt_valid_mask <- function(mask, img) {
  if (is.null(mask)) return(invisible(NULL))
  if (!inherits(mask, "Image") ||
      mask$nchan != 1L ||
      mask$depth_name != "CV_8U" ||
      mask$nrow != img$nrow ||
      mask$ncol != img$ncol)
    stop("mask must be a single-channel CV_8U Image with the same dimensions as self",
         call. = FALSE)
}
