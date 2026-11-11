# TEAM 5 -- Isolating target populations; uncertainty about prevalence.
# Tests: tests/testthat/test-team5-populations.R
# Do NOT call functions owned by other teams.

#' Prevalence of LBW in a sub-population
#'
#' @param data Data frame with a 0/1 column `lbw`, such as [bw_data()].
#' @param ... Conditions passed to [dplyr::filter()]; with none, all of `data`.
#'   Example: `stratum_prevalence(bw, smoke == 1, ht == 0)`.
#' @return The mean of `lbw` among the selected rows.
#' @export
stratum_prevalence <- function(data, ...) {
  stop("TODO(team5): implement stratum_prevalence()")
}

#' Beta posterior for the prevalence in a sub-population
#'
#' With `k` LBW births among `n` selected, a Beta(`prior_a`, `prior_b`) prior gives
#' a Beta(`prior_a + k`, `prior_b + n - k`) posterior for the prevalence.
#'
#' @inheritParams stratum_prevalence
#' @param prior Named numeric `c(a = , b = )`; the default is the flat Beta(1, 1).
#' @return Named numeric `c(a = , b = )`.
#' @export
stratum_beta <- function(data, ..., prior = c(a = 1, b = 1)) {
  stop("TODO(team5): implement stratum_beta()")
}

#' Draws of the prevalence, known or uncertain
#'
#' @param n Number of draws.
#' @param prev A number: the (known) prevalence. Used when `prior` is `NULL`.
#' @param prior `NULL`, or a named numeric `c(a = , b = )`: the prevalence is then
#'   uncertain with a Beta(a, b) distribution.
#' @return A numeric vector of length `n`: `rep(prev, n)` if `prior` is `NULL`,
#'   otherwise draws from the Beta distribution ([stats::rbeta()]).
#' @export
prev_draws <- function(n, prev = NULL, prior = NULL) {
  stop("TODO(team5): implement prev_draws()")
}
