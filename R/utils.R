rt_channel_names <- function(colorspace, nchan) {
  nm <- switch(colorspace,
    BGR   = c("B", "G", "R"),
    BGRA  = c("B", "G", "R", "A"),
    RGB   = c("R", "G", "B"),
    RGBA  = c("R", "G", "B", "A"),
    HSV   = c("H", "S", "V"),
    LAB   = c("L", "A", "B"),
    HLS   = c("H", "L", "S"),
    GRAY  = "GRAY",
    YCrCb = c("Y", "Cr", "Cb"),
    as.character(seq_len(nchan))
  )
  nm[seq_len(nchan)]
}
