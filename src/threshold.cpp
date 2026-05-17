#include "retina_image.h"
#include <opencv2/opencv.hpp>
#include <cmath>
#include <limits>
#include <vector>
using namespace cpp11;

// ── cpu mat helper ────────────────────────────────────────────────────────────

static cv::Mat get_cpu_mat(const external_pointer<RtImage>& img) {
  if (img->is_gpu()) {
    cv::Mat m;
    std::get<cv::UMat>(img->buffer).copyTo(m);
    return m;
  }
  return std::get<cv::Mat>(img->buffer);
}

// ── bimodal helpers ───────────────────────────────────────────────────────────

static bool bimodalTest(const std::vector<double>& y) {
  int len = (int)y.size();
  int modes = 0;
  for (int k = 1; k < len - 1; k++) {
    if (y[k-1] < y[k] && y[k+1] < y[k]) {
      modes++;
      if (modes > 2) return false;
    }
  }
  return modes == 2;
}

// partial-sum helpers used by _autothreshMinErrorI
static double A_sum(const std::vector<int>& y, int j) {
  double x = 0;
  for (int i = 0; i <= j; i++) x += y[i];
  return x;
}

static double B_sum(const std::vector<int>& y, int j) {
  double x = 0;
  for (int i = 0; i <= j; i++) x += (double)i * y[i];
  return x;
}

static double C_sq(const std::vector<int>& y, int j) {
  double x = 0;
  for (int i = 0; i <= j; i++) x += (double)i * i * y[i];
  return x;
}

static double partialSum(const std::vector<int>& y, int j) {
  double x = 0;
  for (int i = 0; i <= j; i++) x += y[i];
  return x;
}

// ── 17 auto-threshold algorithms ──────────────────────────────────────────────

static int _autothreshIJ(std::vector<int> data) {
  int level;
  int maxValue = (int)data.size() - 1;
  double result, sum1, sum2, sum3, sum4;
  int mini = 0;
  while ((data[mini] == 0) && (mini < maxValue)) mini++;
  int maxi = maxValue;
  while ((data[maxi] == 0) && (maxi > 0)) maxi--;
  if (mini >= maxi) {
    level = (int)data.size() / 2;
    return level;
  }
  int movingIndex = mini;
  do {
    sum1 = sum2 = sum3 = sum4 = 0.0;
    for (int i = mini; i <= movingIndex; i++) {
      sum1 += i * data[i];
      sum2 += data[i];
    }
    for (int i = (movingIndex + 1); i <= maxi; i++) {
      sum3 += i * data[i];
      sum4 += data[i];
    }
    result = (sum1 / sum2 + sum3 / sum4) / 2.0;
    movingIndex++;
  } while ((movingIndex + 1) <= result && movingIndex < maxi - 1);
  level = (int)round(result);
  return level;
}

