# Compute an automatic threshold value from an image

Returns the numeric threshold value computed by one of the 17 ImageJ
Auto Threshold algorithms, without modifying the image.

## Usage

``` r
autothreshold_value(img, method, bins = 256L)
```

## Arguments

- img:

  A single-channel `Image` object.

- method:

  A lowercase string naming one of the 17 supported methods: `"imagej"`,
  `"huang"`, `"huang2"`, `"intermodes"`, `"isodata"`, `"li"`,
  `"maxentropy"`, `"mean"`, `"minerrori"`, `"minimum"`, `"moments"`,
  `"otsu"`, `"percentile"`, `"renyientropy"`, `"shanbhag"`,
  `"triangle"`, `"yen"`.

- bins:

  Integer \>= 2. Histogram bin count used when the image depth is not
  `CV_8U`. Ignored for `CV_8U` images (always 256 bins). Default `256`.

## Value

A single numeric (double) — the threshold in the image's native
intensity units.
