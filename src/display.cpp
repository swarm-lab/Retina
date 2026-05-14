#include "retina_image.h"
#include <opencv2/opencv.hpp>
using namespace cpp11;

[[cpp11::register]]
integers rt_image_to_native_raster(external_pointer<RtImage> img) {
  cv::Mat mat;
  if (img->is_gpu()) {
    std::get<cv::UMat>(img->buffer).copyTo(mat);
  } else {
    mat = std::get<cv::Mat>(img->buffer);
  }

  // Normalize to 8-bit
  cv::Mat bgr8;
  if (mat.depth() != CV_8U) {
    double scale = (mat.depth() == CV_16U) ? 1.0 / 256.0 : 255.0;
    mat.convertTo(bgr8, CV_8U, scale);
  } else {
    bgr8 = mat;
  }

  // Ensure 3-channel BGR
  cv::Mat bgr;
  int ch = bgr8.channels();
  if (ch == 1) {
    cv::cvtColor(bgr8, bgr, cv::COLOR_GRAY2BGR);
  } else if (ch == 4) {
    cv::cvtColor(bgr8, bgr, cv::COLOR_BGRA2BGR);
  } else {
    bgr = bgr8;
  }

  int nrow = bgr.rows, ncol = bgr.cols;
  writable::integers result(nrow * ncol);

  // Pack as 0xAARRGGBB (nativeRaster column-major: row varies fastest)
  for (int j = 0; j < ncol; j++) {
    for (int i = 0; i < nrow; i++) {
      cv::Vec3b px = bgr.at<cv::Vec3b>(i, j);
      uint32_t packed = 0xFF000000u
        | (static_cast<uint32_t>(px[2]) << 16)  // R
        | (static_cast<uint32_t>(px[1]) << 8)   // G
        |  static_cast<uint32_t>(px[0]);         // B
      result[i + j * nrow] = static_cast<int>(packed);
    }
  }

  result.attr("dim") = writable::integers({nrow, ncol});
  result.attr("class") = "nativeRaster";
  return result;
}
