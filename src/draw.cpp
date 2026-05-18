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

static int cv_line_type(const std::string& t) {
  if      (t == "line_4") return cv::LINE_4;
  else if (t == "line_8") return cv::LINE_8;
  else if (t == "aa")     return cv::LINE_AA;
  else stop("line_type must be one of: line_4, line_8, aa");
  return -1;
}

static int cv_font_face(const std::string& f, bool italic) {
  int face;
  if      (f == "simplex")        face = cv::FONT_HERSHEY_SIMPLEX;
  else if (f == "plain")          face = cv::FONT_HERSHEY_PLAIN;
  else if (f == "duplex")         face = cv::FONT_HERSHEY_DUPLEX;
  else if (f == "complex")        face = cv::FONT_HERSHEY_COMPLEX;
  else if (f == "triplex")        face = cv::FONT_HERSHEY_TRIPLEX;
  else if (f == "complex_small")  face = cv::FONT_HERSHEY_COMPLEX_SMALL;
  else if (f == "script_simplex") face = cv::FONT_HERSHEY_SCRIPT_SIMPLEX;
  else if (f == "script_complex") face = cv::FONT_HERSHEY_SCRIPT_COMPLEX;
  else stop("font must be one of: simplex, plain, duplex, complex, triplex, complex_small, script_simplex, script_complex");
  return face + (italic ? 16 : 0);
}

static cv::Scalar make_scalar(const doubles& col) {
  if (col.size() == 4) return cv::Scalar(col[0], col[1], col[2], col[3]);
  return cv::Scalar(col[0], col[1], col[2]);
}

// ── line ──────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_draw_line(
    external_pointer<RtImage> img,
    int x1, int y1, int x2, int y2,
    doubles color, int thickness, std::string line_type) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::line(dst,
           cv::Point(x1 - 1, y1 - 1), cv::Point(x2 - 1, y2 - 1),
           make_scalar(color), thickness, cv_line_type(line_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── arrow ─────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_draw_arrow(
    external_pointer<RtImage> img,
    int x1, int y1, int x2, int y2,
    doubles color, int thickness, std::string line_type, double tip_length) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::arrowedLine(dst,
                  cv::Point(x1 - 1, y1 - 1), cv::Point(x2 - 1, y2 - 1),
                  make_scalar(color), thickness, cv_line_type(line_type),
                  0, tip_length);
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── rectangle ─────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_draw_rectangle(
    external_pointer<RtImage> img,
    int x1, int y1, int x2, int y2,
    doubles color, int thickness, std::string line_type) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::rectangle(dst,
                cv::Point(x1 - 1, y1 - 1), cv::Point(x2 - 1, y2 - 1),
                make_scalar(color), thickness, cv_line_type(line_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── circle ────────────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_draw_circle(
    external_pointer<RtImage> img,
    int x, int y, int radius,
    doubles color, int thickness, std::string line_type) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::circle(dst,
             cv::Point(x - 1, y - 1), radius,
             make_scalar(color), thickness, cv_line_type(line_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

// ── ellipse / arc ─────────────────────────────────────────────────────────────

[[cpp11::register]]
external_pointer<RtImage> rt_draw_ellipse(
    external_pointer<RtImage> img,
    int x, int y, int rx, int ry, double angle,
    doubles color, int thickness, std::string line_type) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::ellipse(dst,
              cv::Point(x - 1, y - 1), cv::Size(rx, ry),
              angle, 0.0, 360.0,
              make_scalar(color), thickness, cv_line_type(line_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}

[[cpp11::register]]
external_pointer<RtImage> rt_draw_arc(
    external_pointer<RtImage> img,
    int x, int y, int rx, int ry,
    double angle, double start_angle, double end_angle,
    doubles color, int thickness, std::string line_type) {
  cv::Mat dst = get_cpu_mat(img).clone();
  cv::ellipse(dst,
              cv::Point(x - 1, y - 1), cv::Size(rx, ry),
              angle, start_angle, end_angle,
              make_scalar(color), thickness, cv_line_type(line_type));
  return {new RtImage(std::move(dst), img->colorspace)};
}
