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

// ── Shared helpers ────────────────────────────────────────────────────────────

static int cv_border_type(const std::string& border_type) {
  if      (border_type == "default" ||
           border_type == "reflect_101") return cv::BORDER_DEFAULT;
  else if (border_type == "reflect")    return cv::BORDER_REFLECT;
  else if (border_type == "replicate")  return cv::BORDER_REPLICATE;
  else if (border_type == "constant")   return cv::BORDER_CONSTANT;
  else if (border_type == "wrap")       return cv::BORDER_WRAP;
  else stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap");
  return -1;
}

static int cv_ddepth(const std::string& ddepth) {
  if      (ddepth == "CV_16S") return CV_16S;
  else if (ddepth == "CV_32F") return CV_32F;
  else if (ddepth == "CV_64F") return CV_64F;
  else stop("ddepth must be one of: CV_16S, CV_32F, CV_64F");
  return -1;
}

// ── sobel ─────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_sobel(
    external_pointer<RtImage> img,
    int dx, int dy, int ksize,
    std::string ddepth, double scale, double delta,
    std::string border_type) {
  cv::Mat dst;
  cv::Sobel(get_cpu_mat(img), dst, cv_ddepth(ddepth), dx, dy, ksize,
            scale, delta, cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── laplacian ─────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_laplacian(
    external_pointer<RtImage> img,
    int ksize,
    std::string ddepth, double scale, double delta,
    std::string border_type) {
  cv::Mat dst;
  cv::Laplacian(get_cpu_mat(img), dst, cv_ddepth(ddepth), ksize,
                scale, delta, cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── canny ─────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_canny(
    external_pointer<RtImage> img,
    double low_threshold, double high_threshold,
    int aperture_size, bool L2_gradient) {
  cv::Mat dst;
  cv::Canny(get_cpu_mat(img), dst, low_threshold, high_threshold,
            aperture_size, L2_gradient);
  return {new RtImage(std::move(dst), std::string("GRAY"))};
}

// ── scharr ────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_scharr(
    external_pointer<RtImage> img,
    int dx, int dy, std::string ddepth,
    double scale, double delta, std::string border_type) {
  cv::Mat dst;
  cv::Scharr(get_cpu_mat(img), dst, cv_ddepth(ddepth), dx, dy,
             scale, delta, cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── filter2D ──────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_filter2d(
    external_pointer<RtImage> img,
    cpp11::doubles kernel_data,
    int kernel_nrow, int kernel_ncol,
    int ddepth, int anchor_x, int anchor_y,
    double delta, std::string border_type) {
  cv::Mat kernel(kernel_nrow, kernel_ncol, CV_64F);
  for (int j = 0; j < kernel_ncol; j++)
    for (int i = 0; i < kernel_nrow; i++)
      kernel.at<double>(i, j) = kernel_data[i + j * kernel_nrow];
  cv::Mat dst;
  cv::filter2D(get_cpu_mat(img), dst, ddepth, kernel,
               cv::Point(anchor_x, anchor_y), delta,
               cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}
