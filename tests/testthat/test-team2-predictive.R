test_that("ppv_fn matches Bayes' theorem", {
  expect_equal(ppv_fn(0.99, 0.99, 0.001),
               0.99 * 0.001 / (0.99 * 0.001 + 0.01 * 0.999))
  expect_equal(ppv_fn(0.9, 0.95, 0.1), 0.09 / (0.09 + 0.05 * 0.9))
})

test_that("npv_fn matches Bayes' theorem", {
  expect_equal(npv_fn(0.9, 0.95, 0.1),
               0.95 * 0.9 / (0.95 * 0.9 + 0.1 * 0.1))
})

test_that("ppv_fn and npv_fn are vectorised over se, sp and prev", {
  expect_length(ppv_fn(c(0.8, 0.9), c(0.9, 0.95), 0.1), 2)
  expect_length(npv_fn(c(0.8, 0.9), c(0.9, 0.95), 0.1), 2)
  expect_equal(ppv_fn(0.9, 0.95, c(0.01, 0.1)),
               c(ppv_fn(0.9, 0.95, 0.01), ppv_fn(0.9, 0.95, 0.1)))
})

test_that("limiting prevalences give the obvious answers", {
  expect_equal(ppv_fn(0.9, 0.95, 0), 0)
  expect_equal(ppv_fn(0.9, 0.95, 1), 1)
  expect_equal(npv_fn(0.9, 0.95, 0), 1)
})

test_that("ppv_predictive is the PPV at the posterior means", {
  expect_equal(ppv_predictive(c(a = 9, b = 1), c(a = 19, b = 1), 0.08),
               ppv_fn(0.9, 0.95, 0.08))
})

test_that("ppv_predictive differs from the mean of the PPV (Jensen)", {
  set.seed(1)
  se <- rbeta(2e5, 2, 2); sp <- rbeta(2e5, 8, 2)
  mean_ppv <- mean(ppv_fn(se, sp, 0.1))
  pred <- ppv_predictive(c(a = 2, b = 2), c(a = 8, b = 2), 0.1)
  expect_gt(abs(mean_ppv - pred), 0.005)
})
