# TEAM 1 -- Beta utilities.   Owners: see .github/CODEOWNERS
# Contract: a Beta distribution is passed around as a named numeric vector
# c(a = ..., b = ...).  Tests: tests/testthat/test-team1-beta.R
# Do NOT call functions owned by other teams.

#' Beta distribution from a mean and a prior sample size
#'
#' @param m Mean, in (0, 1).
#' @param n Prior sample size `a + b`, positive.
#' @return Named numeric `c(a = , b = )` with mean `m` and `a + b = n`.
#' @export
beta_from_mean_n <- function(m, n) {
  stop("TODO(team1): implement beta_from_mean_n()")
}

#' Mean of a Beta(a, b)
#' @param a,b Shape parameters.
#' @return The mean.
#' @export
beta_mean <- function(a, b) {
  stop("TODO(team1): implement beta_mean()")
}

#' Median of a Beta(a, b)
#' @inheritParams beta_mean
#' @return The median.
#' @export
beta_median <- function(a, b) {
  stop("TODO(team1): implement beta_median()")
}

#' Mode of a Beta(a, b)
#'
#' Cases: `a > 1` and `b > 1` gives the interior mode `(a - 1) / (a + b - 2)`;
#' `a <= 1` and `b > 1` is decreasing, so the maximum is at 0; `b <= 1` and
#' `a > 1` is increasing, so the maximum is at 1; `a <= 1` and `b <= 1` is
#' uniform or U-shaped, so there is no unique mode and the result is `NA_real_`.
#'
#' @inheritParams beta_mean
#' @return A single number or `NA_real_`.
#' @export
beta_mode <- function(a, b) {
  stop("TODO(team1): implement beta_mode()")
}

#' Conjugate Beta update for binomial data
#'
#' @param a,b Prior shape parameters.
#' @param successes,failures Observed counts. May carry names (for example
#'   `test_counts("ptl_pos")["tp"]`); the result must not inherit them (see
#'   [unname()]).
#' @return Named numeric `c(a = a + successes, b = b + failures)` with exactly
#'   the names `a` and `b`.
#' @export
update_beta <- function(a, b, successes, failures) {
  stop("TODO(team1): implement update_beta()")
}
