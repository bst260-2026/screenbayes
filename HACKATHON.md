# Hackathon guide

**Goal.** By the end of the session the package passes all its tests and
`screenbayes::run_app()` shows live posterior distributions of PPV for a screening
test whose sensitivity and specificity are uncertain.

You are one of six teams. Every team owns **one file** and writes the functions in it.
The files are independent by design, so you can all work at once.

## The teams

| Team | Your file | You implement | Difficulty |
|------|-----------|---------------|:----------:|
| 1 | `R/team1_beta.R` | `beta_from_mean_n`, `beta_mean`, `beta_median`, `beta_mode`, `update_beta` | ★ |
| 2 | `R/team2_predictive.R` | `ppv_fn`, `npv_fn`, `ppv_predictive` | ★ |
| 3 | `R/team3_intervals.R` | `eti_beta`, `hdi_beta`, `eti_draws`, `hdi_draws` | ★★ |
| 4 | `R/team4_map_hpd.R` | `map_kde`, `hpd_region`, `prob_exceeds` | ★★★ |
| 5 | `R/team5_populations.R` | `stratum_prevalence`, `stratum_beta`, `prev_draws` | ★★ |
| 6 | `R/team6_plot.R` | `posterior_plot` (four ggplot2 layers) | ★★★ |

Each function's specification is its **roxygen comment** (`#'` lines) above it and
its **tests** in `tests/testthat/test-teamN-*.R`. Read the tests first: they are the
contract.

## Ground rules

1. **Only edit your own file.** Do not edit tests, `NAMESPACE`, `man/`, `DESCRIPTION`,
   the app, or other teams' files. (If you think a test is wrong, tell the instructor.)
2. **Keep every function's name, arguments and defaults.** Other teams, and the app, call them.
3. **Do not call another team's functions inside yours.** The contract between teams
   is the documented inputs and outputs (for example, a Beta is a named vector
   `c(a = ..., b = ...)`). Compute what you need yourself. That's what lets you work
   in parallel.
4. **No running `devtools::document()`** and no committing `NAMESPACE` or `man/` changes.
   They are already generated.
5. Use the base R / `dplyr` / `ggplot2` already in `DESCRIPTION`. No new dependencies.

## Setup (10 minutes)

```sh
git clone https://github.com/<ORG>/screenbayes.git
cd screenbayes
git checkout -b team-N          # N = your team number
```

```r
install.packages(c("dplyr", "ggplot2", "MASS", "shiny", "tibble",
                   "testthat", "pkgload", "roxygen2"))
pkgload::load_all()             # reload after every edit
testthat::test_local(filter = "teamN")     # your team's tests only
```

All tests start **red**: every function begins with `stop("TODO ...")`.
`Rscript scripts/scoreboard.R` prints pass/fail for all teams.

## Workflow

1. Work on branch `team-N`; commit early and often.
2. When your team's tests pass locally, push and open a **pull request into `main`**
   (the PR template has a checklist).
3. **Peer review in a ring:** team 1 reviews team 2, team 2 reviews 3, …, team 6 reviews team 1.
   A reviewer reads the code against the roxygen spec, runs the tests, and tries two or
   three inputs of their own (an edge case: `NA`? length-1 input? `mass = 0.5`?).
4. When CI is green for your team and the reviewing team approves, merge.
5. After merging, everyone runs `git checkout main && git pull` to get the other teams' work.

Merge conflicts should not happen: you only edit your own file. If you get one, you edited
something you shouldn't have.

## Schedule (for a 100-minute session)

| Time | What |
|-----:|------|
| 0–10 | Setup; read your file's specification and tests |
| 10–55 | Implement until your team's tests pass (hints below) |
| 55–70 | Pull request and peer review |
| 70–85 | **Integration.** Everyone pulls `main`; run the scoreboard; fix what the integration tests find |
| 85–100 | **Demo:** launch the app, use the script below, discuss |

### Integration demo script

1. `screenbayes::run_app()`
2. Se prior: mean 0.90, prior sample size 20. Sp prior: mean 0.95, n = 20.
3. Tick "Update priors with test data", load "Previous premature labour".
4. Target population: "Smokers". On the *Posterior* tab note the mean, median, MAP and the
   three interval types. Then switch to "Assumed specialised (0.015)" and watch the skew change direction.
5. Switch the prevalence to "uncertain: Beta(a, b)" (Team 5's work) and compare.
6. Set the Se prior to a = b = 0.5, quantity "Se", no data, mass 0.5: where do the three
   interval types sit? (Team 3 and Team 4's work.)

## Hints

- **All teams:** `?function_name` is not available for stubs until you reload, but the
  roxygen comment above each function says what it must return. Name the returned
  vector elements exactly as the spec says; tests check names.
- **Team 1:** `update_beta()` must drop names inherited from its arguments: `unname()`.
  `beta_mode()` has four cases.
- **Team 2:** Vectorise by writing the formula directly, with no `if` statements.
  For `ppv_predictive()` compute the two Beta means yourself.
- **Team 3:** For `hdi_beta()` think of intervals `[qbeta(p), qbeta(p + mass)]` and
  minimise the width over `p` with `optimize()`. For `hdi_draws()`, sort, then slide a window of
  `ceiling(mass * n)` draws.
- **Team 4:** Do `map_kde()` first (three lines); `hpd_region()` reuses the same density.
  The key idea is to order grid points by *density*, not by `x`. `rle()` turns a logical vector
  into runs.
- **Team 5:** `dplyr::filter(data, ...)` accepts the dots directly. `prev_draws()` has two cases.
- **Team 6:** Your tests use a hand-made summary list (see `tests/testthat/helper-fixtures.R`),
  so you do not need other teams' code. Look at `ggplot2::ggplot_build(p)` to debug.

## Finished early?

- Write extra edge-case tests in your own test file for a *different* team's function and
  send them a pull request, or
- start on the individual Part 6 questions in `problem-set/` using the app.
