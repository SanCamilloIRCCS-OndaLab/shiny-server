library(shiny)
library(pROC)

author_date_text = "<i>Author: Giorgio Arcara; Version: 11/2025 </i>"
warning_text = "<i> NOTE: this is an educational resource, not meant to be used for clinical practice.</i>"
warning_text2= "<i> NOTE: This application is currently under debugging, use with Caution <i>"

ui <- fluidPage(
  titlePanel("Sensitivity, Specificity, and ROC Explorer for Neuropsychological Tests"),
  sidebarLayout(
    sidebarPanel(
      numericInput("pat_n", "Number of Pathological individuals", value = 50, min = 1),
      numericInput("healthy_n", "Number of Healthy individuals", value = 50, min = 1),
      numericInput("pat_mean", "Pathological Mean", value = 20),
      numericInput("pat_sd", "Pathological SD", value = 2),
      numericInput("healthy_mean", "Healthy Mean", value = 24),
      numericInput("healthy_sd", "Healthy SD", value = 2),
      sliderInput("cutoff", "Cutoff Threshold", min = 0, max = 40, value = 20, step = 0.1),
      radioButtons("show_pathological", "Show Pathological Distribution",
                   choices = c("Yes" = TRUE, "No" = FALSE),
                   selected = TRUE, inline = TRUE),
      radioButtons("show_healthy", "Show Healthy Distribution",
                   choices = c("Yes" = TRUE, "No" = FALSE),
                   selected = TRUE, inline = TRUE),
      actionButton("regenerate", "Regenerate Data"),
      actionButton("setOptimal", "Set Optimal Threshold (Youden Index)"),
      br(),
      HTML(author_date_text)
    ),
    mainPanel(
      tabsetPanel(id = "tabs",
                  tabPanel(
                    title = "Instructions",
                    br(),
                    #p(style = "font-size: 20px;", "Welcome to the App accompanying the article 'XXXXX'"),
                    p(style = "font-size: 18px;", "This application is an educational resource to learn about basic concepts as Sensitivity and Specificity"),
                    br(),
                    p(style = "font-size: 16px;", "The", tags$strong("Sidebar panel"), "on the left allows to insert some parameters to simulate data and to check both empirical and expected (i.e. theoretical) classifications. You can change parameters as desired and then check the results in the Tabs 1. 2. and 3. . 
                      Click on 'Regenerate' data to simulate new samples."),
                    tags$ul(
                      tags$li(style = "font-size: 16px;", tags$strong("Simulated Data"), " tab shows the results for the simulated data with parameter set on the sidebar"),        
                      tags$li(style = "font-size: 16px;", tags$strong("Theoretical Data"), " tab shows the expected results (i.e. theoretical expectations), given the parameters specified in the sidebar panel"),        
                      tags$li(style = "font-size: 16px;", tags$strong("ROC Curve"), " tab shows the ROC Curve for the simulated data."),
                      #tags$li(style = "font-size: 16px;", "See the 'Help' tab for details and clarifications")
                    ),
                    HTML(warning_text),
                    br(),
                    br(),
                    # The code below is enclosed within (div) to have a colored box
                    #div(
                    #  style = "border: 1px solid #ccc; /* Light gray border */
                    #           padding: 15px; /* Space inside the box */
                    #           margin-bottom: 20px; /* Space below the box */
                    #           background-color: #f9f9f9; /* Very light gray background */
                    #           border-radius: 5px; /* Slightly rounded corners */
                    #           box-shadow: 2px 2px 5px rgba(0,0,0,0.1); /* Subtle shadow */",
                    
                    #  h4("Select Regression Models", style = "margin-top: 0;"), # Adjust margin for h4 inside the div
                    #  br(),
                    #  HTML("Select here the regression models you want to use. <br> First option is recommended but it works only if the score from LEQ (Life Experience Questionnaire) is available.<br>"),
                    #  br(),
                    #radioButtons("selected_models", "Select Models",
                    #             choices = c("Models including Age, Education, Sex, LEQ" = "including_CRQ",
                    #                         "Models including Age, Education, Sex" = "NOTincluding_CRQ"
                    #             ))
                    # )
                  ),
                  tabPanel("Simulated Data",
                           plotOutput("histPlot"),
                           h4("Performance metrics"),
                           fluidRow(class = "metric-row",
                                    column(12, 
                                           div(style = "display: flex; justify-content: space-between;",
                                               div(strong("Sensitivity:"), textOutput("sensitivity_sim", inline = TRUE)),
                                               div(strong("Specificity:"), textOutput("specificity_sim", inline = TRUE)),
                                               div(strong("PPV:"), textOutput("precision_sim", inline = TRUE)),
                                               div(strong("NPV:"), textOutput("npv_sim", inline = TRUE)),
                                               div(strong("Accuracy:"), textOutput("accuracy_sim", inline = TRUE)),
                                               div(strong("F1:"), textOutput("f1_sim", inline = TRUE)),
                                               div(strong("AUC:"), textOutput("auc_sim", inline = TRUE))
                                           )
                                    )
                           ),
                           hr(),
                           h4("Proportions"),
                           fluidRow(
                             column(3, strong("True Positives:"), textOutput("TP_sim")),
                             column(3, strong("False Negatives:"), textOutput("FN_sim")),
                             column(3, strong("False Positives:"), textOutput("FP_sim")),
                             column(3, strong("True Negatives:"), textOutput("TN_sim"))
                           ),
                           hr(),
                           h4("Raw Counts"),
                           fluidRow(
                             column(3, strong("True Positives:"), textOutput("TP_count")),
                             column(3, strong("False Negatives:"), textOutput("FN_count")),
                             column(3, strong("False Positives:"), textOutput("FP_count")),
                             column(3, strong("True Negatives:"), textOutput("TN_count"))
                           ),
                           HTML(warning_text)
                  ),
                  tabPanel("Theoretical Data",
                           plotOutput("densityPlot"),
                           h4("Performance metrics"),
                           fluidRow(class = "metric-row",
                                    div(style = "display: flex; justify-content: space-between;",
                                        column(12, 
                                               div(style = "display: flex; justify-content: space-between;",
                                                   div(strong("Sensitivity:"), textOutput("sensitivity", inline = TRUE)),
                                                   div(strong("Specificity:"), textOutput("specificity", inline = TRUE)),
                                                   div(strong("PPV:"), textOutput("precision", inline = TRUE)),
                                                   div(strong("NPV:"), textOutput("npv", inline = TRUE)),
                                                   div(strong("Accuracy:"), textOutput("accuracy", inline = TRUE)),
                                                   div(strong("F1:"), textOutput("f1", inline = TRUE)),
                                                   div(strong("AUC:"), textOutput("auc", inline = TRUE))
                                                   
                                               )
                                        )
                                    )
                           ),
                           hr(),
                           h4("Proportions"),
                           fluidRow(
                             column(3, strong("True Positives:"), textOutput("TP")),
                             column(3, strong("False Negatives:"), textOutput("FN")),
                             column(3, strong("False Positives:"), textOutput("FP")),
                             column(3, strong("True Negatives:"), textOutput("TN"))
                           ),
                           hr(),
                           h4("What Do the Colors Mean?"),
                           tags$ul(
                             tags$li(strong("True Positive (Green):"), " Pathological participant correctly classified (score < cutoff)"),
                             tags$li(strong("False Negative (Red):"), " Pathological participant incorrectly classified as Healthy (score ≥ cutoff)"),
                             tags$li(strong("False Positive (Orange):"), " Healthy participant incorrectly classified as Pathological (score < cutoff)"),
                             tags$li(strong("True Negative (Blue):"), " Healthy participant correctly classified (score ≥ cutoff)")
                           ),
                           HTML(warning_text)
                  ),
                  tabPanel("ROC Curve",
                           plotOutput("rocPlot", height = "500px"),
                           hr(),
                           h4("ROC Analysis Results"),
                           fluidRow(
                             column(6,
                                    h5("Area Under the Curve (AUC) with CI"),
                                    verbatimTextOutput("roc_auc_output")
                             ),
                             column(6,
                                    h5("Optimal Threshold (Youden Index)"),
                                    verbatimTextOutput("roc_optimal_output")
                             )
                           ),
                           hr(),
                           h4("Understanding the ROC Curve"),
                           tags$ul(
                             tags$li("The ROC curve plots Sensitivity (True Positive Rate) against 1 - Specificity (False Positive Rate)"),
                             tags$li("The point shows the currently selected threshold"),
                             tags$li("AUC = 0.5 indicates random performance; AUC = 1.0 indicates perfect classification"),
                             tags$li("The diagonal line represents chance performance")
                           ),
                           HTML(warning_text)
                  )
      )
    )
  )
)

server <- function(input, output, session) {
  data <- reactiveVal()
  
  generateData <- function() {
    pat_n <- input$pat_n
    healthy_n <- input$healthy_n
    
    pat <- rnorm(pat_n, mean = input$pat_mean, sd = input$pat_sd)
    healthy <- rnorm(healthy_n, mean = input$healthy_mean, sd = input$healthy_sd)
    
    dat <- data.frame(
      Score = c(pat, healthy),
      Group = factor(c(rep("Pathological", pat_n), rep("Healthy", healthy_n)))
    )
    data(dat)
  }
  
  observeEvent(input$regenerate, {
    generateData()
  })
  
  observe({
    generateData()
  })
  
  rocData <- reactive({
    req(data())
    dat <- data()
    tryCatch({
      roc(dat$Group, dat$Score, ci = TRUE, percent = FALSE, direction = ">", quiet = TRUE)
    }, error = function(e) {
      NULL
    })
  })
  
  output$histPlot <- renderPlot({
    
    req(data())
    dat <- data()
    threshold <- input$cutoff
    roc_obj <- rocData()
    
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    
    Sensitivity <- TP / (TP + FN)
    Specificity <- TN / (TN + FP)
    Accuracy <- (TP + TN) / (TP + TN + FP + FN)
    
    show_path <- as.logical(input$show_pathological)
    show_hlth <- as.logical(input$show_healthy)
    
    # Determine plot ranges (used fixed range)
    h1 <- hist(dat$Score[dat$Group == "Pathological"], plot = FALSE)
    h2 <- hist(dat$Score[dat$Group == "Healthy"], plot = FALSE)
    x_range <- range(c(h1$breaks, h2$breaks))
    y_range <- range(c(h1$counts, h2$counts)) * 1.1
    
    if (!(show_path | show_hlth)){
      # If neither shown, create empty plot
      plot(1, type = "n", xlim = x_range, ylim = y_range,
           xlab = "Score", ylab = "Frequency",
           main = "No distributions selected")
      
      abline(v = threshold, lwd = 2, col = "red")
      
      return()
    }
    
    # Create base plot
    plot(1, type = "n", xlim = x_range, ylim = y_range,
         xlab = "Score", ylab = "Frequency",
         main = paste0("Specificity = ", round(Specificity, 2),
                       ", Sensitivity = ", round(Sensitivity, 2),
                       "\nAUC = ", round(roc_obj$auc, 2)))
    
    # Plot pathological if selected
    if (show_path) {
      hist(dat$Score[dat$Group == "Pathological"],
           col = rgb(0, 0, 0, 0.5),
           breaks = 10, add = TRUE)
    }
    
    # Plot healthy if selected
    if (show_hlth) {
      hist(dat$Score[dat$Group == "Healthy"],
           col = rgb(0.3, 0.4, 0.8, 0.5),
           breaks = 10, add = TRUE)
    }
    
    abline(v = threshold, lwd = 3, lty = 2)
    
    # Create legend based on what's shown
    legend_labels <- c()
    legend_fills <- c()
    if (show_path) {
      legend_labels <- c(legend_labels, "Pathological")
      legend_fills <- c(legend_fills, rgb(0, 0, 0, 0.5))
    }
    if (show_hlth) {
      legend_labels <- c(legend_labels, "Healthy")
      legend_fills <- c(legend_fills, rgb(0.3, 0.4, 0.8, 0.5))
    }
    
    if (length(legend_labels) > 0) {
      legend("topright", legend = legend_labels, fill = legend_fills)
    }
  })
  
  # Simulated Data panel outputs
  output$sensitivity_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    round(TP / (TP + FN), 3)
  })
  
  output$specificity_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    round(TN / (TN + FP), 3)
  })
  
  output$precision_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    if ((TP + FP) == 0) return("N/A")
    round(TP / (TP + FP), 3)
  })
  
  output$npv_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    if ((TN + FN) == 0) return("N/A")
    round(TN / (TN + FN), 3)
  })
  
  output$accuracy_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    round((TP + TN) / (TP + TN + FP + FN), 3)
  })
  
  output$f1_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    
    precision <- TP / (TP + FP)
    recall <- TP / (TP + FN)
    
    if ((precision + recall) == 0) return("N/A")
    f1 <- 2 * (precision * recall) / (precision + recall)
    round(f1, 3)
  })
  
  output$auc_sim <- renderText({
    req(data())
    req(rocData())
    round(rocData()$auc, 3)
  })
  
  output$TP_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    total_pat <- sum(dat$Group == "Pathological")
    round(TP / total_pat, 3)
  })
  
  output$FN_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    total_pat <- sum(dat$Group == "Pathological")
    round(FN / total_pat, 3)
  })
  
  output$FP_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    total_healthy <- sum(dat$Group == "Healthy")
    round(FP / total_healthy, 3)
  })
  
  output$TN_sim <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    total_healthy <- sum(dat$Group == "Healthy")
    round(TN / total_healthy, 3)
  })
  
  # Raw count outputs for Simulated Data panel
  output$TP_count <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    sum(dat$Score[dat$Group == "Pathological"] < threshold)
  })
  
  output$FN_count <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    sum(dat$Score[dat$Group == "Pathological"] >= threshold)
  })
  
  output$FP_count <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    sum(dat$Score[dat$Group == "Healthy"] < threshold)
  })
  
  output$TN_count <- renderText({
    req(data())
    dat <- data()
    threshold <- input$cutoff
    sum(dat$Score[dat$Group == "Healthy"] >= threshold)
  })
  
  output$densityPlot <- renderPlot({
    
    threshold <- input$cutoff
    mean_pat <- input$pat_mean
    sd_pat <- input$pat_sd
    mean_healthy <- input$healthy_mean
    sd_healthy <- input$healthy_sd
    
    pat_x_lims = c(mean_pat - 3*sd_pat , mean_pat + 3*sd_pat )
    healthy_x_lims = c(mean_healthy - 3*sd_healthy , mean_healthy + 3*sd_healthy )
    tot_x_lims = c(min(c(pat_x_lims, healthy_x_lims)), max(pat_x_lims, healthy_x_lims))
    
    show_path <- as.logical(input$show_pathological)
    show_hlth <- as.logical(input$show_healthy)
    
    x_vals <- seq(tot_x_lims[1], tot_x_lims[2], by = 0.1)
    d_pat <- dnorm(x_vals, mean = mean_pat, sd = sd_pat)
    d_healthy <- dnorm(x_vals, mean = mean_healthy, sd = sd_healthy)
    
    d_pat = d_pat * input$pat_n/(input$pat_n+input$healthy_n)
    d_healthy = d_healthy * input$healthy_n/(input$pat_n+input$healthy_n)
    
    sens <- pnorm(threshold, mean = mean_pat, sd = sd_pat)
    spec <- 1 - pnorm(threshold, mean = mean_healthy, sd = sd_healthy)
    accuracy <- (sens + spec) / 2
    auc <- pnorm((mean_healthy - mean_pat) / sqrt(sd_pat^2 + sd_healthy^2))
    
    # Determine y-axis range based on what's shown
    if (show_path && show_hlth) {
      y_max <- max(c(d_pat, d_healthy)) * 1.1
    } else if (show_path) {
      y_max <- max(d_pat) * 1.1
    } else if (show_hlth) {
      y_max <- max(d_healthy) * 1.1
    } else {
      y_max <- 1
    }
    
    plot(x_vals, d_pat, type = "n", ylim = c(0, y_max*1.1),
         xlab = "Score", ylab = "Density (scaled by N)",
         main = paste0("Specificity = ", round(spec, 2),
                       ", Sensitivity = ", round(sens, 2),
                       "\nAUC = ", round(auc, 2)))
    
    # Plot pathological distribution components if selected
    if (show_path) {
      polygon(c(x_vals[x_vals < threshold], rev(x_vals[x_vals < threshold])),
              c(d_pat[x_vals < threshold], rep(0, sum(x_vals < threshold))),
              col = rgb(0, 0.7, 0, 0.4), border = NA)  # TP
      polygon(c(x_vals[x_vals >= threshold], rev(x_vals[x_vals >= threshold])),
              c(d_pat[x_vals >= threshold], rep(0, sum(x_vals >= threshold))),
              col = rgb(1, 0, 0, 0.4), border = NA)  # FN
    }
    
    # Plot healthy distribution components if selected
    if (show_hlth) {
      polygon(c(x_vals[x_vals < threshold], rev(x_vals[x_vals < threshold])),
              c(d_healthy[x_vals < threshold], rep(0, sum(x_vals < threshold))),
              col = rgb(1, 0.5, 0, 0.4), border = NA)  # FP
      polygon(c(x_vals[x_vals >= threshold], rev(x_vals[x_vals >= threshold])),
              c(d_healthy[x_vals >= threshold], rep(0, sum(x_vals >= threshold))),
              col = rgb(0, 0, 1, 0.4), border = NA)  # TN
    }
    
    # Draw distribution lines
    if (show_path) {
      lines(x_vals, d_pat, col = "black", lwd = 2)
    }
    if (show_hlth) {
      lines(x_vals, d_healthy, col = "blue", lwd = 2)
    }
    
    abline(v = threshold, lwd = 3, lty = 2)
  })
  
  # Theoretical metric outputs (Density View panel)
  output$sensitivity <- renderText({
    round(pnorm(input$cutoff, mean = input$pat_mean, sd = input$pat_sd), 3)
  })
  
  output$specificity <- renderText({
    round(1 - pnorm(input$cutoff, mean = input$healthy_mean, sd = input$healthy_sd), 3)
  })
  
  output$precision <- renderText({
    # Precision = TP / (TP + FP)
    # For theoretical: P(Score < cutoff | Pathological) * P(Pathological) / P(Score < cutoff)
    sens <- pnorm(input$cutoff, input$pat_mean, input$pat_sd)
    fp_rate <- pnorm(input$cutoff, input$healthy_mean, input$healthy_sd)
    
    # Assuming equal priors (can be adjusted based on pat_n and healthy_n)
    prior_pat <- input$pat_n / (input$pat_n + input$healthy_n)
    prior_healthy <- input$healthy_n / (input$pat_n + input$healthy_n)
    
    numerator <- sens * prior_pat
    denominator <- sens * prior_pat + fp_rate * prior_healthy
    
    if (denominator == 0) return("N/A")
    round(numerator / denominator, 3)
  })
  
  output$npv <- renderText({
    # NPV = TN / (TN + FN)
    # For theoretical: P(Score >= cutoff | Healthy) * P(Healthy) / P(Score >= cutoff)
    spec <- 1 - pnorm(input$cutoff, input$healthy_mean, input$healthy_sd)
    fn_rate <- 1 - pnorm(input$cutoff, input$pat_mean, input$pat_sd)
    
    prior_pat <- input$pat_n / (input$pat_n + input$healthy_n)
    prior_healthy <- input$healthy_n / (input$pat_n + input$healthy_n)
    
    numerator <- spec * prior_healthy
    denominator <- spec * prior_healthy + fn_rate * prior_pat
    
    if (denominator == 0) return("N/A")
    round(numerator / denominator, 3)
  })
  
  output$accuracy <- renderText({
    s <- pnorm(input$cutoff, input$pat_mean, input$pat_sd)
    sp <- 1 - pnorm(input$cutoff, input$healthy_mean, input$healthy_sd)
    round((s + sp) / 2, 3)
  })
  
  output$f1 <- renderText({
    # Calculate theoretical precision
    sens <- pnorm(input$cutoff, input$pat_mean, input$pat_sd)
    fp_rate <- pnorm(input$cutoff, input$healthy_mean, input$healthy_sd)
    
    prior_pat <- input$pat_n / (input$pat_n + input$healthy_n)
    prior_healthy <- input$healthy_n / (input$pat_n + input$healthy_n)
    
    numerator <- sens * prior_pat
    denominator <- sens * prior_pat + fp_rate * prior_healthy
    
    if (denominator == 0) return("N/A")
    precision <- numerator / denominator
    recall <- sens
    
    if ((precision + recall) == 0) return("N/A")
    f1 <- 2 * (precision * recall) / (precision + recall)
    round(f1, 3)
  })
  
  output$auc <- renderText({
    d <- sqrt(input$pat_sd^2 + input$healthy_sd^2)
    auc <- pnorm((input$healthy_mean - input$pat_mean) / d)
    round(auc, 3)
  })
  
  output$TP <- renderText({
    round(pnorm(input$cutoff, input$pat_mean, input$pat_sd), 3)
  })
  output$FN <- renderText({
    round(1 - pnorm(input$cutoff, input$pat_mean, input$pat_sd), 3)
  })
  output$FP <- renderText({
    round(pnorm(input$cutoff, input$healthy_mean, input$healthy_sd), 3)
  })
  output$TN <- renderText({
    round(1 - pnorm(input$cutoff, input$healthy_mean, input$healthy_sd), 3)
  })
  
  # ROC Curve tab outputs
  output$rocPlot <- renderPlot({
    req(data())
    req(rocData())
    roc_obj <- rocData()
    
    if (is.null(roc_obj)) return(NULL)
    
    # Get current threshold performance
    dat <- data()
    threshold <- input$cutoff
    TP <- sum(dat$Score[dat$Group == "Pathological"] < threshold)
    FN <- sum(dat$Score[dat$Group == "Pathological"] >= threshold)
    TN <- sum(dat$Score[dat$Group == "Healthy"] >= threshold)
    FP <- sum(dat$Score[dat$Group == "Healthy"] < threshold)
    
    current_sens <- TP / (TP + FN)
    current_spec <- TN / (TN + FP)
    
    # Get optimal threshold
    optimal_coords <- coords(roc_obj, "best", ret = c("threshold", "sensitivity", "specificity"),
                             best.method = "youden", transpose = FALSE)
    
    # Plot ROC curve
    plot(roc_obj,
         main = paste0("ROC Curve - simulated data, (AUC = ", round(roc_obj$auc, 3), ")"),
         col = "darkblue", lwd = 2,
         print.auc = FALSE,
         print.thres = threshold,
         legacy.axes = TRUE,
         xlab = "1 - Specificity (False Positive Rate)",
         ylab = "Sensitivity (True Positive Rate)")
    
    
  })
  
  output$roc_auc_output <- renderText({
    req(rocData())
    roc_obj <- rocData()
    ci <- roc_obj$ci
    if (is.null(roc_obj) || is.null(roc_obj$ci)) return("N/A")
    paste0("AUC: ", round(roc_obj$auc, 4), "; ROC 95% CI: [", round(ci[1], 4), ", ", round(ci[3], 4), "]")
  })
  
  output$roc_optimal_output <- renderText({
    req(rocData())
    roc_obj <- rocData()
    if (is.null(roc_obj)) return("N/A")
    
    tryCatch({
      optimal <- coords(roc_obj, "best", ret = c("threshold", "youden", "sensitivity", "specificity"),
                        best.method = "youden", transpose = FALSE)
      paste0("Threshold: ", round(optimal$threshold, 3), "\n",
             "Youden: ", round(optimal$youden, 3), "\n",
             "Sensitivity: ", round(optimal$sensitivity, 3), "\n",
             "Specificity: ", round(optimal$specificity, 3), "\n")
    }, error = function(e) {
      "Error calculating optimal threshold"
    })
  })
  
  observeEvent(input$setOptimal, {
    tab <- input$tabs
    if (tab == "Simulated Data") {
      req(data())
      req(rocData())
      roc_obj <- rocData()
      if (!is.null(roc_obj)) {
        tryCatch({
          threshold <- as.numeric(coords(roc_obj, "best", ret = "threshold", best.method = "youden"))
          updateSliderInput(session, "cutoff", value = round(threshold, 2))
        }, error = function(e) {
          showNotification("Error calculating optimal threshold. Please try regenerating data.", type = "error")
        })
      }
    } else {
      thresholds <- seq(0, 40, by = 0.1)
      youden <- sapply(thresholds, function(t) {
        sens <- pnorm(t, mean = input$pat_mean, sd = input$pat_sd)
        spec <- 1 - pnorm(t, mean = input$healthy_mean, sd = input$healthy_sd)
        sens + spec - 1
      })
      threshold <- thresholds[which.max(youden)]
      updateSliderInput(session, "cutoff", value = round(threshold, 2))
    }
  })
}

shinyApp(ui, server)