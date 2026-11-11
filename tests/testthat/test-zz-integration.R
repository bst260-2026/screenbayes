# Integration tests: these pass only when ALL teams are done.

test_that("the full pipeline works: draws -> summaries -> plot", {
  se_ab <- update_beta(1, 1, 18, 41); sp_ab <- update_beta(1, 1, 118, 12)
  set.seed(1)
  d <- post_draws(5000, se_ab, sp_ab, prev = 0.08)
  expect_named(d, c("se", "sp", "ppv", "npv"))
  s <- summarise_posterior(d$ppv, 0.95)
  expect_named(s, c("point", "eti", "hdi", "hpd", "hpd_mass"))
  expect_true(s$hpd_mass >= 0.94)
  expect_s3_class(posterior_plot(d$ppv, s, "PPV", 0.25), "ggplot")
})

test_that("target populations reproduce the known prevalences", {
  p <- target_populations()
  expect_named(p, population_labels)
  expect_equal(p[["All births (sample)"]], 59 / 189)
  expect_equal(p[["Smokers"]], 30 / 74)
})

test_that("uncertain prevalence flows through post_draws", {
  set.seed(1)
  pv <- prev_draws(5000, prior = stratum_beta(bw_data(), ht == 1))
  d <- post_draws(5000, c(a = 90, b = 10), c(a = 95, b = 5), pv)
  expect_length(d$ppv, 5000)
  expect_gt(sd(d$ppv), 0)
})

test_that("the app's server logic runs end to end", {
  skip_if_not_installed("shiny")
  app_dir <- system.file("app", package = "screenbayes")
  skip_if(!nzchar(app_dir))
  shiny::testServer(app_dir, {
    session$setInputs(param = "mn", se_m = 0.9, se_n = 20, sp_m = 0.95, sp_n = 20,
                      use_data = TRUE, test_var = "ptl_pos",
                      tp = 18, fn = 41, tn = 118, fp = 12,
                      pop = "Smokers", prev = 0.08, prev_mode = "known",
                      prev_a = 1, prev_b = 1,
                      qty = "ppv", mass = 0.95, threshold = 0.5, adjust = 1,
                      ndraws = 5000, seed = 260)
    expect_equal(unname(post_se()), c(36, 43))
    expect_equal(prev(), 30 / 74)
    expect_true(is.list(summ()))
    expect_s3_class(sweep(), "data.frame")
    session$setInputs(prev_mode = "beta")
    expect_equal(length(prev_vec()), 5000)
  })
})
