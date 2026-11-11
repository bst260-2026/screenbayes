# TEAM 3 -- Interval estimates (equal-tailed and highest-density intervals).
# Tests: tests/testthat/test-team3-intervals.R
# Do NOT call functions owned by other teams.

#' Equal-tailed interval of a Beta(a, b)
#'
#' @param a,b Shape parameters.
#' @param mass Probability content of the interval, in (0, 1).
#' @return Numeric `c(lower, upper)` with probability `(1 - mass) / 2` in each tail.
#' @export
eti_beta <- function(a, b, mass = 0.95) {
  stop("TODO(team3): implement eti_beta()")
}

#' Highest-density (shortest) interval of a Beta(a, b)
#'
#' Hint: an interval `[qbeta(p), qbeta(p + mass)]` always has probability `mass`;
#' choose `p` in `[0, 1 - mass]` to minimise its width ([stats::optimize()]).
#' Also compare the end points `p = 0` and `p = 1 - mass`, which matter for
#' J-shaped densities.
#'
#' @inheritParams eti_beta
#' @return Numeric `c(lower, upper)`.
#' @export
hdi_beta <- function(a, b, mass = 0.95) {
  stop("TODO(team3): implement hdi_beta()")
}

#' Equal-tailed interval from draws
#'
#' @param draws Numeric vector of posterior draws.
#' @param mass Probability content, in (0, 1).
#' @return Unnamed numeric `c(lower, upper)`.
#' @export
eti_draws <- function(draws, mass = 0.95) {
  stop("TODO(team3): implement eti_draws()")
}

#' Shortest interval containing a fraction of the draws
#'
#' Hint: sort the draws; among all windows of `k = ceiling(mass * n)` consecutive
#' sorted values, take the one with the smallest width.
#'
#' @inheritParams eti_draws
#' @return Unnamed numeric `c(lower, upper)`.
#' @export
hdi_draws <- function(draws, mass = 0.95) {
  stop("TODO(team3): implement hdi_draws()")
}
