test_that("posterior_plot returns a ggplot that can be built", {
  p <- posterior_plot(fx_draws, fx_summary, "PPV")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("the plot has HPD shading, point-estimate lines and interval bars", {
  g <- layer_geoms(posterior_plot(fx_draws, fx_summary, "PPV"))
  expect_true("GeomArea" %in% g)
  expect_true("GeomVline" %in% g)
  expect_true("GeomSegment" %in% g)
})

test_that("there is one vertical line per point estimate", {
  p <- posterior_plot(fx_draws, fx_summary, "PPV")
  b <- ggplot2::ggplot_build(p)
  vl <- which(layer_geoms(p) == "GeomVline")[1]
  expect_equal(nrow(b$data[[vl]]), 3)
})

test_that("interval bars: ETI + HDI + one per HPD piece", {
  seg_rows <- function(s) {
    p <- posterior_plot(fx_draws, s, "PPV")
    b <- ggplot2::ggplot_build(p)
    sum(vapply(which(layer_geoms(p) == "GeomSegment"), function(i) nrow(b$data[[i]]), 1))
  }
  expect_equal(seg_rows(fx_summary), 3)
  expect_equal(seg_rows(fx_summary_2pieces), 4)
})

test_that("a multi-piece HPD region builds without error", {
  p <- posterior_plot(fx_draws, fx_summary_2pieces, "x")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("a threshold adds a dashed line and a text annotation", {
  g0 <- layer_geoms(posterior_plot(fx_draws, fx_summary, "PPV"))
  g1 <- layer_geoms(posterior_plot(fx_draws, fx_summary, "PPV", threshold = 0.3))
  expect_equal(sum(g1 == "GeomVline"), sum(g0 == "GeomVline") + 1)
  expect_true("GeomText" %in% g1)
  expect_false("GeomText" %in% g0)
})
