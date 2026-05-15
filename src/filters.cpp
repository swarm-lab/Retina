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

// ── blur ──────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_blur(
    external_pointer<RtImage> img, int ksize_w, int ksize_h) {
  cv::Mat dst;
  cv::blur(get_cpu_mat(img), dst, cv::Size(ksize_w, ksize_h));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── gaussian_blur ─────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_gaussian_blur(
    external_pointer<RtImage> img,
    int ksize_w, int ksize_h,
    double sigma_x, double sigma_y) {
  cv::Mat dst;
  cv::GaussianBlur(get_cpu_mat(img), dst, cv::Size(ksize_w, ksize_h),
                   sigma_x, sigma_y);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── median_blur ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_median_blur(
    external_pointer<RtImage> img, int ksize) {
  cv::Mat dst;
  cv::medianBlur(get_cpu_mat(img), dst, ksize);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── bilateral_filter ──────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_bilateral_filter(
    external_pointer<RtImage> img,
    int d, double sigma_color, double sigma_space) {
  cv::Mat dst;
  cv::bilateralFilter(get_cpu_mat(img), dst, d, sigma_color, sigma_space);
  return {new RtImage(std::move(dst), img->colorspace)};
}