static int _autothreshHuang(std::vector<int> data) {
  int threshold = -1;
  int ih, it;
  int first_bin = 0;
  int last_bin = (int)data.size() - 1;
  int sum_pix, num_pix;
  double term, ent, min_ent, mu_x;
  for (ih = 0; ih < (int)data.size(); ih++) {
    if (data[ih] != 0) { first_bin = ih; break; }
  }
  for (ih = (int)data.size() - 1; ih >= first_bin; ih--) {
    if (data[ih] != 0) { last_bin = ih; break; }
  }
  if (first_bin == last_bin) return first_bin;
  term = 1.0 / (double)(last_bin - first_bin);
  std::vector<double> mu_0(data.size(), 0.0);
  sum_pix = num_pix = 0;
  for (ih = first_bin; ih < (int)data.size(); ih++) {
    sum_pix += ih * data[ih];
    num_pix += data[ih];
    mu_0[ih] = sum_pix / (double)num_pix;
  }
  std::vector<double> mu_1(data.size(), 0.0);
  sum_pix = num_pix = 0;
  for (ih = last_bin; ih > 0; ih--) {
    sum_pix += ih * data[ih];
    num_pix += data[ih];
    mu_1[ih - 1] = sum_pix / (double)num_pix;
  }
  threshold = -1;
  min_ent = std::numeric_limits<double>::max();
  for (it = 0; it < (int)data.size(); it++) {
    ent = 0.0;
    for (ih = 0; ih <= it; ih++) {
      mu_x = 1.0 / (1.0 + term * fabs(ih - mu_0[it]));
      if (!((mu_x < 1e-06) || (mu_x > 0.999999)))
        ent += data[ih] * (-mu_x * log(mu_x) - (1.0 - mu_x) * log(1.0 - mu_x));
    }
    for (ih = it + 1; ih < (int)data.size(); ih++) {
      mu_x = 1.0 / (1.0 + term * fabs(ih - mu_1[it]));
      if (!((mu_x < 1e-06) || (mu_x > 0.999999)))
        ent += data[ih] * (-mu_x * log(mu_x) - (1.0 - mu_x) * log(1.0 - mu_x));
    }
    if (ent < min_ent) { min_ent = ent; threshold = it; }
  }
  return threshold;
}

static int _autothreshHuang2(std::vector<int> data) {
  int first, last;
  for (first = 0; first < (int)data.size() && data[first] == 0; first++);
  for (last = (int)data.size() - 1; last > first && data[last] == 0; last--);
  if (first == last) return 0;
  std::vector<uintmax_t> S(last + 1, 0);
  std::vector<double>    W(last + 1, 0.0);
  S[0] = data[0];
  for (int i = std::max(1, first); i <= last; i++) {
    S[i] = S[i-1] + data[i];
    W[i] = W[i-1] + i * data[i];
  }
  double C_span = last - first;
  int smu_size = last + 1 - first;
  std::vector<double> Smu(smu_size, 0.0);
  for (int i = 1; i < smu_size; i++) {
    double mu = 1.0 / (1.0 + i / C_span);
    Smu[i] = -mu * log(mu) - (1.0 - mu) * log(1.0 - mu);
  }
  int bestThreshold = 0;
  double bestEntropy = std::numeric_limits<double>::max();
  for (int threshold = first; threshold != last; ++threshold) {
    double entropy = 0;
    int mu = (int)round(W[threshold] / S[threshold]);
    for (int i = first; i <= threshold; i++)
      entropy += Smu[abs(i - mu)] * data[i];
    double mu_dbl = std::round((W[last] - W[threshold]) / (S[last] - S[threshold]));
    if (std::isnan(mu_dbl)) return bestThreshold;
    mu = (int)mu_dbl;
    for (int i = threshold + 1; i <= last; i++)
      entropy += Smu[abs(i - mu)] * data[i];
    if (bestEntropy > entropy) { bestEntropy = entropy; bestThreshold = threshold; }
  }
  return bestThreshold;
}

static int _autothreshIM(std::vector<int> data) {
  std::vector<double> iHisto(data.size());
  int iter = 0;
  int threshold = -1;
  for (int i = 0; i < (int)data.size(); i++) iHisto[i] = (double)data[i];
  while (!bimodalTest(iHisto)) {
    double previous = 0, current = 0, next = iHisto[0];
    for (int i = 0; i < (int)data.size() - 1; i++) {
      previous = current; current = next; next = iHisto[i+1];
      iHisto[i] = (previous + current + next) / 3;
    }
    iHisto[data.size()-1] = (current + next) / 3;
    iter++;
    if (iter > 10000) return -1;
  }
  int tt = 0;
  for (int i = 1; i < (int)data.size() - 1; i++) {
    if (iHisto[i-1] < iHisto[i] && iHisto[i+1] < iHisto[i]) tt += i;
  }
  threshold = (int)floor(tt / 2.0);
  return threshold;
}

