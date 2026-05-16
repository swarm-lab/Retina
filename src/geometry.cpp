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

// ── resize ────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_resize(
    external_pointer<RtImage> img,
    int width, int height, double fx, double fy, int interp_int) {
  cv::Mat dst;
  if (width > 0) {
    cv::resize(get_cpu_mat(img), dst, cv::Size(width, height), 0, 0, interp_int);
  } else {
    if (fx <= 0 || fy <= 0)
      stop("fx and fy must be positive");
    cv::resize(get_cpu_mat(img), dst, cv::Size(0, 0), fx, fy, interp_int);
  }
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── rotate ────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_rotate(
    external_pointer<RtImage> img,
    double angle, double cx, double cy,
    double scale, int interp_int, int border_int) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat M = cv::getRotationMatrix2D(
    cv::Point2f(static_cast<float>(cx - 1.0), static_cast<float>(cy - 1.0)),
    angle, scale);
  cv::Mat dst;
  cv::warpAffine(src, dst, M, cv::Size(src.cols, src.rows), interp_int, border_int);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── flip ──────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_flip(
    external_pointer<RtImage> img, int flip_code) {
  cv::Mat dst;
  cv::flip(get_cpu_mat(img), dst, flip_code);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── crop ──────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_crop(
    external_pointer<RtImage> img,
    int x1, int y1, int x2, int y2) {
  cv::Mat src = get_cpu_mat(img);
  if (x1 < 1 || y1 < 1 || x2 > src.cols || y2 > src.rows || x2 <= x1 || y2 <= y1)
    stop("crop coordinates are out of bounds or invalid");
  cv::Mat roi = src(cv::Rect(x1 - 1, y1 - 1, x2 - x1 + 1, y2 - y1 + 1)).clone();
  return {new RtImage(std::move(roi), img->colorspace)};
}
