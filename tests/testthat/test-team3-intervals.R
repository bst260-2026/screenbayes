test_that("eti_beta has the requested mass and equal tails", {
  e <- eti_beta(3, 9, 0.9)
  expect_length(e, 2)
  expect_equal(diff(pbeta(e, 3, 9)), 0.9)
  expect_equal(pbeta(e[1], 3, 9), 0.05)
  expect_equal(eti_beta(3, 9)[2] > eti_beta(3, 9)[1], TRUE)  # default mass 0.95
})

test_that("hdi_beta has the requested mass and equal density at both ends", {
  h <- hdi_beta(3, 9, 0.9)
  expect_equal(diff(pbeta(h, 3, 9)), 0.9, tolerance = 1e-5)
  expect_equal(dbeta(h[1], 3, 9), dbeta(h[2], 3, 9), tolerance = 1e-3)
})

test_that("hdi_beta is shorter than the equal-tailed interval for a skewed Beta", {
  expect_lt(diff(hdi_beta(2, 12, 0.9)), diff(eti_beta(2, 12, 0.9)))
})

test_that("hdi_beta equals the equal-tailed interval for a symmetric Beta", {
  expect_equal(hdi_beta(10, 10, 0.9), eti_beta(10, 10, 0.9), tolerance = 1e-5)
})

test_that("hdi_beta of a decreasing density starts at 0", {
  h <- hdi_beta(1, 5, 0.9)
  expect_equal(h[1], 0, tolerance = 1e-6)
  expect_equal(diff(pbeta(h, 1, 5)), 0.9, tolerance = 1e-5)
})

test_that("eti_draws and hdi_draws agree with the closed forms", {
  set.seed(1); x <- rbeta(5e4, 3, 9)
  expect_lt(max(abs(eti_draws(x, 0.9) - eti_beta(3, 9, 0.9))), 0.01)
  expect_lt(max(abs(hdi_draws(x, 0.9) - hdi_beta(3, 9, 0.9))), 0.01)
})

test_that("eti_draws and hdi_draws return unnamed length-2 vectors", {
  x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
  expect_null(names(eti_draws(x, 0.5)))
  expect_length(hdi_draws(x, 0.5), 2)
})

test_that("hdi_draws holds at least the requested fraction of the draws", {
  set.seed(1); x <- rbeta(5e4, 2, 30)
  h <- hdi_draws(x, 0.95)
  m <- mean(x >= h[1] & x <= h[2])
  expect_gte(m, 0.95)
  expect_lt(m, 0.9505)
})
