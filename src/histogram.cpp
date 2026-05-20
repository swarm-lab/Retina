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
// Applies a lookup table to a CV_8U, CV_16U, or CV_16S image.
// lut_vals: integer vector, length = lut_size * nchan_lut, column-major
//           (all values for channel 0, then channel 1, etc.)
// lut_size: 256 (for CV_8U) or 65536 (for CV_16U / CV_16S)
// nchan_lut: 1 = broadcast to all source channels; else = source nchan
//
// For CV_8U images, cv::LUT is used directly (requires 256-entry table).
// For CV_16U/CV_16S images, manual per-pixel mapping is used because
// cv::LUT only accepts 256-entry LUTs in OpenCV < 4.13.
[[cpp11::register]]
external_pointer<RtImage> rt_lut(external_pointer<RtImage> img,
                                  integers lut_vals,
                                  int lut_size,
                                  int nchan_lut) {
  cv::Mat mat = get_cpu_mat(img);

  if (lut_size == 256) {
    // CV_8U path: use cv::LUT (fast).
    if (nchan_lut == 1) {
      cv::Mat lut(1, 256, CV_8U);
      for (int i = 0; i < 256; i++)
        lut.at<uchar>(0, i) = static_cast<uchar>(lut_vals[i]);
      cv::Mat out;
      cv::LUT(mat, lut, out);
      return {new RtImage(std::move(out), img->colorspace)};
    } else {
      // Per-channel: split, apply each channel's LUT, merge.
      int src_nchan = mat.channels();
      std::vector<cv::Mat> channels;
      cv::split(mat, channels);
      std::vector<cv::Mat> results(src_nchan);
      for (int c = 0; c < src_nchan; c++) {
        cv::Mat lut(1, 256, CV_8U);
        for (int i = 0; i < 256; i++)
          lut.at<uchar>(0, i) = static_cast<uchar>(lut_vals[c * 256 + i]);
        cv::LUT(channels[c], lut, results[c]);
      }
      cv::Mat out;
      cv::merge(results, out);
      return {new RtImage(std::move(out), img->colorspace)};
    }
  } else {
    // CV_16U / CV_16S path: manual per-pixel mapping.
    // Build a flat C++ lookup table for each channel.
    int src_nchan = mat.channels();
    bool is_signed = (mat.depth() == CV_16S);

    // Build per-channel uint16 lookup tables from lut_vals.
    std::vector<std::vector<uint16_t>> tables(
      nchan_lut == 1 ? 1 : src_nchan);
    for (int c = 0; c < (int)tables.size(); c++) {
      tables[c].resize(65536);
      for (int i = 0; i < 65536; i++)
        tables[c][i] = static_cast<uint16_t>(lut_vals[c * 65536 + i]);
    }

    cv::Mat out(mat.size(), mat.type());
    int rows = mat.rows;
    int cols = mat.cols;

    if (!is_signed) {
      // CV_16U
      for (int r = 0; r < rows; r++) {
        const uint16_t* src_row = mat.ptr<uint16_t>(r);
        uint16_t*       dst_row = out.ptr<uint16_t>(r);
        for (int col = 0; col < cols; col++) {
          for (int c = 0; c < src_nchan; c++) {
            int idx = col * src_nchan + c;
            uint16_t pix = src_row[idx];
            int tbl_idx = (nchan_lut == 1) ? 0 : c;
            dst_row[idx] = tables[tbl_idx][pix];
          }
        }
      }
    } else {
      // CV_16S — LUT index = pixel + 32768
      for (int r = 0; r < rows; r++) {
        const int16_t* src_row = mat.ptr<int16_t>(r);
        int16_t*       dst_row = out.ptr<int16_t>(r);
        for (int col = 0; col < cols; col++) {
          for (int c = 0; c < src_nchan; c++) {
            int idx = col * src_nchan + c;
            int16_t  pix  = src_row[idx];
            int      lut_i = static_cast<int>(pix) + 32768;
            int tbl_idx = (nchan_lut == 1) ? 0 : c;
            dst_row[idx] = static_cast<int16_t>(
              static_cast<int>(tables[tbl_idx][lut_i]) - 32768);
          }
        }
      }
    }
    return {new RtImage(std::move(out), img->colorspace)};
  }
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
