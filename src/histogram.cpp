#include "retina_image.h"
#include <opencv2/opencv.hpp>
#include <vector>
using namespace cpp11;

static cv::Mat get_cpu_mat(const external_pointer<RtImage>& img) {
  if (img->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(img->buffer).copyTo(m);
    return m;
  }
  return std::get<cv::Mat>(img->buffer);
}

// ── rt_hist ──────────────────────────────────────────────────────────────────
// Returns a list of length nchan; each element is a doubles vector of length
// `bins` containing raw pixel counts.
[[cpp11::register]]
list rt_hist(external_pointer<RtImage> img, int bins,
             double range_lo, double range_hi) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  std::vector<cv::Mat> chans;
  cv::split(mat, chans);

  int hist_size[] = {bins};
  float flo = static_cast<float>(range_lo);
  float fhi = static_cast<float>(range_hi);
  float ranges_arr[] = {flo, fhi};
  const float* range_ptr = ranges_arr;
  int ch[] = {0};

  writable::list result(nchan);
  for (int c = 0; c < nchan; c++) {
    cv::Mat hist;
    cv::calcHist(&chans[c], 1, ch, cv::Mat(), hist, 1, hist_size, &range_ptr);
    writable::doubles counts(bins);
    for (int b = 0; b < bins; b++)
      counts[b] = static_cast<double>(hist.at<float>(b));
    result[c] = counts;
  }
  return result;
}

// ── rt_hist_eq ───────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_hist_eq(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Mat out;
  cv::equalizeHist(mat, out);
  return {new RtImage(std::move(out), img->colorspace)};
}

// ── rt_lut ───────────────────────────────────────────────────────────────────
// Applies a 256-entry lookup table to a CV_8U single-channel image.
// lut_vals: integer vector of length 256, values 0-255.
[[cpp11::register]]
external_pointer<RtImage> rt_lut(external_pointer<RtImage> img,
                                  integers lut_vals) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Mat lut(1, 256, CV_8U);
  for (int i = 0; i < 256; i++)
    lut.at<uchar>(0, i) = static_cast<uchar>(lut_vals[i]);
  cv::Mat out;
  cv::LUT(mat, lut, out);
  return {new RtImage(std::move(out), img->colorspace)};
}

// ── rt_clahe ─────────────────────────────────────────────────────────────────
[[cpp11::register]]
external_pointer<RtImage> rt_clahe(external_pointer<RtImage> img,
                                    double clip_limit, int tile_w, int tile_h) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(clip_limit,
                                              cv::Size(tile_w, tile_h));
  cv::Mat out;
  clahe->apply(mat, out);
  return {new RtImage(std::move(out), img->colorspace)};
}

// ── rt_minmax_loc ─────────────────────────────────────────────────────────────
// Returns a named list: min_val, min_row, min_col, max_val, max_row, max_col.
// Coordinates are 1-based (R convention).
[[cpp11::register]]
list rt_minmax_loc(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  double min_val, max_val;
  cv::Point min_loc, max_loc;
  cv::minMaxLoc(mat, &min_val, &max_val, &min_loc, &max_loc);

  writable::list result(6);
  result[0] = writable::doubles({min_val});
  result[1] = writable::integers({min_loc.y + 1});  // y = row (0-based → 1-based)
  result[2] = writable::integers({min_loc.x + 1});  // x = col
  result[3] = writable::doubles({max_val});
  result[4] = writable::integers({max_loc.y + 1});
  result[5] = writable::integers({max_loc.x + 1});
  result.attr("names") = writable::strings({"min_val", "min_row", "min_col",
                                             "max_val", "max_row", "max_col"});
  return result;
}

// ── rt_count_nonzero ──────────────────────────────────────────────────────────
[[cpp11::register]]
int rt_count_nonzero(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  return cv::countNonZero(mat);
}

// ── rt_find_nonzero ───────────────────────────────────────────────────────────
// Returns a data frame with columns `row` and `col` (1-based integers).
// Returns a zero-row data frame when no non-zero pixels exist.
[[cpp11::register]]
list rt_find_nonzero(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  std::vector<cv::Point> pts;
  if (cv::countNonZero(mat) > 0)
    cv::findNonZero(mat, pts);

  int n = static_cast<int>(pts.size());
  writable::integers rows(n), cols(n);
  for (int i = 0; i < n; i++) {
    rows[i] = pts[i].y + 1;  // y = row, 0-based → 1-based
    cols[i] = pts[i].x + 1;  // x = col
  }
  writable::list result(2);
  result[0] = rows;
  result[1] = cols;
  result.attr("names")     = writable::strings({"row", "col"});
  result.attr("class")     = writable::strings({"data.frame"});
  result.attr("row.names") = writable::integers({NA_INTEGER, -n});
  return result;
}
