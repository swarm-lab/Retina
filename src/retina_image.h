#pragma once
#include <cpp11.hpp>
#include <opencv2/opencv.hpp>
#include <variant>
#include <string>
#include <stdexcept>

struct RtImage {
  std::variant<cv::Mat, cv::UMat> buffer;
  std::string colorspace;

  RtImage() : buffer(cv::Mat()), colorspace("BGR") {}

  explicit RtImage(cv::Mat mat, std::string cs = "BGR")
    : buffer(std::move(mat)), colorspace(std::move(cs)) {}

  explicit RtImage(cv::UMat umat, std::string cs = "BGR")
    : buffer(std::move(umat)), colorspace(std::move(cs)) {}

  explicit RtImage(std::variant<cv::Mat, cv::UMat> buf, std::string cs = "BGR")
    : buffer(std::move(buf)), colorspace(std::move(cs)) {}

  bool is_gpu() const {
    return std::holds_alternative<cv::UMat>(buffer);
  }

  void to_gpu() {
    if (!is_gpu()) {
      cv::UMat u;
      std::get<cv::Mat>(buffer).copyTo(u);
      buffer = std::move(u);
    }
  }

  void to_cpu() {
    if (is_gpu()) {
      cv::Mat m;
      std::get<cv::UMat>(buffer).copyTo(m);
      buffer = std::move(m);
    }
  }

  int rows() const {
    return std::visit([](const auto& b) { return b.rows; }, buffer);
  }

  int cols() const {
    return std::visit([](const auto& b) { return b.cols; }, buffer);
  }

  int channels() const {
    return std::visit([](const auto& b) { return b.channels(); }, buffer);
  }

  int depth() const {
    return std::visit([](const auto& b) { return b.depth(); }, buffer);
  }

  bool empty() const {
    return std::visit([](const auto& b) { return b.empty(); }, buffer);
  }
};
