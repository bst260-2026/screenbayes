# TEAM 6 -- The posterior plot.
# Tests: tests/testthat/test-team6-plot.R  (uses a hand-made summary list, so
# you do not depend on the other teams).

#' Plot a posterior density with point and interval summaries
#'
#' The base density curve is provided. Add the four layers marked TODO.
#'
#' @param draws Numeric vector of posterior draws in \[0, 1\].
#' @param s A list as returned by [summarise_posterior()]: `s$point` (named
#'   numeric `c(mean = , median = , MAP = )`), `s$eti` and `s$hdi` (each
#'   `c(lower, upper)`), `s$hpd` (data frame with columns `lower`, `upper`, one
#'   row per piece).
#' @param xlab x-axis label.
#' @param threshold Optional number; if not `NULL`, draw a dashed vertical line
#'   there and annotate with `P(value >= threshold)` computed from `draws`.
#' @return A ggplot object.
#' @export
posterior_plot <- function(draws, s, xlab = "value", threshold = NULL) {
  d  <- density(draws, from = 0, to = 1, n = 1024)
  dd <- tibble::tibble(x = d$x, y = d$y)

  p <- ggplot(dd, aes(x, y)) +
    geom_line(linewidth = 0.8) +
    scale_colour_brewer(palette = "Dark2", name = NULL) +
    scale_linetype_discrete(name = NULL) +
    labs(x = xlab, y = "posterior density") +
    theme_minimal(base_size = 13)

  # TODO 1: shade the area under the curve that lies inside the HPD region
  #   s$hpd. There can be several pieces, so give each its own `group`
  #   (hint: geom_area(data = ..., aes(group = piece), alpha = 0.4)).

  # TODO 2: add one vertical line per point estimate in s$point (mean, median,
  #   MAP), with a different colour AND linetype for each (geom_vline, with a
  #   small tibble of estimate names and values mapped in aes()).

  # TODO 3: below the curve (negative y) draw horizontal bars for the
  #   equal-tailed interval, the HDI, and each piece of the HPD region
  #   (geom_segment, colour = method, linewidth about 2.5, y offsets of
  #   -0.04, -0.08, -0.12 times max(dd$y)).

  # TODO 4: if `threshold` is not NULL, add a dashed vertical line there and
  #   annotate the plot with P(value >= threshold) computed from `draws`.
  p
}
