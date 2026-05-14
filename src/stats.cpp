#include "retina_image.h"
#include <opencv2/opencv.hpp>
#include <vector>
#include <algorithm>
#include <cmath>
using namespace cpp11;

static cv::Mat get_cpu_mat(const external_pointer<RtImage>& img) {
  if (img->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(img->buffer).copyTo(m);
    return m;
  }
  return std::get<cv::Mat>(img->buffer);
}

[[cpp11::register]]
doubles rt_image_mean(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Mat mean_v, stddev_v;
  cv::meanStdDev(mat, mean_v, stddev_v);
  int nchan = mat.channels();
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++)
    result[c] = mean_v.at<double>(c);
  return result;
}

[[cpp11::register]]
doubles rt_image_sd(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Mat mean_v, stddev_v;
  cv::meanStdDev(mat, mean_v, stddev_v);
  int nchan = mat.channels();
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++)
    result[c] = stddev_v.at<double>(c);
  return result;
}

[[cpp11::register]]
doubles rt_image_var(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  cv::Mat mean_v, stddev_v;
  cv::meanStdDev(mat, mean_v, stddev_v);
  int nchan = mat.channels();
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++) {
    double sd = stddev_v.at<double>(c);
    result[c] = sd * sd;
  }
  return result;
}

[[cpp11::register]]
doubles rt_image_min(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  std::vector<cv::Mat> channels;
  cv::split(mat, channels);
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++) {
    double mn, mx;
    cv::minMaxLoc(channels[c], &mn, &mx);
    result[c] = mn;
  }
  return result;
}

[[cpp11::register]]
doubles rt_image_max(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  std::vector<cv::Mat> channels;
  cv::split(mat, channels);
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++) {
    double mn, mx;
    cv::minMaxLoc(channels[c], &mn, &mx);
    result[c] = mx;
  }
  return result;
}

[[cpp11::register]]
doubles rt_image_sum(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  cv::Scalar s = cv::sum(mat);
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++)
    result[c] = s[c];
  return result;
}

static std::vector<double> sorted_channel(const cv::Mat& ch) {
  int n = ch.rows * ch.cols;
  std::vector<double> px(n);
  for (int i = 0; i < ch.rows; i++)
    for (int j = 0; j < ch.cols; j++)
      px[i * ch.cols + j] = static_cast<double>(ch.at<uchar>(i, j));
  std::sort(px.begin(), px.end());
  return px;
}

static double quantile_sorted(const std::vector<double>& px, double prob) {
  int n = static_cast<int>(px.size());
  double idx = prob * (n - 1);
  int lo = static_cast<int>(std::floor(idx));
  int hi = static_cast<int>(std::ceil(idx));
  if (lo == hi) return px[lo];
  return px[lo] + (idx - lo) * (px[hi] - px[lo]);
}

[[cpp11::register]]
doubles rt_image_median(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  std::vector<cv::Mat> channels;
  cv::split(mat, channels);
  writable::doubles result(nchan);
  for (int c = 0; c < nchan; c++) {
    auto px = sorted_channel(channels[c]);
    result[c] = quantile_sorted(px, 0.5);
  }
  return result;
}

[[cpp11::register]]
doubles rt_image_quantile(external_pointer<RtImage> img, doubles probs) {
  cv::Mat mat = get_cpu_mat(img);
  int nchan = mat.channels();
  int nprobs = probs.size();
  std::vector<cv::Mat> channels;
  cv::split(mat, channels);
  // column-major: all probs for channel 0, then channel 1, ...
  writable::doubles result(nprobs * nchan);
  for (int c = 0; c < nchan; c++) {
    auto px = sorted_channel(channels[c]);
    for (int p = 0; p < nprobs; p++)
      result[c * nprobs + p] = quantile_sorted(px, probs[p]);
  }
  return result;
}
