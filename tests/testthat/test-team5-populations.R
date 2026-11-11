test_that("stratum_prevalence with no conditions is the overall prevalence", {
  expect_equal(stratum_prevalence(bw_data()), 59 / 189)
})

test_that("stratum_prevalence applies one or several conditions", {
  bw <- bw_data()
  expect_equal(stratum_prevalence(bw, smoke == 1), 30 / 74)
  expect_equal(stratum_prevalence(bw, smoke == 1, ht == 1),
               mean(bw$lbw[bw$smoke == 1 & bw$ht == 1]))
})

test_that("stratum_beta is the Beta posterior of the prevalence", {
  bw <- bw_data()
  expect_equal(stratum_beta(bw, smoke == 1), c(a = 31, b = 45))
  expect_equal(stratum_beta(bw, smoke == 1, prior = c(a = 0.5, b = 0.5)),
               c(a = 30.5, b = 44.5))
  expect_named(stratum_beta(bw), c("a", "b"))
})

test_that("prev_draws with a known prevalence repeats it", {
  expect_equal(prev_draws(5, prev = 0.08), rep(0.08, 5))
})

test_that("prev_draws with a prior draws from the Beta", {
  set.seed(1)
  x <- prev_draws(2e4, prior = c(a = 8, b = 6))
  expect_length(x, 2e4)
  expect_true(all(x > 0 & x < 1))
  expect_equal(mean(x), 8 / 14, tolerance = 0.01)
  expect_gt(sd(x), 0)
})
