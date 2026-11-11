# Run with:  Rscript practice/check.R   (from the repository root)
suppressPackageStartupMessages(library(testthat))
source("practice/template.R")

test_that("beta_cv matches the definition", {
  a <- 3; b <- 7
  sd <- sqrt(a * b / ((a + b)^2 * (a + b + 1)))
  expect_equal(beta_cv(a, b), sd / (a / (a + b)))
})

test_that("beta_cv is vectorised", {
  expect_length(beta_cv(c(1, 2, 3), 5), 3)
})

test_that("beta_cv shrinks as the prior sample size grows", {
  expect_lt(beta_cv(30, 70), beta_cv(3, 7))
})

# 4. ADD YOUR OWN TEST HERE
