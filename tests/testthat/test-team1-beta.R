test_that("beta_from_mean_n returns named a and b with the right mean and size", {
  ab <- beta_from_mean_n(0.9, 20)
  expect_named(ab, c("a", "b"))
  expect_equal(unname(ab), c(18, 2))
  ab2 <- beta_from_mean_n(0.25, 8)
  expect_equal(unname(ab2[["a"]] / sum(ab2)), 0.25)
  expect_equal(sum(ab2), 8)
})

test_that("update_beta adds successes to a and failures to b", {
  expect_equal(update_beta(2, 3, 5, 7), c(a = 7, b = 10))
})

test_that("update_beta ignores the names of its count arguments", {
  k <- c(tp = 18, fn = 41)
  expect_named(update_beta(1, 1, k["tp"], k["fn"]), c("a", "b"))
  expect_equal(update_beta(1, 1, k["tp"], k["fn"]), c(a = 19, b = 42))
})

test_that("beta_mean and beta_median", {
  expect_equal(beta_mean(2, 6), 0.25)
  expect_equal(pbeta(beta_median(3, 9), 3, 9), 0.5)
  expect_equal(beta_median(4, 4), 0.5)
})

test_that("beta_mode: interior mode", {
  expect_equal(beta_mode(3, 7), 0.25)
  expect_equal(beta_mode(2, 2), 0.5)
})

test_that("beta_mode: J-shaped densities have their mode at the boundary", {
  expect_equal(beta_mode(1, 5), 0)
  expect_equal(beta_mode(0.5, 3), 0)
  expect_equal(beta_mode(5, 1), 1)
  expect_equal(beta_mode(4, 0.5), 1)
})

test_that("beta_mode: uniform and U-shaped densities have no mode", {
  expect_true(is.na(beta_mode(1, 1)))
  expect_true(is.na(beta_mode(0.5, 0.5)))
})
