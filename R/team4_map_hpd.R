# TEAM 4 -- Mode (MAP) and HPD region from draws; tail probabilities.
# Tests: tests/testthat/test-team4-map_hpd.R
# Do NOT call functions owned by other teams.

#' Posterior mode of a quantity in \[0, 1\], from draws
#'
#' The location of the maximum of
#' `density(draws, from = 0, to = 1, n = 2048, adjust = adjust)`.
#'
#' @param draws Numeric vector of draws in \[0, 1\].
#' @param adjust Bandwidth multiplier passed to [stats::density()].
#' @return A single number.
#' @export
map_kde <- function(draws, adjust = 1) {
  stop("TODO(team4): implement map_kde()")
}

#' HPD region from draws
#'
#' The set `{x : f(x) >= c}` where the threshold `c` is chosen so that the set
#' holds `mass` of the estimated posterior. Unlike an interval it may have several
#' pieces. Steps: (1) kernel density estimate on a grid of \[0, 1\] (as in
#' [map_kde()]), renormalised so that `sum(f) * dx = 1`; (2) order grid points
#' from highest to lowest density; (3) accumulate `f * dx` in that order until the
#' total reaches `mass`; (4) the grid points used form the region: split them into
#' contiguous runs ([rle()] helps).
#'
#' @inheritParams map_kde
#' @param mass Posterior mass of the region, in (0, 1).
#' @return A data frame with columns `lower` and `upper`, one row per piece, in
#'   increasing order.
#' @export
hpd_region <- function(draws, mass = 0.95, adjust = 1) {
  stop("TODO(team4): implement hpd_region()")
}

#' Posterior probability that a quantity is at least a threshold
#'
#' @param draws Numeric vector of draws.
#' @param threshold A number.
#' @return The fraction of `draws` that are `>= threshold`.
#' @export
prob_exceeds <- function(draws, threshold) {
  stop("TODO(team4): implement prob_exceeds()")
}
