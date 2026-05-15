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

static int cv_morph_op(const std::string& op) {
  if      (op == "erode")    return cv::MORPH_ERODE;
  else if (op == "dilate")   return cv::MORPH_DILATE;
  else if (op == "open")     return cv::MORPH_OPEN;
  else if (op == "close")    return cv::MORPH_CLOSE;
  else if (op == "gradient") return cv::MORPH_GRADIENT;
  else if (op == "tophat")   return cv::MORPH_TOPHAT;
  else if (op == "blackhat") return cv::MORPH_BLACKHAT;
  else stop("operation must be one of: erode, dilate, open, close, gradient, tophat, blackhat");
  return -1;
}

static int cv_morph_shape(const std::string& shape) {
  if      (shape == "rect")    return cv::MORPH_RECT;
  else if (shape == "cross")   return cv::MORPH_CROSS;
  else if (shape == "ellipse") return cv::MORPH_ELLIPSE;
  else stop("shape must be one of: rect, cross, ellipse");
  return -1;
}

static int cv_border_type(const std::string& b) {
  if      (b == "default" || b == "reflect_101") return cv::BORDER_DEFAULT;
  else if (b == "reflect")                       return cv::BORDER_REFLECT;
  else if (b == "replicate")                     return cv::BORDER_REPLICATE;
  else if (b == "constant")                      return cv::BORDER_CONSTANT;
  else if (b == "wrap")                          return cv::BORDER_WRAP;
  else stop("border_type must be one of: default, reflect, reflect_101, replicate, constant, wrap");
  return -1;
}

// ── morph (shape + size kernel) ───────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_morph(
    external_pointer<RtImage> img,
    std::string op, std::string shape, int size,
    int iterations, std::string border_type) {
  if (size < 1) stop("size must be >= 1");
  if (iterations < 1) stop("iterations must be >= 1");
  cv::Mat kernel = cv::getStructuringElement(
    cv_morph_shape(shape), cv::Size(size, size));
  cv::Mat dst;
  cv::morphologyEx(get_cpu_mat(img), dst, cv_morph_op(op), kernel,
                   cv::Point(-1, -1), iterations, cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── morph_custom (user-supplied matrix kernel) ────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_morph_custom(
    external_pointer<RtImage> img,
    std::string op,
    cpp11::integers custom_kernel,
    int iterations, std::string border_type) {
  if (iterations < 1) stop("iterations must be >= 1");
  cpp11::integers dims(static_cast<SEXP>(custom_kernel.attr("dim")));
  if (dims.size() != 2) stop("kernel must be a 2-dimensional matrix");
  int nrow = dims[0], ncol = dims[1];
  cv::Mat kernel(nrow, ncol, CV_8U);
  for (int i = 0; i < nrow; i++)
    for (int j = 0; j < ncol; j++)
      kernel.at<uchar>(i, j) = static_cast<uchar>(custom_kernel[i + j * nrow]);
  cv::Mat dst;
  cv::morphologyEx(get_cpu_mat(img), dst, cv_morph_op(op), kernel,
                   cv::Point(-1, -1), iterations, cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}
