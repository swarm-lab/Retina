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

static int cv_interp(const std::string& m) {
  if      (m == "nearest")  return cv::INTER_NEAREST;
  else if (m == "linear")   return cv::INTER_LINEAR;
  else if (m == "cubic")    return cv::INTER_CUBIC;
  else if (m == "area")     return cv::INTER_AREA;
  else if (m == "lanczos4") return cv::INTER_LANCZOS4;
  else stop("interpolation must be one of: nearest, linear, cubic, area, lanczos4");
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

// ── warp_affine ───────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_warp_affine(
    external_pointer<RtImage> img,
    doubles m,
    int width, int height,
    std::string interpolation, std::string border_type) {
  // m arrives as a length-6 vector (R stores 2x3 matrix column-major)
  // Layout: m[0]=M(0,0), m[1]=M(1,0), m[2]=M(0,1), m[3]=M(1,1), m[4]=M(0,2), m[5]=M(1,2)
  cv::Mat M(2, 3, CV_64F);
  for (int i = 0; i < 2; i++)
    for (int j = 0; j < 3; j++)
      M.at<double>(i, j) = m[i + j * 2];
  cv::Mat dst;
  cv::warpAffine(get_cpu_mat(img), dst, M, cv::Size(width, height),
                 cv_interp(interpolation), cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── warp_perspective ──────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_warp_perspective(
    external_pointer<RtImage> img,
    doubles m,
    int width, int height,
    std::string interpolation, std::string border_type) {
  // m arrives as a length-9 vector (R stores 3x3 matrix column-major)
  // Layout: m[i + j*3] = M(i, j)
  cv::Mat M(3, 3, CV_64F);
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      M.at<double>(i, j) = m[i + j * 3];
  cv::Mat dst;
  cv::warpPerspective(get_cpu_mat(img), dst, M, cv::Size(width, height),
                      cv_interp(interpolation), cv_border_type(border_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── affine_rotate ─────────────────────────────────────────────────────────────

[[cpp11::register]]
doubles rt_affine_rotate(double angle, double cx, double cy) {
  // cx, cy are 1-based; subtract 1 for OpenCV
  cv::Mat M = cv::getRotationMatrix2D(
    cv::Point2f(static_cast<float>(cx - 1.0), static_cast<float>(cy - 1.0)),
    angle, 1.0);
  // Return as length-6 vector; R will reshape to 2x3 matrix column-major
  writable::doubles result(6);
  for (int i = 0; i < 2; i++)
    for (int j = 0; j < 3; j++)
      result[i + j * 2] = M.at<double>(i, j);
  return result;
}

// ── affine_from_points ────────────────────────────────────────────────────────

[[cpp11::register]]
doubles rt_affine_from_points(doubles src, doubles dst) {
  // src and dst are length-6 vectors from 3x2 R matrices (column-major)
  // col 0 = x values (indices 0,1,2), col 1 = y values (indices 3,4,5)
  std::vector<cv::Point2f> src_pts(3), dst_pts(3);
  for (int i = 0; i < 3; i++) {
    src_pts[i] = cv::Point2f(static_cast<float>(src[i]     - 1.0),
                             static_cast<float>(src[i + 3] - 1.0));
    dst_pts[i] = cv::Point2f(static_cast<float>(dst[i]     - 1.0),
                             static_cast<float>(dst[i + 3] - 1.0));
  }
  cv::Mat M = cv::getAffineTransform(src_pts, dst_pts);
  writable::doubles result(6);
  for (int i = 0; i < 2; i++)
    for (int j = 0; j < 3; j++)
      result[i + j * 2] = M.at<double>(i, j);
  return result;
}

// ── perspective_from_points ───────────────────────────────────────────────────

[[cpp11::register]]
doubles rt_perspective_from_points(doubles src, doubles dst) {
  // src and dst are length-8 vectors from 4x2 R matrices (column-major)
  // col 0 = x values (indices 0-3), col 1 = y values (indices 4-7)
  std::vector<cv::Point2f> src_pts(4), dst_pts(4);
  for (int i = 0; i < 4; i++) {
    src_pts[i] = cv::Point2f(static_cast<float>(src[i]     - 1.0),
                             static_cast<float>(src[i + 4] - 1.0));
    dst_pts[i] = cv::Point2f(static_cast<float>(dst[i]     - 1.0),
                             static_cast<float>(dst[i + 4] - 1.0));
  }
  cv::Mat M = cv::getPerspectiveTransform(src_pts, dst_pts);
  writable::doubles result(9);
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      result[i + j * 3] = M.at<double>(i, j);
  return result;
}
