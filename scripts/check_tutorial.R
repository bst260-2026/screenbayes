# Check a learnr tutorial WITHOUT running Shiny/learnr:
#   Rscript scripts/check_tutorial.R inst/tutorials/warmup-a-beta/warmup-a-beta.Rmd
#   (or all tutorials:  for f in inst/tutorials/*/*.Rmd; do Rscript scripts/check_tutorial.R $f; done)
# - runs every non-exercise chunk, the solution of every exercise (or the
#   exercise itself when it has no solution because it is complete), in order;
# - checks every quiz: each question has exactly one correct answer.
# Exit status 0 if everything ran.
pdf(NULL)  # no Rplots.pdf
suppressPackageStartupMessages(library(ggplot2))
f <- commandArgs(TRUE)[1]
x <- readLines(f)
starts <- grep("^```\\{r", x)
chunks <- lapply(starts, function(s) {
  e <- s + which(x[(s + 1):length(x)] == "```")[1]
  hdr <- sub("^```\\{r,? ?", "", sub("\\}\\s*$", "", x[s]))
  label <- trimws(strsplit(hdr, ",")[[1]][1])
  list(label = label, hdr = hdr, code = x[(s + 1):(e - 1)])
})
labels <- vapply(chunks, `[[`, "", "label")
is_ex  <- vapply(chunks, function(ch) grepl("exercise\\s*=\\s*TRUE", ch$hdr), NA)

# stubs for learnr's quiz functions that also validate structure
answer <- function(text, correct = FALSE, message = NULL) list(text = text, correct = correct)
question <- function(text, ..., type = NULL, allow_retry = FALSE, random_answer_order = FALSE) {
  a <- list(...)
  nc <- sum(vapply(a, function(z) isTRUE(z$correct), NA))
  if (nc < 1 || (nc > 1 && !identical(type, "learnr_checkbox"))) stop("question has ", nc, " correct answers: ", substr(text, 1, 60))
  list(text = text, n = length(a))
}
quiz <- function(...) { cat("  quiz with", length(list(...)), "question(s) OK\n"); invisible(NULL) }
library_orig <- library
library <- function(pkg, ...) { if (!identical(as.character(substitute(pkg)), "learnr")) library_orig(as.character(substitute(pkg)), character.only = TRUE) }
tutorial_options <- function(...) NULL

env <- globalenv(); ran <- 0
for (i in seq_along(chunks)) {
  ch <- chunks[[i]]; lab <- ch$label
  if (grepl("-hint(-[0-9]+)?$", lab)) next
  run <- FALSE
  if (grepl("-solution$", lab)) run <- TRUE
  else if (is_ex[i]) run <- !(paste0(lab, "-solution") %in% labels)  # complete exercise
  else run <- (!grepl("include=FALSE", ch$hdr) || lab == "setup") && !grepl("eval\\s*=\\s*FALSE", ch$hdr)
  if (!run) next
  cat("chunk:", lab, "\n")
  code <- ch$code
  if (lab == "setup") code <- code[!grepl("knitr::opts_chunk", code)]
  res <- withVisible(eval(parse(text = code), env))
  if (inherits(res$value, "ggplot")) ggplot2::ggplot_build(res$value)
  if (res$visible && !inherits(res$value, "ggplot") && !is.null(res$value)) print(res$value)
  ran <- ran + 1
}
cat("\nAll", ran, "chunks ran without error.\n")
