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

// ── split ─────────────────────────────────────────────────────────────────────

[[cpp11::register]]
cpp11::list rt_image_split_channels(external_pointer<RtImage> img) {
  cv::Mat mat = get_cpu_mat(img);
  std::vector<cv::Mat> mats;
  cv::split(mat, mats);
  cpp11::writable::list result(static_cast<R_xlen_t>(mats.size()));
  for (size_t i = 0; i < mats.size(); i++) {
    result[i] = external_pointer<RtImage>(
      new RtImage(std::move(mats[i]), std::string("GRAY"))
    );
  }
  return result;
}

// ── merge ─────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_merge_channels(
    cpp11::list channel_ptrs, std::string colorspace) {
  std::vector<cv::Mat> mats;
  mats.reserve(channel_ptrs.size());
  for (int i = 0; i < channel_ptrs.size(); i++) {
    auto ptr = cpp11::as_cpp<external_pointer<RtImage>>(channel_ptrs[i]);
    mats.push_back(get_cpu_mat(ptr));
  }
  cv::Mat merged;
  cv::merge(mats, merged);
  return {new RtImage(std::move(merged), colorspace)};
}
