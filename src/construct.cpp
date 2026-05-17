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
  else stop("depth must be one of: CV_8U, CV_8S, CV_16U, CV_16S, CV_32S, CV_32F, CV_64F");
  return -1;
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

static int cv_border_type_c(const std::string& b) {
  if      (b == "constant")                      return cv::BORDER_CONSTANT;
  else if (b == "reflect")                       return cv::BORDER_REFLECT;
  else if (b == "reflect_101" || b == "default") return cv::BORDER_DEFAULT;
  else if (b == "replicate")                     return cv::BORDER_REPLICATE;
  else if (b == "wrap")                          return cv::BORDER_WRAP;
  else stop("type must be one of: constant, reflect, reflect_101, replicate, wrap");
  return -1;
}

// ── border ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_border(
    external_pointer<RtImage> img,
    int top, int bottom, int left, int right,
    std::string border_type, doubles value) {
  cv::Scalar scalar(value.size() > 0 ? value[0] : 0.0,
                    value.size() > 1 ? value[1] : 0.0,
                    value.size() > 2 ? value[2] : 0.0,
                    value.size() > 3 ? value[3] : 0.0);
  cv::Mat dst;
  cv::copyMakeBorder(get_cpu_mat(img), dst, top, bottom, left, right,
                     cv_border_type_c(border_type), scalar);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── fill ──────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_fill(int rows, int cols, int nchan,
                                   std::string depth, std::string colorspace,
                                   doubles value_vec) {
  int type = CV_MAKETYPE(cv_depth_code(depth), nchan);
  // value_vec is always length nchan (recycled on the R side).
  // Build a 4-element Scalar, zero-padding unused channels.
  double v0 = value_vec.size() > 0 ? value_vec[0] : 0.0;
  double v1 = value_vec.size() > 1 ? value_vec[1] : 0.0;
  double v2 = value_vec.size() > 2 ? value_vec[2] : 0.0;
  double v3 = value_vec.size() > 3 ? value_vec[3] : 0.0;
  cv::Mat mat(rows, cols, type, cv::Scalar(v0, v1, v2, v3));
  return {new RtImage(std::move(mat), colorspace)};
}

// ── tile ──────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_tile(external_pointer<RtImage> img,
                                         int nrow_rep, int ncol_rep) {
  cv::Mat dst;
  cv::repeat(get_cpu_mat(img), nrow_rep, ncol_rep, dst);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── set_to ────────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_image_set_to(
    external_pointer<RtImage> img,
    doubles value,
    SEXP mask_ptr) {
  cv::Scalar scalar(value.size() > 0 ? value[0] : 0.0,
                    value.size() > 1 ? value[1] : 0.0,
                    value.size() > 2 ? value[2] : 0.0,
                    value.size() > 3 ? value[3] : 0.0);
  cv::Mat dst = get_cpu_mat(img).clone();
  if (mask_ptr == R_NilValue) {
    dst.setTo(scalar);
  } else {
    external_pointer<RtImage> mask_img(mask_ptr);
    cv::Mat mask_mat = get_cpu_mat(mask_img);
    dst.setTo(scalar, mask_mat);
  }
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── concatenate ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_concatenate(cpp11::list img_ptrs,
                                          std::string axis) {
  // Colorspace uniformity is validated on the R side; take colorspace from img_ptrs[0].
  std::vector<cv::Mat> mats;
  mats.reserve(img_ptrs.size());
  std::string colorspace;
  for (int i = 0; i < img_ptrs.size(); i++) {
    auto ptr = cpp11::as_cpp<external_pointer<RtImage>>(img_ptrs[i]);
    if (i == 0) colorspace = ptr->colorspace;
    mats.push_back(get_cpu_mat(ptr));
  }
  cv::Mat result;
  if (axis == "h" || axis == "horizontal") {
    cv::hconcat(mats, result);
  } else {
    cv::vconcat(mats, result);
  }
  return {new RtImage(std::move(result), colorspace)};
}
