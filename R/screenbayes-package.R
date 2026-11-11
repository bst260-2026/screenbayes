#' screenbayes: uncertainty about sensitivity and specificity
#'
#' See `README.md` and `HACKATHON.md` in the repository.
#'
#' @keywords internal
#' @import ggplot2
#' @importFrom stats density median optimize qbeta rbeta quantile dbeta setNames
"_PACKAGE"

# variables used through non-standard evaluation (ggplot2 aes(), dplyr::filter())
utils::globalVariables(c(
  "x", "y", "piece", "estimate", "value", "method", "lo", "hi",
  "smoke", "ht", "ptl_pos", "race", "low", "ptl", "lwt", "lbw", "bw"
))
