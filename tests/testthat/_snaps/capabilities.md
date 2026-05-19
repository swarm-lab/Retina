# require_module() stops with informative error for absent module

    Code
      Retina:::require_module("__nonexistent_module__")
    Condition
      Error:
      ! This function requires the '__nonexistent_module__' OpenCV module, which is not available in your current OpenCV installation.
      See ?retina_install for instructions on installing optional modules.

