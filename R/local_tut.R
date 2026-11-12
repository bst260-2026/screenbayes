tnames = c(a="warmup-a-beta", b="warmup-b-simulation", c="warmup-c-intervals",
  d="warmup-d-loss-shortest", e="warmup-e-densities", f="warmup-f-ggplot",
  g="warmup-g-tests-prs")

#' start a learnr process locall
#' @param which character(1) in letters\[1:7\] to pick tutorial to run
#' @examples
#' # options, use the letter, not the warmup string
#' screenbayes:::tnames
#' @export
run_tut = function(which = "a") {
 stopifnot(which %in% letters[1:7])
 if (!requireNamespace("shiny")) stop("please install the shiny package to use this function.")
 if (!requireNamespace("learnr")) stop("please install the learnr package to use this function.")
 learnr::run_tutorial(tnames[which], package="screenbayes")
}

