# Hackathon scoreboard.  From the repository root:
#   Rscript scripts/scoreboard.R
# Runs every test file and prints, per team, how many tests pass.
# Exit status is 0 only if every test passes.

if (!requireNamespace("testthat", quietly = TRUE) ||
    !requireNamespace("pkgload", quietly = TRUE))
  stop("Please install.packages(c('testthat', 'pkgload'))")

res <- suppressWarnings(testthat::test_local(".", reporter = "silent",
                                             stop_on_failure = FALSE))
df <- as.data.frame(res)
df$file <- sub("\\.[Rr]$", "", sub("^test-", "", df$file))
df$ok <- df$failed == 0 & !df$error & !df$skipped

teams <- c("team1-beta" = "Team 1  Beta utilities",
           "team2-predictive" = "Team 2  Predictive values",
           "team3-intervals" = "Team 3  Intervals",
           "team4-map_hpd" = "Team 4  MAP and HPD region",
           "team5-populations" = "Team 5  Target populations",
           "team6-plot" = "Team 6  Plot",
           "zz-integration" = "All     Integration")

out <- do.call(rbind, lapply(names(teams), function(k) {
  d <- df[df$file == k, ]
  data.frame(team = teams[[k]], passed = sum(d$ok), total = nrow(d),
             status = if (nrow(d) > 0 && all(d$ok)) "DONE" else "...",
             stringsAsFactors = FALSE)
}))
print(out, row.names = FALSE)
cat(sprintf("\nTotal: %d / %d tests passing\n", sum(out$passed), sum(out$total)))

summary_file <- Sys.getenv("GITHUB_STEP_SUMMARY")
if (nzchar(summary_file)) {
  lines <- c("| Team | Passed | Total | Status |", "|---|---|---|---|",
             sprintf("| %s | %d | %d | %s |", out$team, out$passed, out$total, out$status))
  cat(lines, file = summary_file, sep = "\n", append = TRUE)
}
quit(status = if (all(out$status == "DONE")) 0 else 1)
