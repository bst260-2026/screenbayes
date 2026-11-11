test_that("map_kde finds the mode of a unimodal sample", {
  set.seed(1)
  expect_lt(abs(map_kde(rbeta(5e4, 5, 3)) - 4 / 6), 0.03)
})

test_that("map_kde respects the bandwidth multiplier argument", {
  set.seed(1); x <- rbeta(2e3, 5, 3)
  expect_length(map_kde(x, adjust = 2), 1)
})

test_that("hpd_region returns a data frame with lower and upper", {
  set.seed(1); r <- hpd_region(rbeta(5e4, 3, 9), 0.9)
  expect_s3_class(r, "data.frame")
  expect_named(r, c("lower", "upper"))
})

test_that("hpd_region of a unimodal density is one interval close to the HDI", {
  set.seed(1); x <- rbeta(5e4, 3, 9)
  r <- hpd_region(x, 0.9)
  expect_equal(nrow(r), 1)
  # the HPD region of a unimodal density is its highest-density interval
  # (the closed form is hdi_beta(3, 9, 0.9), team 3's job; we use the
  # equal-density property instead so that teams stay independent)
  expect_lt(abs(dbeta(r$lower[1], 3, 9) - dbeta(r$upper[1], 3, 9)), 0.15)
  expect_lt(diff(pbeta(c(r$lower[1], r$upper[1]), 3, 9)) - 0.9, 0.02)
  expect_gt(r$lower[1], 0.03); expect_lt(r$upper[1], 0.5)
})

test_that("hpd_region of a U-shaped density has two pieces", {
  set.seed(1); x <- rbeta(5e4, 0.5, 0.5)
  r <- hpd_region(x, 0.5)
  expect_equal(nrow(r), 2)
  expect_lt(r$lower[1], 0.05)
  expect_gt(r$upper[2], 0.95)
})

test_that("the draws in the region hold about the requested mass", {
  set.seed(1); x <- rbeta(5e4, 3, 9)
  r <- hpd_region(x, 0.9)
  expect_equal(mean(x >= r$lower[1] & x <= r$upper[1]), 0.9, tolerance = 0.02)
})

test_that("prob_exceeds counts draws at or above the threshold", {
  expect_equal(prob_exceeds(c(0.1, 0.4, 0.5, 0.9), 0.5), 0.5)
  expect_equal(prob_exceeds(c(0.1, 0.2), 0.5), 0)
})
