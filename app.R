library(shiny)
library(readxl)
library(meta)
library(metafor)
library(Matrix)
library(readxl)
library(plotrix)
library(PerformanceAnalytics)
library(tidyverse)
library(MuMIn)
library(ggplot2)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)
library(plotly)


ui <- fluidPage(
  titlePanel("Shiny meta regression"),
  navbarPage(
    "Meta",
    tabPanel(
      "Load data",
      sidebarLayout(
        sidebarPanel(
          fileInput("file", "Select file from your computer:"),
          uiOutput("var_ui")
        ),
        mainPanel(
          tableOutput("load_d")
        )
      )
    ),
    tabPanel(
      "Statistics summary",
      verbatimTextOutput("lmSummary")
    ),
    tabPanel(
      "Funnel plot",
      plotOutput("plot", height = "820px")
    ),
    tabPanel(
      "Forest plot",
      plotOutput("forest", height = "820px")
    )
  )
)



server <- function(input, output, session) {
  df <- reactive({
    req(input$file)
    read_excel(input$file$datapath)
  })

  output$load_d <- renderTable({
    req(df())
    df()
  })


  random_eff <- reactive({
    req(df())
    model <- rma.mv(Fat_mean, Fat_var, mods = ~ factor(Level), random = ~ 1 | Author, data = df(), slab = paste(Author))
    return(model)
  })

  output$lmSummary <- renderPrint({
    req(random_eff())
    summary(random_eff())
  })

  output$plot <- renderPlot({
    funnel(random_eff(), level = c(90, 95, 99), shade = c("white", "gray", "darkgray"), refline = 0)
  })

  output$forest <- renderPlot({
    forest(random_eff(),
      addfit = TRUE, level = 95, header = TRUE, xlab = "Fat %", ilab = cbind(df()$n, df()$Gender, df()$Level, df()$Method),
      ilab.xpos = c(-18, -14, -8, -3)
    )
    op <- par(cex = 0.75, font = 4)
    text(c(-18, -14, -8, -3), 94, c("n = Subjects", "Gender", "Level", "Method"))
  })
}
shinyApp(ui, server)
