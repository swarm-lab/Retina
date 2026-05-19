# merge_channels() errors on mismatched dimensions

    Code
      merge_channels(list(a, b))
    Condition
      Error:
      ! all channels must have the same dimensions

# merge_channels() errors on mismatched depth

    Code
      merge_channels(list(a, b))
    Condition
      Error:
      ! all channels must have the same depth

# merge_channels() errors on multi-channel input element

    Code
      merge_channels(list(img_bgr()))
    Condition
      Error:
      ! channels must be a non-empty list of single-channel Image objects

# split_channels() errors on non-Image input

    Code
      split_channels(42)
    Condition
      Error:
      ! img must be an Image object

