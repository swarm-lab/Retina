#' Erode an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("erode", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_erode(img)$plot()
#' }
#' @export
morph_erode <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("erode", ...)
}

#' Dilate an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("dilate", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_dilate(img)$plot()
#' }
#' @export
morph_dilate <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("dilate", ...)
}

#' Apply morphological opening to an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("open", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_open(img)$plot()
#' }
#' @export
morph_open <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("open", ...)
}

#' Apply morphological closing to an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("close", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_close(img)$plot()
#' }
#' @export
morph_close <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("close", ...)
}

#' Compute the morphological gradient of an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("gradient", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_gradient(img)$plot()
#' }
#' @export
morph_gradient <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("gradient", ...)
}

#' Apply top-hat morphological transform to an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("tophat", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_tophat(img)$plot()
#' }
#' @export
morph_tophat <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("tophat", ...)
}

#' Apply black-hat morphological transform to an image
#'
#' @param img An \code{Image} object.
#' @param ... Passed to \code{img$morph("blackhat", ...)}.
#' @return A new \code{Image}.
#' @examples
#' \donttest{
#' img_path <- system.file("img", "flower.jpg", package = "Retina")
#' img <- Image$new(img_path)$convert_color("GRAY")
#' morph_blackhat(img)$plot()
#' }
#' @export
morph_blackhat <- function(img, ...) {
  if (!inherits(img, "Image"))
    stop("img must be an Image object", call. = FALSE)
  img$morph("blackhat", ...)
}
