# screenbayes

Bayesian uncertainty about the **sensitivity** and **specificity** of a screening
test, and what it does to the **predictive values** in a target population.

- Beta priors express our credal state about Se and Sp (conjugate updating with
  2×2 data).
- Prevalence is fixed by *choosing the target population* (or treated as
  uncertain with its own Beta).
- The posterior of PPV/NPV is summarised by point estimates (mean, median, MAP)
  and by interval estimates based on posterior mass (equal-tailed interval,
  highest-density interval, HPD region).
- A Shiny app (`run_app()`) lets you vary the Beta parameters and see all of
  this.

This repository is a **class hackathon**: the package skeleton is complete, but
the functions that do the real work are stubs. Six teams implement them, merge
them through pull requests, and watch the app come to life.

## Quick start

```r
install.packages(c("dplyr", "ggplot2", "MASS", "shiny", "tibble",
                   "testthat", "pkgload", "roxygen2"))
pkgload::load_all()          # load the package from this folder
screenbayes::run_app()       # the app (panels say "Not yet working" until teams merge)
```

```sh
Rscript scripts/scoreboard.R   # pass/fail per team
```

**Warmups first.** Short self-paced [learnr](https://pkgs.rstudio.com/learnr/) tutorials prepare each
part of the hackathon (install once: `install.packages("learnr")`):

```r
learnr::run_tutorial("warmup-a-beta", package = "screenbayes")   # Beta distributions (Team 1)
```

Read **[HACKATHON.md](HACKATHON.md)** for the team assignments, the workflow and
the schedule. The accompanying problem set is in `problem-set/`.

## Layout

| Path | What |
|------|------|
| `R/team1_beta.R` … `R/team6_plot.R` | the six team files (stubs until implemented) |
| `R/data.R`, `R/summaries.R` | provided glue: data, `post_draws()`, `summarise_posterior()`, tables, `run_app()` |
| `inst/app/app.R` | the Shiny app |
| `tests/testthat/` | one test file per team + an integration test |
| `scripts/scoreboard.R` | pass/fail summary per team |
| `scripts/check_tutorial.R` | runs a tutorial's solutions and validates its quizzes without Shiny |
| `inst/tutorials/` | self-paced warmup tutorials (learnr), one per hackathon topic |
| `problem-set/` | the Quarto problem set (Parts 5–6) |
| `.github/` | CODEOWNERS, PR template, per-team CI |
