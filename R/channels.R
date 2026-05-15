.channel_names <- list(
  BGR   = c("B", "G", "R"),
  BGRA  = c("B", "G", "R", "A"),
  RGB   = c("R", "G", "B"),
  RGBA  = c("R", "G", "B", "A"),
  GRAY  = c("Y"),
  HSV   = c("H", "S", "V"),
  HLS   = c("H", "L", "S"),
  LAB   = c("L", "A", "B"),
  YCrCb = c("Y", "Cr", "Cb")
)

#' Split an image into its individual channels
#'
#' @param img An \code{Image} object.
#' @return A named list of single-channel \code{Image} objects. Names are
#'   derived from the colorspace (e.g. \code{c("B", "G", "R")} for BGR).
#'   Unknown colorspaces use \code{"ch1"}, \code{"ch2"}, etc.
#' @examples
#' \donttest{
#' img <- Image$new(system.file("img", "flower.jpg", package = "Retina"))
#' channels <- split_channels(img)
#' channels$B$plot()
#' }
#' @export
split_channels <- function(img) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  raw <- rt_image_split_channels(.rt_ptr(img))
  channels <- lapply(raw, function(ptr) Image$new(ptr))
  nms <- .channel_names[[img$colorspace]]
  if (is.null(nms))
    nms <- paste0("ch", seq_along(channels))
  names(channels) <- nms
  channels
}

#' Merge a list of single-channel images into a multi-channel image
#'
#' @param channels A named list of single-channel \code{Image} objects with
#'   equal dimensions and depth. Names are used to infer the output colorspace.
#' @return A new \code{Image}. Colorspace is inferred from \code{names(channels)};
#'   if unrecognised, colorspace is set to \code{"UNKNOWN"} with a warning.
#' @examples
#' \donttest{
#' img <- Image$new(system.file("img", "flower.jpg", package = "Retina"))
#' channels <- split_channels(img)
#' reconstructed <- merge_channels(channels)
#' reconstructed$plot()
#' }
#' @export
merge_channels <- function(channels) {
  if (!is.list(channels) || length(channels) == 0L ||
      !all(vapply(channels, inherits, logical(1L), "Image")) ||
      !all(vapply(channels, function(x) x$nchan == 1L, logical(1L))))
    stop("channels must be a non-empty list of single-channel Image objects",
         call. = FALSE)
  nrows <- vapply(channels, function(x) x$nrow, integer(1L))
  ncols <- vapply(channels, function(x) x$ncol, integer(1L))
  if (length(unique(nrows)) > 1L || length(unique(ncols)) > 1L)
    stop("all channels must have the same dimensions", call. = FALSE)
  depths <- vapply(channels, function(x) x$depth, integer(1L))
  if (length(unique(depths)) > 1L)
    stop("all channels must have the same depth", call. = FALSE)
  nms <- names(channels)
  colorspace <- "UNKNOWN"
  if (!is.null(nms)) {
    for (cs in names(.channel_names)) {
      if (identical(nms, .channel_names[[cs]])) {
        colorspace <- cs
        break
      }
    }
  }
  if (colorspace == "UNKNOWN")
    warning("channel names do not match a known colorspace; colorspace set to 'UNKNOWN'",
            call. = FALSE)
  Image$new(rt_image_merge_channels(lapply(channels, .rt_ptr), colorspace))
}
