
## ## tnames <- c(a = "warmup-a-beta", b = "warmup-b-simulation", c = "warmup-c-intervals",
## ##             d = "warmup-d-loss-shortest", e = "warmup-e-densities", f = "warmup-f-ggplot",
## ##             g = "warmup-g-tests-prs")
## ## 
## ## #' Run a warmup tutorial locally
## ## #'
## ## #' @param which A single letter `"a"` to `"g"` selecting the warmup (see `screenbayes:::tnames`).
## ## #' @return Called for its side effect of starting the tutorial.
## ## #' @examples
## ## #' screenbayes:::tnames
## ## #' @export
## ## run_tut <- function(which = "a") {
## ##   stopifnot(length(which) == 1, which %in% names(tnames))
## ##   for (pkg in c("shiny", "learnr"))
## ##     if (!requireNamespace(pkg, quietly = TRUE))
## ##       stop("please install the ", pkg, " package: install.packages(\"", pkg, "\")", call. = FALSE)
## ##   learnr::run_tutorial(tnames[[which]], package = "screenbayes")
## ## }
