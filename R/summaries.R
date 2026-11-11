# PROVIDED -- glue between the teams' functions. Not owned by any team.
# summarise_posterior() calls: eti_draws, hdi_draws (team 3), hpd_region,
# map_kde (team 4).  target_populations() calls stratum_prevalence (team 5).

#' Draw from independent Beta posteriors for Se and Sp
#'
#' @param n Number of draws.
#' @param se_ab,sp_ab Named numeric `c(a = , b = )`.
#' @param prev Prevalence: a number, or a vector of length `n` (for example from
#'   [prev_draws()]).
#' @return A tibble with columns `se`, `sp`, `ppv`, `npv`.
#' @export
post_draws <- function(n, se_ab, sp_ab, prev) {
  se <- rbeta(n, se_ab[["a"]], se_ab[["b"]])
  sp <- rbeta(n, sp_ab[["a"]], sp_ab[["b"]])
  tibble::tibble(se = se, sp = sp,
                 ppv = ppv_fn(se, sp, prev),
                 npv = npv_fn(se, sp, prev))
}

#' Fraction of draws inside a union of intervals
#' @param draws Numeric vector.
#' @param region Data frame with columns `lower` and `upper`, e.g. from [hpd_region()].
#' @return A number in \[0, 1\].
#' @export
mass_in_region <- function(draws, region) {
  inside <- rep(FALSE, length(draws))
  for (i in seq_len(nrow(region)))
    inside <- inside | (draws >= region$lower[i] & draws <= region$upper[i])
  mean(inside)
}

#' Prevalence of LBW in each target population of `birthwt`
#' @param data Defaults to [bw_data()].
#' @return Named numeric vector (names are [population_labels]).
#' @export
target_populations <- function(data = bw_data()) {
  out <- c(
    stratum_prevalence(data),
    stratum_prevalence(data, smoke == 1),
    stratum_prevalence(data, smoke == 0),
    stratum_prevalence(data, ht == 1),
    stratum_prevalence(data, ptl_pos == 1),
    stratum_prevalence(data, race == "black")
  )
  setNames(out, population_labels)
}

#' Point and interval summaries of posterior draws
#' @param draws Numeric vector in \[0, 1\].
#' @param mass Interval mass.
#' @param adjust Kernel bandwidth multiplier for the MAP and HPD region.
#' @return A list with `point` (mean, median, MAP), `eti`, `hdi`, `hpd`, `hpd_mass`.
#' @export
summarise_posterior <- function(draws, mass = 0.95, adjust = 1) {
  hpd <- hpd_region(draws, mass, adjust)
  list(
    point    = c(mean = mean(draws), median = median(draws),
                 MAP = map_kde(draws, adjust)),
    eti      = eti_draws(draws, mass),
    hdi      = hdi_draws(draws, mass),
    hpd      = hpd,
    hpd_mass = mass_in_region(draws, hpd)
  )
}

#' Format numbers for display
#' @param x Numeric.
#' @param digits Decimal places.
#' @return Character vector ("NA" for missing values).
#' @export
fmt <- function(x, digits = 3) {
  ifelse(is.na(x), "NA", formatC(x, digits = digits, format = "f"))
}

#' Summary table for the app
#' @param s Result of [summarise_posterior()].
#' @param mass Interval mass used.
#' @param draws The draws summarised.
#' @param threshold Clinical threshold.
#' @return A tibble with columns `Summary` and `Value`.
#' @export
summary_table <- function(s, mass, draws, threshold) {
  pct <- paste0(round(100 * mass), "%")
  hpd_txt <- paste0("[", fmt(s$hpd$lower), ", ", fmt(s$hpd$upper), "]", collapse = " U ")
  tibble::tibble(
    Summary = c("Posterior mean", "Posterior median", "MAP (mode of kernel density)",
                paste(pct, "equal-tailed interval"),
                paste(pct, "HDI (shortest interval)"),
                paste(pct, "HPD region (density threshold)"),
                "Posterior mass actually inside the HPD region",
                paste0("P(value >= ", threshold, ")")),
    Value = c(fmt(s$point[["mean"]]), fmt(s$point[["median"]]), fmt(s$point[["MAP"]]),
              paste0("[", fmt(s$eti[1]), ", ", fmt(s$eti[2]), "]"),
              paste0("[", fmt(s$hdi[1]), ", ", fmt(s$hdi[2]), "]"),
              hpd_txt, fmt(s$hpd_mass), fmt(prob_exceeds(draws, threshold)))
  )
}

#' Closed-form summaries of a Beta distribution
#' @param ab Named numeric `c(a = , b = )`.
#' @param mass Interval mass.
#' @return A tibble with columns `Summary` and `Value`.
#' @export
beta_table <- function(ab, mass = 0.95) {
  a <- ab[["a"]]; b <- ab[["b"]]
  e <- eti_beta(a, b, mass); h <- hdi_beta(a, b, mass)
  tibble::tibble(
    Summary = c("a, b", "Mean", "Median", "Mode", "Equal-tailed interval", "HDI"),
    Value = c(paste0(fmt(a, 2), ", ", fmt(b, 2)),
              fmt(beta_mean(a, b)), fmt(beta_median(a, b)), fmt(beta_mode(a, b)),
              paste0("[", fmt(e[1]), ", ", fmt(e[2]), "]"),
              paste0("[", fmt(h[1]), ", ", fmt(h[2]), "]"))
  )
}

#' Posterior of the PPV over a grid of prevalences
#' @param se_ab,sp_ab Named numeric `c(a = , b = )`.
#' @param prevs Numeric vector of prevalences.
#' @param mass Interval mass.
#' @param n Number of draws.
#' @param threshold Threshold for `P(PPV >= threshold)`.
#' @param seed Random seed.
#' @return A tibble with `prev`, `median`, `lo`, `hi`, `p_exceed`.
#' @export
sweep_ppv <- function(se_ab, sp_ab, prevs, mass = 0.95, n = 20000,
                      threshold = 0.5, seed = 260) {
  set.seed(seed)
  se <- rbeta(n, se_ab[["a"]], se_ab[["b"]])
  sp <- rbeta(n, sp_ab[["a"]], sp_ab[["b"]])
  dplyr::bind_rows(lapply(prevs, function(p) {
    ppv <- ppv_fn(se, sp, p)
    tibble::tibble(prev = p, median = median(ppv),
                   lo = unname(quantile(ppv, (1 - mass) / 2)),
                   hi = unname(quantile(ppv, (1 + mass) / 2)),
                   p_exceed = mean(ppv >= threshold))
  }))
}

#' Launch the screening app
#' @param ... Passed to [shiny::runApp()].
#' @return Called for its side effect.
#' @export
run_app <- function(...) {
  app_dir <- system.file("app", package = "screenbayes")
  if (!nzchar(app_dir)) stop("Could not find the app; is screenbayes installed or loaded with pkgload::load_all()?")
  shiny::runApp(app_dir, ...)
}
