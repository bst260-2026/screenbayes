
# Shiny app shipped with the screenbayes package (inst/app/app.R).
# Launch with screenbayes::run_app().  It calls the functions the teams write;
# until a function is implemented, the matching panel shows "Not yet working".

library(shiny)
if (!("package:screenbayes" %in% search())) library(screenbayes)
bw <- bw_data()


# Turn an error from an unfinished helper into a readable message in the UI
safe <- function(expr) {
  tryCatch(expr, error = function(e)
    shiny::validate(shiny::need(FALSE, paste("Not yet working:", conditionMessage(e)))))
}

prior_inputs <- function(prefix, label, m, n, a, b) {
  tagList(
    h4(paste("Prior (credal state) for", label)),
    conditionalPanel("input.param == 'mn'",
      sliderInput(paste0(prefix, "_m"), paste(label, "prior mean"),
                  min = 0.01, max = 0.99, value = m, step = 0.01),
      sliderInput(paste0(prefix, "_n"), paste(label, "prior sample size (a + b)"),
                  min = 0.5, max = 200, value = n, step = 0.5)),
    conditionalPanel("input.param == 'ab'",
      fluidRow(
        column(6, numericInput(paste0(prefix, "_a"), "a", a, min = 0.05, step = 0.5)),
        column(6, numericInput(paste0(prefix, "_b"), "b", b, min = 0.05, step = 0.5))))
  )
}

ui <- fluidPage(
  titlePanel("Screening test with uncertain sensitivity and specificity"),
  sidebarLayout(
    sidebarPanel(
      width = 4,
      radioButtons("param", "Parameterise the Beta priors by",
                   c("mean & prior sample size" = "mn", "a & b" = "ab"), inline = TRUE),
      prior_inputs("se", "Se", 0.90, 20, 9, 1),
      prior_inputs("sp", "Sp", 0.95, 20, 19, 1),
      hr(),
      checkboxInput("use_data", "Update priors with test data", FALSE),
      conditionalPanel("input.use_data",
        selectInput("test_var", "Load 2x2 counts from a birthwt test",
                    c("(enter manually)" = "", test_choices)),
        fluidRow(column(6, numericInput("tp", "TP (test+, LBW)", 0, min = 0)),
                 column(6, numericInput("fn", "FN (test-, LBW)", 0, min = 0))),
        fluidRow(column(6, numericInput("tn", "TN (test-, not LBW)", 0, min = 0)),
                 column(6, numericInput("fp", "FP (test+, not LBW)", 0, min = 0)))),
      hr(),
      selectInput("pop", "Target population (fixes the prevalence)",
                  c("Custom" = "custom", names(assumed_populations), population_labels)),
      conditionalPanel("input.pop == 'custom'",
        numericInput("prev", "Prevalence", 0.08, min = 1e-4, max = 0.99, step = 0.005)),
      radioButtons("prev_mode", "Prevalence of the target population is",
                   c("known" = "known", "uncertain: Beta(a, b)" = "beta"), inline = TRUE),
      conditionalPanel("input.prev_mode == 'beta'",
        helpText("For a birthwt sub-population the Beta is filled in from its counts",
                 "(flat prior + k LBW among n births); edit freely."),
        fluidRow(column(6, numericInput("prev_a", "a", 1, min = 0.05, step = 0.5)),
                 column(6, numericInput("prev_b", "b", 1, min = 0.05, step = 0.5)))),
      textOutput("prev_txt"),
      hr(),
      radioButtons("qty", "Quantity to summarise",
                   c("PPV" = "ppv", "NPV" = "npv", "Se" = "se", "Sp" = "sp"), inline = TRUE),
      sliderInput("mass", "Posterior mass for intervals", 0.5, 0.99, 0.95, step = 0.01),
      numericInput("threshold", "Clinical threshold for P(value >= t)", 0.5,
                   min = 0, max = 1, step = 0.05),
      sliderInput("adjust", "Kernel bandwidth multiplier (MAP / HPD region)",
                  0.3, 3, 1, step = 0.1),
      fluidRow(column(6, numericInput("ndraws", "Draws", 20000, min = 1000, step = 1000)),
               column(6, numericInput("seed", "Seed", 260)))
    ),
    mainPanel(
      width = 8,
      tabsetPanel(
        tabPanel("Se and Sp",
                 plotOutput("beta_plot", height = 330),
                 fluidRow(column(6, h5("Sensitivity (posterior)"), tableOutput("se_tab")),
                          column(6, h5("Specificity (posterior)"), tableOutput("sp_tab")))),
        tabPanel("Posterior of the chosen quantity",
                 plotOutput("post_plot", height = 380),
                 tableOutput("post_tab"),
                 verbatimTextOutput("reparam")),
        tabPanel("Sweep over prevalence",
                 plotOutput("sweep_band", height = 300),
                 plotOutput("sweep_prob", height = 260))
      )
    )
  )
)

