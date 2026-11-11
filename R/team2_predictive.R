# TEAM 2 -- Predictive values (Bayes' theorem).
# Tests: tests/testthat/test-team2-predictive.R
# Do NOT call functions owned by other teams (compute Beta means inline).

#' Positive predictive value
#'
#' @param se,sp Sensitivity and specificity (vectorised).
#' @param prev Prevalence (a number, or a vector recycled against `se`/`sp`).
#' @return `P(D | T+) = se * prev / (se * prev + (1 - sp) * (1 - prev))`.
#' @export
ppv_fn <- function(se, sp, prev) {
  stop("TODO(team2): implement ppv_fn()")
}

#' Negative predictive value
#' @inheritParams ppv_fn
#' @return `P(D^c | T-) = sp * (1 - prev) / (sp * (1 - prev) + (1 - se) * prev)`.
#' @export
npv_fn <- function(se, sp, prev) {
  stop("TODO(team2): implement npv_fn()")
}

#' Posterior-predictive PPV for a new person who tests positive
#'
#' With independent Beta distributions for Se and Sp, a new person's probabilities
#' of testing positive are the posterior means: `P(T+ | D) = E[Se]` and
#' `P(T+ | D^c) = E[1 - Sp]`. Hence
#' `P(D | T+) = prev * E[Se] / (prev * E[Se] + (1 - prev) * E[1 - Sp])`,
#' a ratio of posterior **means**, not the posterior mean of the PPV.
#'
#' @param se_ab,sp_ab Named numeric `c(a = , b = )` for the Beta distributions.
#' @param prev Prevalence (a number).
#' @return A single number.
#' @export
ppv_predictive <- function(se_ab, sp_ab, prev) {
  stop("TODO(team2): implement ppv_predictive()")
}
