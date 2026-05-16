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

static int cv_depth_code(const std::string& depth) {
  if      (depth == "CV_8U")  return CV_8U;
  else if (depth == "CV_8S")  return CV_8S;
  else if (depth == "CV_16U") return CV_16U;
  else if (depth == "CV_16S") return CV_16S;
  else if (depth == "CV_32S") return CV_32S;
  else if (depth == "CV_32F") return CV_32F;
  else if (depth == "CV_64F") return CV_64F;
  return -1;
}

// ── zeros ─────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_zeros(int rows, int cols, int nchan,
                                    std::string depth, std::string colorspace) {
  int type = CV_MAKETYPE(cv_depth_code(depth), nchan);
  cv::Mat mat = cv::Mat::zeros(rows, cols, type);
  return {new RtImage(std::move(mat), colorspace)};
}

// ── ones ──────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_ones(int rows, int cols, int nchan,
                                   std::string depth, std::string colorspace) {
  int type = CV_MAKETYPE(cv_depth_code(depth), nchan);
  cv::Mat mat = cv::Mat::ones(rows, cols, type);
  return {new RtImage(std::move(mat), colorspace)};
}

// ── randu ─────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_randu(int rows, int cols, int nchan,
                                    std::string depth, std::string colorspace,
                                    double low, double high) {
  int type = CV_MAKETYPE(cv_depth_code(depth), nchan);
  cv::Mat mat(rows, cols, type);
  cv::randu(mat, cv::Scalar::all(low), cv::Scalar::all(high));
  return {new RtImage(std::move(mat), colorspace)};
}

// ── randn ─────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_randn(int rows, int cols, int nchan,
                                    std::string depth, std::string colorspace,
                                    double mean, double stddev) {
  int type = CV_MAKETYPE(cv_depth_code(depth), nchan);
  cv::Mat mat(rows, cols, type);
  cv::randn(mat, cv::Scalar::all(mean), cv::Scalar::all(stddev));
  return {new RtImage(std::move(mat), colorspace)};
}