static int _autothreshIsoData(std::vector<int> data) {
  int i, l, toth, totl, h, g = 0;
  for (i = 1; i < (int)data.size(); i++) {
    if (data[i] > 0) { g = i + 1; break; }
  }
  while (true) {
    l = 0; totl = 0;
    for (i = 0; i < g; i++) { totl += data[i]; l += data[i] * i; }
    h = 0; toth = 0;
    for (i = g + 1; i < (int)data.size(); i++) { toth += data[i]; h += data[i] * i; }
    if (totl > 0 && toth > 0) {
      l /= totl; h /= toth;
      if (g == (int)round((l + h) / 2.0)) break;
    }
    g++;
    if (g > (int)data.size() - 2) return -1;
  }
  return g;
}

static int _autothreshLi(std::vector<int> data) {
  int threshold;
  int ih, num_pixels = 0;
  int sum_back, sum_obj, num_back, num_obj;
  double old_thresh, new_thresh, mean_back, mean_obj, mean, tolerance = 0.5, temp;
  for (ih = 0; ih < (int)data.size(); ih++) num_pixels += data[ih];
  mean = 0.0;
  for (ih = 0; ih < (int)data.size(); ih++) mean += ih * data[ih];
  mean /= num_pixels;
  new_thresh = mean;
  do {
    old_thresh = new_thresh;
    threshold = (int)(old_thresh + 0.5);
    sum_back = 0; num_back = 0;
    for (ih = 0; ih <= threshold; ih++) { sum_back += ih * data[ih]; num_back += data[ih]; }
    mean_back = (num_back == 0 ? 0.0 : sum_back / (double)num_back);
    sum_obj = 0; num_obj = 0;
    for (ih = threshold + 1; ih < (int)data.size(); ih++) { sum_obj += ih * data[ih]; num_obj += data[ih]; }
    mean_obj = (num_obj == 0 ? 0.0 : sum_obj / (double)num_obj);
    temp = (mean_back - mean_obj) / (log(mean_back) - log(mean_obj));
    if (temp < -2.220446049250313E-16)
      new_thresh = (int)(temp - 0.5);
    else
      new_thresh = (int)(temp + 0.5);
  } while (fabs(new_thresh - old_thresh) > tolerance);
  return threshold;
}

static int _autothreshME(std::vector<int> data) {
  // Bug fix vs Rvision: max_ent initialised to 0.0 (not +DBL_MAX) so the first
  // tot_ent can win the comparison.
  int threshold = -1, ih, it, first_bin = 0, last_bin = (int)data.size() - 1;
  double tot_ent, max_ent, ent_back, ent_obj;
  int total = 0;
  for (ih = 0; ih < (int)data.size(); ih++) total += data[ih];
  std::vector<double> norm_histo(data.size()), P1(data.size()), P2(data.size());
  for (ih = 0; ih < (int)data.size(); ih++) norm_histo[ih] = (double)data[ih] / total;
  P1[0] = norm_histo[0]; P2[0] = 1.0 - P1[0];
  for (ih = 1; ih < (int)data.size(); ih++) { P1[ih] = P1[ih-1] + norm_histo[ih]; P2[ih] = 1.0 - P1[ih]; }
  for (ih = 0; ih < (int)data.size(); ih++) {
    if (!(fabs(P1[ih]) < 2.220446049250313E-16)) { first_bin = ih; break; }
  }
  for (ih = (int)data.size() - 1; ih >= first_bin; ih--) {
    if (!(fabs(P2[ih]) < 2.220446049250313E-16)) { last_bin = ih; break; }
  }
  max_ent = 0.0; // fixed: was std::numeric_limits<double>::max()
  threshold = first_bin;  // initialize to first_bin in case no valid threshold is found
  for (it = first_bin; it <= last_bin; it++) {
    ent_back = 0.0;
    for (ih = 0; ih <= it; ih++) {
      if (data[ih] != 0)
        ent_back -= (norm_histo[ih] / P1[it]) * log(norm_histo[ih] / P1[it]);
    }
    ent_obj = 0.0;
    for (ih = it + 1; ih < (int)data.size(); ih++) {
      if (data[ih] != 0)
        ent_obj -= (norm_histo[ih] / P2[it]) * log(norm_histo[ih] / P2[it]);
    }
    tot_ent = ent_back + ent_obj;
    if (max_ent < tot_ent) { max_ent = tot_ent; threshold = it; }
  }
  return threshold;
}

