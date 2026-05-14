#include "retina_image.h"
#include <opencv2/opencv.hpp>
using namespace cpp11;

[[cpp11::register]]
bool rt_has_module(std::string module_name) {
  std::string build_info = cv::getBuildInformation();
  return build_info.find(module_name) != std::string::npos;
}

[[cpp11::register]]
bool rt_has_cuda() {
#ifdef HAVE_CUDA
  return cv::cuda::getCudaEnabledDeviceCount() > 0;
#else
  return false;
#endif
}
