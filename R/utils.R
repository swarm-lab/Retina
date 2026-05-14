rt_channel_names <- function(colorspace, nchan) {
  nm <- switch(colorspace,
    BGR   = c("B", "G", "R"),
    RGB   = c("R", "G", "B"),
    HSV   = c("H", "S", "V"),
    LAB   = c("L", "A", "B"),
    HLS   = c("H", "L", "S"),
    GRAY  = "GRAY",
    YCrCb = c("Y", "Cr", "Cb"),
    as.character(seq_len(nchan))
  )
  nm[seq_len(nchan)]
}