static int _autothreshMean(std::vector<int> data) {
  long tot = 0, sum = 0;
  for (int i = 0; i < (int)data.size(); i++) { tot += data[i]; sum += (long)i * data[i]; }
  return (int)(sum / tot);
}

static int _autothreshMinErrorI(std::vector<int> data) {
  int threshold = _autothreshMean(data);
  int Tprev = -2;
  double mu, nu, p, q, sigma2, tau2, w0, w1, w2, sqterm, temp;
  int n = (int)data.size() - 1;
  while (threshold != Tprev) {
    mu     = B_sum(data, threshold) / A_sum(data, threshold);
    nu     = (B_sum(data, n) - B_sum(data, threshold)) / (A_sum(data, n) - A_sum(data, threshold));
    p      = A_sum(data, threshold) / A_sum(data, n);
    q      = (A_sum(data, n) - A_sum(data, threshold)) / A_sum(data, n);
    sigma2 = C_sq(data, threshold) / A_sum(data, threshold) - mu * mu;
    tau2   = (C_sq(data, n) - C_sq(data, threshold)) / (A_sum(data, n) - A_sum(data, threshold)) - nu * nu;
    w0 = 1.0 / sigma2 - 1.0 / tau2;
    w1 = mu / sigma2 - nu / tau2;
    w2 = (mu * mu) / sigma2 - (nu * nu) / tau2 + log10((sigma2 * (q * q)) / (tau2 * (p * p)));
    sqterm = w1 * w1 - w0 * w2;
    if (sqterm < 0) return threshold;
    Tprev = threshold;
    temp = (w1 + sqrt(sqterm)) / w0;
    if (std::isnan(temp))
      threshold = Tprev;
    else
      threshold = (int)floor(temp);
  }
  return threshold;
}

static int _autothreshMinimum(std::vector<int> data) {
  if ((int)data.size() < 2) return 0;
  int iter = 0, threshold = -1, maxi = -1;
  std::vector<double> iHisto(data.size()), tHisto(data.size());
  for (int i = 0; i < (int)data.size(); i++) {
    iHisto[i] = (double)data[i];
    if (data[i] > 0) maxi = i;
  }
  while (!bimodalTest(iHisto)) {
    for (int i = 1; i < (int)data.size() - 1; i++)
      tHisto[i] = (iHisto[i-1] + iHisto[i] + iHisto[i+1]) / 3;
    tHisto[0] = (iHisto[0] + iHisto[1]) / 3;
    tHisto[data.size()-1] = (iHisto[data.size()-2] + iHisto[data.size()-1]) / 3;
    iHisto = tHisto;
    iter++;
    if (iter > 10000) return -1;
  }
  for (int i = 1; i < maxi; i++) {
    if (iHisto[i-1] > iHisto[i] && iHisto[i+1] >= iHisto[i]) { threshold = i; break; }
  }
  return threshold;
}

static int _autothreshMoments(std::vector<int> data) {
  double total = 0, m0 = 1.0, m1 = 0.0, m2 = 0.0, m3 = 0.0, sum = 0.0, p0 = 0.0;
  double cd, c0, c1, z0, z1;
  int threshold = -1;
  std::vector<double> histo(data.size());
  for (int i = 0; i < (int)data.size(); i++) total += data[i];
  for (int i = 0; i < (int)data.size(); i++) histo[i] = data[i] / total;
  for (int i = 0; i < (int)data.size(); i++) {
    m1 += i * histo[i];
    m2 += (double)i * i * histo[i];
    m3 += (double)i * i * i * histo[i];
  }
  cd = m0 * m2 - m1 * m1;
  c0 = (-m2 * m2 + m1 * m3) / cd;
  c1 = (m0 * (-m3) + m2 * m1) / cd;
  z0 = 0.5 * (-c1 - sqrt(c1 * c1 - 4.0 * c0));
  z1 = 0.5 * (-c1 + sqrt(c1 * c1 - 4.0 * c0));
  p0 = (z1 - m1) / (z1 - z0);
  sum = 0;
  for (int i = 0; i < (int)data.size(); i++) {
    sum += histo[i];
    if (sum > p0) { threshold = i; break; }
  }
  return threshold;
}

