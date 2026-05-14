#include "retina_image.h"
#include <opencv2/opencv.hpp>
#include <map>
#include <utility>
#include <string>
using namespace cpp11;

static const std::map<std::pair<std::string,std::string>, int> kColorConvCodes = {
  {{"BGR",  "GRAY"},  cv::COLOR_BGR2GRAY},
  {{"BGR",  "RGB"},   cv::COLOR_BGR2RGB},
  {{"BGR",  "HSV"},   cv::COLOR_BGR2HSV},
  {{"BGR",  "LAB"},   cv::COLOR_BGR2Lab},
  {{"BGR",  "HLS"},   cv::COLOR_BGR2HLS},
  {{"BGR",  "YCrCb"}, cv::COLOR_BGR2YCrCb},
  {{"GRAY", "BGR"},   cv::COLOR_GRAY2BGR},
  {{"GRAY", "RGB"},   cv::COLOR_GRAY2RGB},
  {{"RGB",  "GRAY"},  cv::COLOR_RGB2GRAY},
  {{"RGB",  "BGR"},   cv::COLOR_RGB2BGR},
  {{"RGB",  "HSV"},   cv::COLOR_RGB2HSV},
  {{"RGB",  "LAB"},   cv::COLOR_RGB2Lab},
  {{"HSV",  "BGR"},   cv::COLOR_HSV2BGR},
  {{"LAB",  "BGR"},   cv::COLOR_Lab2BGR},
};

[[cpp11::register]]
external_pointer<RtImage> rt_image_convert_color(
    external_pointer<RtImage> img,
    std::string from_cs,
    std::string to_cs) {

  auto key = std::make_pair(from_cs, to_cs);
  auto it = kColorConvCodes.find(key);
  if (it == kColorConvCodes.end())
    stop("unsupported color space conversion: %s -> %s",
         from_cs.c_str(), to_cs.c_str());

  cv::Mat src;
  if (img->is_gpu()) {
    std::get<cv::UMat>(img->buffer).copyTo(src);
  } else {
    src = std::get<cv::Mat>(img->buffer);
  }

  cv::Mat dst;
  cv::cvtColor(src, dst, it->second);
  return {new RtImage(std::move(dst), to_cs)};
}
