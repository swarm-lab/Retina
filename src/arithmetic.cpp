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

static cv::Scalar to_scalar(const doubles& v) {
  if (v.size() == 1) return cv::Scalar::all(v[0]);
  return cv::Scalar(
    v[0],
    v.size() > 1 ? v[1] : 0.0,
    v.size() > 2 ? v[2] : 0.0,
    v.size() > 3 ? v[3] : 0.0);
}

// ── add ───────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_add_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::add(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_add_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat dst;
  cv::add(get_cpu_mat(img), to_scalar(values), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── subtract ──────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_subtract_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::subtract(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_subtract_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat dst;
  cv::subtract(get_cpu_mat(img), to_scalar(values), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── multiply ──────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_multiply_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::multiply(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_multiply_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat scalar_mat(src.size(), src.type(), to_scalar(values));
  cv::Mat dst;
  cv::multiply(src, scalar_mat, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── divide ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_divide_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::divide(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_divide_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat scalar_mat(src.size(), src.type(), to_scalar(values));
  cv::Mat dst;
  cv::divide(src, scalar_mat, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── absdiff ───────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_absdiff_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::absdiff(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_absdiff_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat dst;
  cv::absdiff(get_cpu_mat(img), to_scalar(values), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── add_weighted ──────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_add_weighted(
    external_pointer<RtImage> img1, double alpha,
    external_pointer<RtImage> img2, double beta,
    double gamma_val) {
  cv::Mat dst;
  cv::addWeighted(get_cpu_mat(img1), alpha, get_cpu_mat(img2), beta, gamma_val, dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

// ── bitwise_and ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_and_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::bitwise_and(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_and_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat scalar_mat(src.size(), src.type(), to_scalar(values));
  cv::Mat dst;
  cv::bitwise_and(src, scalar_mat, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── bitwise_or ────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_or_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::bitwise_or(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_or_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat scalar_mat(src.size(), src.type(), to_scalar(values));
  cv::Mat dst;
  cv::bitwise_or(src, scalar_mat, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── bitwise_xor ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_xor_image(
    external_pointer<RtImage> img1, external_pointer<RtImage> img2) {
  cv::Mat dst;
  cv::bitwise_xor(get_cpu_mat(img1), get_cpu_mat(img2), dst);
  return {new RtImage(std::move(dst), img1->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_xor_scalar(
    external_pointer<RtImage> img, doubles values) {
  cv::Mat src = get_cpu_mat(img);
  cv::Mat scalar_mat(src.size(), src.type(), to_scalar(values));
  cv::Mat dst;
  cv::bitwise_xor(src, scalar_mat, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── bitwise_not ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_bitwise_not(external_pointer<RtImage> img) {
  cv::Mat dst;
  cv::bitwise_not(get_cpu_mat(img), dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}