static int _autothreshOtsu(std::vector<int> data) {
  int ih, threshold = -1, num_pixels = 0;
  double total_mean, bcv, term, max_bcv;
  for (ih = 0; ih < (int)data.size(); ih++) num_pixels += data[ih];
  term = 1.0 / (double)num_pixels;
  std::vector<double> histo(data.size()), cnh(data.size()), mean(data.size(), 0.0);
  for (ih = 0; ih < (int)data.size(); ih++) histo[ih] = term * data[ih];
  cnh[0] = histo[0];
  for (ih = 1; ih < (int)data.size(); ih++) cnh[ih] = cnh[ih-1] + histo[ih];
  for (ih = 1; ih < (int)data.size(); ih++) mean[ih] = mean[ih-1] + ih * histo[ih];
  total_mean = mean[data.size()-1];
  max_bcv = 0.0;
  threshold = std::numeric_limits<int>::min();
  for (ih = 0; ih < (int)data.size(); ih++) {
    bcv = total_mean * cnh[ih] - mean[ih];
    bcv *= bcv / (cnh[ih] * (1.0 - cnh[ih]));
    if (max_bcv < bcv) { max_bcv = bcv; threshold = ih; }
  }
  return threshold;
}

static int _autothreshPercentile(std::vector<int> data) {
  int threshold = -1;
  double ptile = 0.5;
  std::vector<double> avec(data.size(), 0.0);
  double total = partialSum(data, (int)data.size() - 1);
  double temp = 1.0;
  for (int i = 0; i < (int)data.size(); i++) {
    avec[i] = fabs(partialSum(data, i) / total - ptile);
    if (avec[i] < temp) { temp = avec[i]; threshold = i; }
  }
  return threshold;
}

