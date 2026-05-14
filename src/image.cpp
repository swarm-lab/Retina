#include "retina_image.h"
#include <opencv2/opencv.hpp>
using namespace cpp11;

// ── Build verification ────────────────────────────────────────────────────────

[[cpp11::register]]
bool rt_build_ok() { return true; }

// ── Construction ──────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_image_read(std::string path) {
  cv::Mat mat = cv::imread(path, cv::IMREAD_UNCHANGED);
  if (mat.empty())
    stop("Failed to read image from '%s'. Check the path and file format.",
         path.c_str());
  return {new RtImage(std::move(mat))};
}

[[cpp11::register]]
external_pointer<RtImage> rt_image_from_array(integers arr, std::string colorspace) {
  integers dim(static_cast<SEXP>(arr.attr("dim")));
  if (dim.size() < 2 || dim.size() > 3)
    stop("arr must be a 2D matrix or a 3D array.");

  int nrow  = dim[0];
  int ncol  = dim[1];
  int nchan = (dim.size() == 3) ? dim[2] : 1;

  // R arrays are column-major; cv::Mat is row-major.
  // R element [i, j, c] -> index: i + j*nrow + c*nrow*ncol
  std::vector<cv::Mat> channels(nchan);
  for (int c = 0; c < nchan; c++) {
    channels[c] = cv::Mat(nrow, ncol, CV_8U);
    for (int j = 0; j < ncol; j++) {
      for (int i = 0; i < nrow; i++) {
        channels[c].at<uchar>(i, j) =
          (uchar)arr[i + j * nrow + c * nrow * ncol];
      }
    }
  }
  cv::Mat mat;
  cv::merge(channels, mat);
  return {new RtImage(std::move(mat), colorspace)};
}

// ── Properties ────────────────────────────────────────────────────────────────

[[cpp11::register]]
int rt_image_nrow(external_pointer<RtImage> img) { return img->rows(); }

[[cpp11::register]]
int rt_image_ncol(external_pointer<RtImage> img) { return img->cols(); }

[[cpp11::register]]
int rt_image_nchan(external_pointer<RtImage> img) { return img->channels(); }

[[cpp11::register]]
int rt_image_depth(external_pointer<RtImage> img) { return img->depth(); }

[[cpp11::register]]
bool rt_image_is_gpu(external_pointer<RtImage> img) { return img->is_gpu(); }

[[cpp11::register]]
std::string rt_image_colorspace(external_pointer<RtImage> img) {
  return img->colorspace;
}

[[cpp11::register]]
void rt_image_set_colorspace(external_pointer<RtImage> img, std::string cs) {
  img->colorspace = cs;
}
