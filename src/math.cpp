#include "retina_image.h"
#include <opencv2/opencv.hpp>
using namespace cpp11;

static cv::Mat get_cpu_mat(const external_pointer<RtImage>& img) {
  if (img->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(img->buffer).copyTo(m);
    return m;
  }
  return std::get<cv::Mat>(img->buffer);
}

// ── rt_pow ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_pow(external_pointer<RtImage> img, double power) {
  cv::Mat dst;
  cv::pow(get_cpu_mat(img), power, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── rt_exp ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_exp(external_pointer<RtImage> img) {
  cv::Mat dst;
  cv::exp(get_cpu_mat(img), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── rt_log ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_log(external_pointer<RtImage> img) {
  cv::Mat dst;
  cv::log(get_cpu_mat(img), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── rt_sqrt ───────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_sqrt(external_pointer<RtImage> img) {
  cv::Mat dst;
  cv::sqrt(get_cpu_mat(img), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}
