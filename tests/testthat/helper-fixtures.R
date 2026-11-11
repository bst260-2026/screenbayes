# Fixtures shared by the tests.  A fixed, hand-made posterior summary lets
# team 6 test the plot without depending on the other teams.
fx_draws <- local({ set.seed(1); rbeta(5000, 3, 9) })

fx_summary <- list(
  point = c(mean = 0.25, median = 0.24, MAP = 0.22),
  eti   = c(0.07, 0.52),
  hdi   = c(0.05, 0.48),
  hpd   = data.frame(lower = 0.05, upper = 0.48),
  hpd_mass = 0.95
)

fx_summary_2pieces <- fx_summary
fx_summary_2pieces$hpd <- data.frame(lower = c(0, 0.8), upper = c(0.2, 1))

layer_geoms <- function(p) vapply(p$layers, function(l) class(l$geom)[1], character(1))