static int _autothreshRenyiEntropy(std::vector<int> data) {
  int threshold, opt_threshold;
  int ih, it, first_bin = 0, last_bin = (int)data.size() - 1;
  int tmp_var, t_star1, t_star2, t_star3, beta1, beta2, beta3;
  double alpha, term, tot_ent, max_ent, ent_back, ent_obj, omega;
  int total = 0;
  for (ih = 0; ih < (int)data.size(); ih++) total += data[ih];
  std::vector<double> norm_histo(data.size()), P1(data.size()), P2(data.size());
  for (ih = 0; ih < (int)data.size(); ih++) norm_histo[ih] = (double)data[ih] / total;
  P1[0] = norm_histo[0]; P2[0] = 1.0 - P1[0];
  for (ih = 1; ih < (int)data.size(); ih++) { P1[ih] = P1[ih-1] + norm_histo[ih]; P2[ih] = 1.0 - P1[ih]; }
  for (ih = 0; ih < (int)data.size(); ih++) {
    if (!(fabs(P1[ih]) < 2.220446049250313E-16)) { first_bin = ih; break; }
  }
  for (ih = (int)data.size() - 1; ih >= first_bin; ih--) {
    if (!(fabs(P2[ih]) < 2.220446049250313E-16)) { last_bin = ih; break; }
  }
  // alpha = 1
  threshold = 0; max_ent = 0.0;
  for (it = first_bin; it <= last_bin; it++) {
    ent_back = 0.0;
    for (ih = 0; ih <= it; ih++)
      if (data[ih] != 0) ent_back -= (norm_histo[ih] / P1[it]) * log(norm_histo[ih] / P1[it]);
    ent_obj = 0.0;
    for (ih = it + 1; ih < (int)data.size(); ih++)
      if (data[ih] != 0) ent_obj -= (norm_histo[ih] / P2[it]) * log(norm_histo[ih] / P2[it]);
    tot_ent = ent_back + ent_obj;
    if (max_ent < tot_ent) { max_ent = tot_ent; threshold = it; }
  }
  t_star2 = threshold;
  // alpha = 0.5
  threshold = 0; max_ent = 0.0; alpha = 0.5; term = 1.0 / (1.0 - alpha);
  for (it = first_bin; it <= last_bin; it++) {
    ent_back = 0.0;
    for (ih = 0; ih <= it; ih++) ent_back += sqrt(norm_histo[ih] / P1[it]);
    ent_obj = 0.0;
    for (ih = it + 1; ih < (int)data.size(); ih++) ent_obj += sqrt(norm_histo[ih] / P2[it]);
    tot_ent = term * ((ent_back * ent_obj) > 0.0 ? log(ent_back * ent_obj) : 0.0);
    if (tot_ent > max_ent) { max_ent = tot_ent; threshold = it; }
  }
  t_star1 = threshold;
  // alpha = 2
  threshold = 0; max_ent = 0.0; alpha = 2.0; term = 1.0 / (1.0 - alpha);
  for (it = first_bin; it <= last_bin; it++) {
    ent_back = 0.0;
    for (ih = 0; ih <= it; ih++) ent_back += (norm_histo[ih] * norm_histo[ih]) / (P1[it] * P1[it]);
    ent_obj = 0.0;
    for (ih = it + 1; ih < (int)data.size(); ih++) ent_obj += (norm_histo[ih] * norm_histo[ih]) / (P2[it] * P2[it]);
    tot_ent = term * ((ent_back * ent_obj) > 0.0 ? log(ent_back * ent_obj) : 0.0);
    if (tot_ent > max_ent) { max_ent = tot_ent; threshold = it; }
  }
  t_star3 = threshold;
  // sort t_star values
  if (t_star2 < t_star1) { tmp_var = t_star1; t_star1 = t_star2; t_star2 = tmp_var; }
  if (t_star3 < t_star2) { tmp_var = t_star2; t_star2 = t_star3; t_star3 = tmp_var; }
  if (t_star2 < t_star1) { tmp_var = t_star1; t_star1 = t_star2; t_star2 = tmp_var; }
  if (abs(t_star1 - t_star2) <= 5) {
    if (abs(t_star2 - t_star3) <= 5) { beta1 = 1; beta2 = 2; beta3 = 1; }
    else                              { beta1 = 0; beta2 = 1; beta3 = 3; }
  } else {
    if (abs(t_star2 - t_star3) <= 5) { beta1 = 3; beta2 = 1; beta3 = 0; }
    else                              { beta1 = 1; beta2 = 2; beta3 = 1; }
  }
  omega = P1[t_star3] - P1[t_star1];
  opt_threshold = (int)(t_star1 * (P1[t_star1] + 0.25 * omega * beta1) +
                        0.25 * t_star2 * omega * beta2 +
                        t_star3 * (P2[t_star3] + 0.25 * omega * beta3));
  return opt_threshold;
}

