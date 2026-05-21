# Image$zeros() errors on nrow < 1

    Code
      Image$zeros(0L, 4L)
    Condition
      Error:
      ! nrow must be a single positive integer

# Image$zeros() errors on nchan > 4

    Code
      Image$zeros(3L, 4L, nchan = 5L)
    Condition
      Error:
      ! nchan must be a single positive integer <= 4

# Image$zeros() errors on invalid depth

    Code
      Image$zeros(3L, 4L, depth = "CV_128U")
    Condition
      Error:
      ! depth must be one of: CV_8U, CV_16U, CV_16S, CV_32F, CV_64F

# Image$randu() errors when low >= high

    Code
      Image$randu(3L, 3L, low = 5, high = 5)
    Condition
      Error:
      ! low must be strictly less than high

# Image$randn() errors when sd <= 0

    Code
      Image$randn(3L, 3L, sd = -1)
    Message
      Using default mean/sd [128, -1] for CV_8U. Provide both 'mean' and 'sd' explicitly to suppress this message.
    Condition
      Error:
      ! sd must be a single positive finite numeric

# Image$ones() errors on invalid ncol

    Code
      Image$ones(3L, 0L)
    Condition
      Error:
      ! ncol must be a single positive integer

# border() errors on invalid type

    Code
      img$border(1L, type = "invalid")
    Condition
      Error:
      ! type must be one of: constant, reflect, reflect_101, replicate, wrap

# border() errors on negative width

    Code
      img$border(-1L)
    Condition
      Error:
      ! top must be a single non-negative integer

# border() errors on empty value vector

    Code
      img$border(1L, value = numeric(0))
    Condition
      Error:
      ! value must be a non-empty numeric vector with no NAs

# border_() errors on invalid type

    Code
      img$border_(1L, type = "bad")
    Condition
      Error:
      ! type must be one of: constant, reflect, reflect_101, replicate, wrap

# border() rejects 'default' as a type

    Code
      img$border(1L, type = "default")
    Condition
      Error:
      ! type must be one of: constant, reflect, reflect_101, replicate, wrap

# Image$fill() errors on mismatched value length

    Code
      Image$fill(c(1, 2), 3L, 3L, 3L)
    Condition
      Error:
      ! value length (2) must equal nchan (3) or be 1

# Image$fill() errors on NA value

    Code
      Image$fill(NA_real_, 3L, 3L)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector (length 1-4) with no NAs

# Image$fill() errors on empty value

    Code
      Image$fill(numeric(0), 3L, 3L)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector (length 1-4) with no NAs

# Image$fill() errors on non-finite value (Inf)

    Code
      Image$fill(Inf, 3L, 3L)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector (length 1-4) with no NAs

# border_() rejects 'default' as a type

    Code
      img$border_(1L, type = "default")
    Condition
      Error:
      ! type must be one of: constant, reflect, reflect_101, replicate, wrap

# $sobel() rejects 'default' as border_type

    Code
      img$sobel(1L, 0L, border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# $laplacian() rejects 'default' as border_type

    Code
      img$laplacian(border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# $morph() rejects 'default' as border_type

    Code
      img$morph("erode", border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant

# $warp_affine() rejects 'default' as border_type

    Code
      img$warp_affine(m, border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant, wrap

# $warp_perspective() rejects 'default' as border_type

    Code
      img$warp_perspective(m, border_type = "default")
    Condition
      Error:
      ! border_type must be one of: reflect, reflect_101, replicate, constant, wrap

# $tile() errors on nrow < 1

    Code
      img$tile(0L)
    Condition
      Error:
      ! nrow must be a single positive integer

# $tile() errors on ncol < 1

    Code
      img$tile(2L, 0L)
    Condition
      Error:
      ! ncol must be a single positive integer

# $tile() errors on non-integer nrow (e.g., 1.5)

    Code
      img$tile(1.5)
    Condition
      Error:
      ! nrow must be a single positive integer

# $tile() errors on NA nrow

    Code
      img$tile(NA_integer_)
    Condition
      Error:
      ! nrow must be a single positive integer

# $tile() errors on Inf nrow

    Code
      img$tile(Inf)
    Condition
      Warning in `isTRUE()`:
      NAs introduced by coercion to integer range
      Error:
      ! nrow must be a single positive integer

# $tile() errors on non-integer ncol (e.g., 2.7)

    Code
      img$tile(2L, 2.7)
    Condition
      Error:
      ! ncol must be a single positive integer

# $tile() errors on NA ncol

    Code
      img$tile(2L, NA_integer_)
    Condition
      Error:
      ! ncol must be a single positive integer

# $tile() errors on Inf ncol

    Code
      img$tile(2L, Inf)
    Condition
      Warning in `isTRUE()`:
      NAs introduced by coercion to integer range
      Error:
      ! ncol must be a single positive integer

# $set_to() errors on NA value

    Code
      img$set_to(NA_real_)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector with no NAs

# $set_to() errors when mask has wrong depth

    Code
      img$set_to(255, mask = bad_mask)
    Condition
      Error:
      ! mask must be a single-channel CV_8U Image with the same dimensions as self

# $set_to() errors when mask has wrong dimensions

    Code
      img$set_to(255, mask = bad_mask)
    Condition
      Error:
      ! mask must be a single-channel CV_8U Image with the same dimensions as self

# $set_to() errors when mask has more than 1 channel

    Code
      img$set_to(255, mask = bad_mask)
    Condition
      Error:
      ! mask must be a single-channel CV_8U Image with the same dimensions as self

# $set_to_() errors on NA value

    Code
      img$set_to_(NA_real_)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector with no NAs

# $set_to_() errors when mask has wrong depth

    Code
      img$set_to_(255, mask = bad_mask)
    Condition
      Error:
      ! mask must be a single-channel CV_8U Image with the same dimensions as self

# $set_to() errors on Inf value

    Code
      img$set_to(Inf)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector with no NAs

# $set_to_() errors on Inf value

    Code
      img$set_to_(-Inf)
    Condition
      Error:
      ! value must be a non-empty finite numeric vector with no NAs

# concatenate() errors on fewer than 2 images

    Code
      concatenate(list(a), "h")
    Condition
      Error:
      ! imgs must be a list of at least 2 Image objects

# concatenate() errors on mismatched depth

    Code
      concatenate(list(a, b), "h")
    Condition
      Error:
      ! all images must have the same depth

# concatenate() horizontal errors on mismatched nrow

    Code
      concatenate(list(a, b), "h")
    Condition
      Error:
      ! for horizontal concatenation all images must have the same nrow

# concatenate() vertical errors on mismatched ncol

    Code
      concatenate(list(a, b), "v")
    Condition
      Error:
      ! for vertical concatenation all images must have the same ncol

# concatenate() errors on invalid axis

    Code
      concatenate(list(a, b), "diagonal")
    Condition
      Error:
      ! axis must be one of: h, horizontal, v, vertical

# concatenate() errors on mismatched nchan

    Code
      concatenate(list(a, b), "h")
    Condition
      Error:
      ! all images must have the same nchan

