# PROVIDED -- not owned by any team. Data, constants, and small helpers.

#' Low birth weight data with indicator variables used in the course
#'
#' [MASS::birthwt] (189 births, Baystate Medical Center, 1986) with extra
#' columns: `lbw` (1 = birth weight under 2500 g), `ptl_pos` (any previous
#' premature labour), `lwt_low` (mother's weight under 110 lb) and `race` as a
#' labelled factor.
#'
#' @return A tibble with 189 rows.
#' @export
bw_data <- function() {
  MASS::birthwt |>
    tibble::as_tibble() |>
    dplyr::mutate(
      lbw     = low,
      ptl_pos = as.integer(ptl > 0),
      lwt_low = as.integer(lwt < 110),
      race    = factor(race, 1:3, c("white", "black", "other"))
    )
}

#' Binary indicators in `birthwt` treated as crude screening tests for LBW
#' @export
test_choices <- c(
  "Previous premature labour" = "ptl_pos",
  "History of hypertension"   = "ht",
  "Uterine irritability"      = "ui",
  "Low maternal weight"       = "lwt_low"
)

#' Prevalences we simply assume for populations outside the sample
#' @export
assumed_populations <- c(
  "Assumed US-wide (0.08)"         = 0.08,
  "Assumed specialised (0.015)"    = 0.015,
  "Assumed rare screening (0.001)" = 0.001
)

#' Labels of the sub-populations of `birthwt` isolated by [target_populations()]
#' @export
population_labels <- c(
  "All births (sample)", "Smokers", "Non-smokers",
  "History of hypertension", "Previous premature labour", "Black mothers"
)

#' 2x2 counts of a binary test against LBW
#'
#' @param var Name of a 0/1 column of `data` (see [test_choices]).
#' @param data Data frame with columns `lbw` and `var`; default [bw_data()].
#' @return Named numeric `c(tp, fn, tn, fp)`: tp = test+ & LBW, fn = test- & LBW,
#'   tn = test- & not LBW, fp = test+ & not LBW.
#' @export
test_counts <- function(var, data = bw_data()) {
  t <- data[[var]]; y <- data$lbw
  c(tp = sum(t == 1 & y == 1), fn = sum(t == 0 & y == 1),
    tn = sum(t == 0 & y == 0), fp = sum(t == 1 & y == 0))
}

#' Size and number of LBW births in a sub-population
#' @param data Data frame with column `lbw`.
#' @param ... Conditions passed to [dplyr::filter()].
#' @return Named numeric `c(n, k)`.
#' @export
strat_counts <- function(data, ...) {
  d <- dplyr::filter(data, ...)
  c(n = nrow(d), k = sum(d$lbw))
}

#' Size and LBW count for each target population
#' @param data Defaults to [bw_data()].
#' @return A tibble with columns `population`, `n`, `k`.
#' @export
population_counts <- function(data = bw_data()) {
  cts <- list(
    strat_counts(data),
    strat_counts(data, smoke == 1),
    strat_counts(data, smoke == 0),
    strat_counts(data, ht == 1),
    strat_counts(data, ptl_pos == 1),
    strat_counts(data, race == "black")
  )
  tibble::tibble(population = population_labels,
                 n = vapply(cts, `[[`, numeric(1), "n"),
                 k = vapply(cts, `[[`, numeric(1), "k"))
}
