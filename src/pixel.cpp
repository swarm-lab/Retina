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

// ── Get pixel ─────────────────────────────────────────────────────────────────

[[cpp11::register]]
doubles rt_image_get_pixel(external_pointer<RtImage> img, int row, int col) {
  cv::Mat mat = get_cpu_mat(img);
  int r = row - 1, c = col - 1;
  if (r < 0 || r >= mat.rows || c < 0 || c >= mat.cols)
    stop("pixel coordinates out of bounds");
  int nchan = mat.channels();
  int depth = mat.depth();
  writable::doubles result(nchan);
  for (int k = 0; k < nchan; k++) {
    if      (depth == CV_8U)  result[k] = mat.ptr<uint8_t>(r)[c * nchan + k];
    else if (depth == CV_16U) result[k] = mat.ptr<uint16_t>(r)[c * nchan + k];
    else if (depth == CV_16S) result[k] = mat.ptr<int16_t>(r)[c * nchan + k];
    else if (depth == CV_32F) result[k] = mat.ptr<float>(r)[c * nchan + k];
    else                      result[k] = mat.ptr<double>(r)[c * nchan + k];
  }
  return result;
}

// ── Set pixel ─────────────────────────────────────────────────────────────────

[[cpp11::register]]
void rt_image_set_pixel(external_pointer<RtImage> img,
                        int row, int col, doubles values) {
  // Access buffer directly (not via get_cpu_mat) to modify in-place.
  if (img->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(img->buffer).copyTo(m);
    img->buffer = std::move(m);
  }
  cv::Mat& mat = std::get<cv::Mat>(img->buffer);
  int r = row - 1, c = col - 1;
  if (r < 0 || r >= mat.rows || c < 0 || c >= mat.cols)
    stop("pixel coordinates out of bounds");
  int nchan = mat.channels();
  if ((int)values.size() < nchan)
    stop("values must have one element per channel (%d expected, got %d)",
         nchan, (int)values.size());
  int depth = mat.depth();
  for (int k = 0; k < nchan; k++) {
    double v = values[k];
    if      (depth == CV_8U)  mat.ptr<uint8_t>(r)[c * nchan + k]  = static_cast<uint8_t>(v);
    else if (depth == CV_16U) mat.ptr<uint16_t>(r)[c * nchan + k] = static_cast<uint16_t>(v);
    else if (depth == CV_16S) mat.ptr<int16_t>(r)[c * nchan + k]  = static_cast<int16_t>(v);
    else if (depth == CV_32F) mat.ptr<float>(r)[c * nchan + k]    = static_cast<float>(v);
    else                      mat.ptr<double>(r)[c * nchan + k]   = v;
  }
}

// ── Extract region (range read) ───────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_extract_region(
    external_pointer<RtImage> img,
    int row_start, int col_start, int row_end, int col_end) {
  cv::Mat src = get_cpu_mat(img);
  // All coords are 1-based inclusive; cv::Rect is 0-based with width/height.
  cv::Rect roi(col_start - 1, row_start - 1,
               col_end - col_start + 1, row_end - row_start + 1);
  if (roi.x < 0 || roi.y < 0 || roi.x + roi.width > src.cols || roi.y + roi.height > src.rows)
    stop("region coordinates out of bounds");
  cv::Mat result = src(roi).clone();
  return {new RtImage(std::move(result), img->colorspace)};
}

// ── Copy ROI (range write) ────────────────────────────────────────────────────

[[cpp11::register]]
void rt_image_copy_roi(external_pointer<RtImage> dst,
                       external_pointer<RtImage> src,
                       int row_start, int col_start) {
  if (dst->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(dst->buffer).copyTo(m);
    dst->buffer = std::move(m);
  }
  cv::Mat& dst_mat = std::get<cv::Mat>(dst->buffer);
  cv::Mat src_mat  = get_cpu_mat(src);
  cv::Rect roi(col_start - 1, row_start - 1, src_mat.cols, src_mat.rows);
  if (roi.x < 0 || roi.y < 0 ||
      roi.x + roi.width > dst_mat.cols || roi.y + roi.height > dst_mat.rows)
    stop("ROI exceeds destination image bounds");
  src_mat.copyTo(dst_mat(roi));
}