static int _autothreshShanbhag(std::vector<int> data) {
  int threshold = -1, ih, it, first_bin = 0, last_bin = (int)data.size() - 1;
  double term, tot_ent, min_ent, ent_back, ent_obj;
  int total = 0;
  for (ih = 0; ih < (int)data.size(); ih++) total += data[ih];
  std::vector<double> norm_histo(data.size()), P1(data.size()), P2(data.size());
  for (ih = 0; ih < (int)data.size(); ih++) norm_histo[ih] = (double)data[ih] / total;
  P1[0] = norm_histo[0]; P2[0] = 1.0 - P1[0];
  for (ih = 1; ih < (int)data.size(); ih++) { P1[ih] = P1[ih-1] + norm_histo[ih]; P2[ih] = 1.0 - P1[ih]; }
  for (ih = 0; ih < (int)data.size(); ih++) {
    if (!(fabs(P1[ih]) < 2.220446049250313E-16)) { first_bin = ih; break; }
  }
  for (ih = (int)data.size() - 1; ih >= first_bin; ih--) {
    if (!(fabs(P2[ih]) < 2.220446049250313E-16)) { last_bin = ih; break; }
  }
  min_ent = std::numeric_limits<double>::max();
  for (it = first_bin; it <= last_bin; it++) {
    ent_back = 0.0;
    term = 0.5 / P1[it];
    for (ih = 1; ih <= it; ih++) ent_back -= norm_histo[ih] * log(1.0 - term * P1[ih-1]);
    ent_back *= term;
    ent_obj = 0.0;
    term = 0.5 / P2[it];
    for (ih = it + 1; ih < (int)data.size(); ih++) ent_obj -= norm_histo[ih] * log(1.0 - term * P2[ih]);
    ent_obj *= term;
    tot_ent = fabs(ent_back - ent_obj);
    if (tot_ent < min_ent) { min_ent = tot_ent; threshold = it; }
  }
  return threshold;
}

// _autothreshTriangle takes data by value because it may reverse the vector in-place.
static int _autothreshTriangle(std::vector<int> data) {
  int min_val = 0, dmax = 0, max_val = 0, min2 = 0;
  for (int i = 0; i < (int)data.size(); i++) {
    if (data[i] > 0) { min_val = i; break; }
  }
  if (min_val > 0) min_val--;
  for (int i = (int)data.size() - 1; i > 0; i--) {
    if (data[i] > 0) { min2 = i; break; }
  }
  if (min2 < (int)data.size() - 1) min2++;
  for (int i = 0; i < (int)data.size(); i++) {
    if (data[i] > dmax) { max_val = i; dmax = data[i]; }
  }
  bool inverted = false;
  if ((max_val - min_val) < (min2 - max_val)) {
    inverted = true;
    int left = 0, right = (int)data.size() - 1;
    while (left < right) { int t = data[left]; data[left] = data[right]; data[right] = t; left++; right--; }
    min_val = (int)data.size() - 1 - min2;
    max_val  = (int)data.size() - 1 - max_val;
  }
  if (min_val == max_val) return min_val;
  double nx = data[max_val];
  double ny = min_val - max_val;
  double d  = sqrt(nx * nx + ny * ny);
  nx /= d; ny /= d;
  d = nx * min_val + ny * data[min_val];
  int split = min_val;
  double splitDistance = 0;
  for (int i = min_val + 1; i <= max_val; i++) {
    double newDistance = nx * i + ny * data[i] - d;
    if (newDistance > splitDistance) { split = i; splitDistance = newDistance; }
  }
  split--;
  if (inverted) return (int)data.size() - 1 - split;
  return split;
}