server <- function(input, output, session) {

  # ---- priors and posteriors for Se and Sp -------------------------------
  prior_se <- reactive(safe(
    if (input$param == "mn") beta_from_mean_n(input$se_m, input$se_n)
    else c(a = input$se_a, b = input$se_b)))
  prior_sp <- reactive(safe(
    if (input$param == "mn") beta_from_mean_n(input$sp_m, input$sp_n)
    else c(a = input$sp_a, b = input$sp_b)))

  observeEvent(input$test_var, {
    if (nzchar(input$test_var)) {
      k <- test_counts(input$test_var)
      updateNumericInput(session, "tp", value = k[["tp"]])
      updateNumericInput(session, "fn", value = k[["fn"]])
      updateNumericInput(session, "tn", value = k[["tn"]])
      updateNumericInput(session, "fp", value = k[["fp"]])
    }
  })

  post_se <- reactive({
    p <- prior_se()
    if (isTRUE(input$use_data)) safe(update_beta(p[["a"]], p[["b"]], input$tp, input$fn)) else p
  })
  post_sp <- reactive({
    p <- prior_sp()
    if (isTRUE(input$use_data)) safe(update_beta(p[["a"]], p[["b"]], input$tn, input$fp)) else p
  })

  # ---- target population -> prevalence ------------------------------------
  prev <- reactive({
    if (input$pop == "custom") return(input$prev)
    if (input$pop %in% names(assumed_populations)) return(assumed_populations[[input$pop]])
    safe(target_populations(bw))[[input$pop]]
  })
  # uncertain prevalence: pre-fill a, b from the stratum counts (provided helper)
  observeEvent(list(input$pop, input$prev_mode), {
    if (input$prev_mode == "beta" && input$pop %in% population_labels) {
      cts <- population_counts(bw)
      row <- cts[cts$population == input$pop, ]
      updateNumericInput(session, "prev_a", value = 1 + row$k)
      updateNumericInput(session, "prev_b", value = 1 + row$n - row$k)
    }
  })
  prev_vec <- reactive({
    if (input$prev_mode == "beta")
      safe(prev_draws(input$ndraws, prior = c(a = input$prev_a, b = input$prev_b)))
    else prev()
  })
  prev_mean <- reactive(if (input$prev_mode == "beta")
    input$prev_a / (input$prev_a + input$prev_b) else prev())
  output$prev_txt <- renderText(
    if (input$prev_mode == "beta")
      paste0("Prevalence ~ Beta(", fmt(input$prev_a, 1), ", ", fmt(input$prev_b, 1),
             "), mean ", fmt(prev_mean(), 4))
    else paste("Prevalence used:", fmt(prev(), 4)))

  # ---- draws and summaries --------------------------------------------------
  draws <- reactive({
    set.seed(input$seed)
    post_draws(input$ndraws, post_se(), post_sp(), prev_vec())
  })
  x <- reactive(draws()[[input$qty]])
  qty_label <- reactive(c(ppv = "PPV", npv = "NPV", se = "Sensitivity", sp = "Specificity")[[input$qty]])
  summ <- reactive(safe(summarise_posterior(x(), input$mass, input$adjust)))

  # ---- tab 1: Beta densities ----------------------------------------------
  output$beta_plot <- renderPlot({
    g <- seq(0.001, 0.999, length.out = 600)
    pr <- list(Se = prior_se(), Sp = prior_sp())
    po <- list(Se = post_se(),  Sp = post_sp())
    df <- dplyr::bind_rows(lapply(c("Se", "Sp"), function(w) {
      dplyr::bind_rows(
        tibble::tibble(which = w, kind = "prior",     x = g, d = dbeta(g, pr[[w]][["a"]], pr[[w]][["b"]])),
        tibble::tibble(which = w, kind = "posterior", x = g, d = dbeta(g, po[[w]][["a"]], po[[w]][["b"]])))
    }))
    ggplot(df, aes(x, d, linetype = kind)) +
      geom_line(linewidth = 0.9) +
      facet_wrap(~which) +
      coord_cartesian(ylim = c(0, quantile(df$d, 0.995))) +
      labs(x = NULL, y = "density", linetype = NULL) +
      theme_minimal(base_size = 13)
  })
  output$se_tab <- renderTable(safe(beta_table(post_se(), input$mass)), colnames = FALSE)
  output$sp_tab <- renderTable(safe(beta_table(post_sp(), input$mass)), colnames = FALSE)

  # ---- tab 2: posterior of the chosen quantity -------------------------------
  output$post_plot <- renderPlot({
    s <- summ()
    safe(posterior_plot(x(), s, qty_label(), input$threshold))
  })
  output$post_tab <- renderTable(
    summary_table(summ(), input$mass, x(), input$threshold))

  output$reparam <- renderText({
    req(input$qty == "ppv")
    s <- summ()
    se <- post_se(); sp <- post_sp()
    paste0(
      "Five different 'point estimates' of the PPV at prevalence ", fmt(prev_mean(), 4), ":\n",
      "  PPV evaluated at MAP(Se), MAP(Sp)      : ",
      fmt(safe(ppv_fn(beta_mode(se[["a"]], se[["b"]]), beta_mode(sp[["a"]], sp[["b"]]), prev_mean()))), "\n",
      "  MAP of the posterior of the PPV        : ", fmt(s$point[["MAP"]]), "\n",
      "  Posterior median of the PPV            : ", fmt(s$point[["median"]]), "\n",
      "  Posterior mean of the PPV              : ", fmt(s$point[["mean"]]), "\n",
      "  Predictive PPV (ratio of posterior means): ",
      fmt(safe(ppv_predictive(se, sp, prev_mean()))))
  })

  # ---- tab 3: sweep over prevalence -------------------------------------------
  sweep <- reactive({
    grid <- 10^seq(-3.5, log10(0.6), length.out = 80)
    safe(sweep_ppv(post_se(), post_sp(), grid, input$mass, input$ndraws,
                   input$threshold, input$seed))
  })
  output$sweep_band <- renderPlot({
    ggplot(sweep(), aes(prev)) +
      geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.3) +
      geom_line(aes(y = median), linewidth = 0.9) +
      geom_vline(xintercept = prev_mean(), linetype = "dashed") +
      scale_x_log10() +
      labs(x = "Prevalence (log scale)",
           y = paste0("PPV: median and ", round(100 * input$mass), "% equal-tailed band")) +
      theme_minimal(base_size = 13)
  })
  output$sweep_prob <- renderPlot({
    ggplot(sweep(), aes(prev, p_exceed)) +
      geom_line(linewidth = 0.9) +
      geom_vline(xintercept = prev_mean(), linetype = "dashed") +
      scale_x_log10() + ylim(0, 1) +
      labs(x = "Prevalence (log scale)",
           y = paste0("P(PPV >= ", input$threshold, ")")) +
      theme_minimal(base_size = 13)
  })
}

shinyApp(ui, server)