static int _autothreshYen(std::vector<int> data) {
  // Bug fix vs Rvision: max_crit initialised to -DBL_MAX (not +DBL_MAX) so the
  // first crit value can win the comparison.
  int threshold = -1, ih, it;
  double crit, max_crit;
  int total = 0;
  for (ih = 0; ih < (int)data.size(); ih++) total += data[ih];
  std::vector<double> norm_histo(data.size()), P1(data.size()), P1_sq(data.size()), P2_sq(data.size());
  for (ih = 0; ih < (int)data.size(); ih++) norm_histo[ih] = (double)data[ih] / total;
  P1[0] = norm_histo[0];
  for (ih = 1; ih < (int)data.size(); ih++) P1[ih] = P1[ih-1] + norm_histo[ih];
  P1_sq[0] = norm_histo[0] * norm_histo[0];
  for (ih = 1; ih < (int)data.size(); ih++) P1_sq[ih] = P1_sq[ih-1] + norm_histo[ih] * norm_histo[ih];
  P2_sq[(int)data.size()-1] = 0.0;
  for (ih = (int)data.size() - 2; ih >= 0; ih--) P2_sq[ih] = P2_sq[ih+1] + norm_histo[ih+1] * norm_histo[ih+1];
  max_crit = -std::numeric_limits<double>::max(); // fixed: was +max()
  for (it = 0; it < (int)data.size(); it++) {
    crit = -1.0 * ((P1_sq[it] * P2_sq[it]) > 0.0 ? log(P1_sq[it] * P2_sq[it]) : 0.0) +
           2.0  * ((P1[it]    * (1.0 - P1[it])) > 0.0 ? log(P1[it] * (1.0 - P1[it])) : 0.0);
    if (crit > max_crit) { max_crit = crit; threshold = it; }
  }
  return threshold;
}

// ── rt_autothreshold_value ────────────────────────────────────────────────────

[[cpp11::register]]
double rt_autothreshold_value(external_pointer<RtImage> img,
                               std::string method, int bins) {
  cv::Mat src = get_cpu_mat(img);
  std::vector<int> hist;
  double min_val = 0.0, max_val = 0.0;

  if (src.depth() == CV_8U) {
    hist.resize(256, 0);
    for (int r = 0; r < src.rows; r++) {
      const uchar* row = src.ptr<uchar>(r);
      for (int c = 0; c < src.cols; c++) hist[row[c]]++;
    }
    min_val = 0.0;
    max_val = 255.0;
  } else {
    cv::minMaxLoc(src, &min_val, &max_val);
    int hist_size = bins;
    float range_lo = (float)min_val;
    float range_hi = (float)(max_val + 1e-6);
    float range_arr[2] = { range_lo, range_hi };
    const float* ranges[] = { range_arr };
    int channel = 0;
    cv::Mat hist_mat;
    cv::calcHist(&src, 1, &channel, cv::Mat(), hist_mat, 1, &hist_size, ranges);
    hist.resize(bins);
    for (int i = 0; i < bins; i++) hist[i] = (int)hist_mat.at<float>(i);
  }

  int bin_idx;
  if      (method == "imagej")       bin_idx = _autothreshIJ(hist);
  else if (method == "huang")        bin_idx = _autothreshHuang(hist);
  else if (method == "huang2")       bin_idx = _autothreshHuang2(hist);
  else if (method == "intermodes")   bin_idx = _autothreshIM(hist);
  else if (method == "isodata")      bin_idx = _autothreshIsoData(hist);
  else if (method == "li")           bin_idx = _autothreshLi(hist);
  else if (method == "maxentropy")   bin_idx = _autothreshME(hist);
  else if (method == "mean")         bin_idx = _autothreshMean(hist);
  else if (method == "minerrori")    bin_idx = _autothreshMinErrorI(hist);
  else if (method == "minimum")      bin_idx = _autothreshMinimum(hist);
  else if (method == "moments")      bin_idx = _autothreshMoments(hist);
  else if (method == "otsu")         bin_idx = _autothreshOtsu(hist);
  else if (method == "percentile")   bin_idx = _autothreshPercentile(hist);
  else if (method == "renyientropy") bin_idx = _autothreshRenyiEntropy(hist);
  else if (method == "shanbhag")     bin_idx = _autothreshShanbhag(hist);
  else if (method == "triangle")     bin_idx = _autothreshTriangle(hist);
  else if (method == "yen")          bin_idx = _autothreshYen(hist);
  else stop("unknown autothreshold method '%s'", method.c_str());

  if (bin_idx < 0)
    stop("autothreshold method '%s' failed to converge for this image",
         method.c_str());

  if (src.depth() == CV_8U) return (double)bin_idx;
  if (bins == 1) return min_val;
  return min_val + bin_idx * (max_val - min_val) / (bins - 1);
}
