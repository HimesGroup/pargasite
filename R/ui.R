ui <- fluidPage(
  title = "PARGASITE",
  titlePanel(h2(
    "Pollution-Associated Risk Geospatial Analysis Site (PARGASITE)",
    style = "font-weight: bold; margin-bottom: 20px")
    ),
  sidebarLayout(
    sidebarPanel(
      uiOutput("pollutant_ui"),
      width = 3
    ),
    mainPanel(
      ## withSpinner(leafletOutput("us_map", width = "100%", height = 800)),
      withSpinner(leafletOutput("us_map", height = "67vh")),
      hr(),
      radioButtons(
        inputId = "color",
        label = span("Color scale",
                     style = "font-weight: bold"),
        choices = list("Free", "Fixed"), inline = TRUE
      ),
      ## span(
      ##   tags$div(checkboxInput(
      ##          inputId = "color_bounded",
      ##          label = "Upper bounded (useful when extreme outliers exist)",
      ##          value = FALSE,
      ##          width = "70%"
      ##        ), style = "margin-top: -0.7em"),
      ##   tags$div(numericInput(
      ##                     inputId = "outlier_cutoff",
      ##                     label = NULL,
      ##                     value = 0,
      ##                     width = "30%"
      ##                   ), style = "margin-top: -0.7em")
      ## ),
      tags$div(checkboxInput(
             inputId = "color_bounded",
             label = "Upper bounded (useful when extreme outliers exist)",
             value = FALSE,
             width = "100%"
           ), style = "margin-top: -0.7em; margin-right: 0.5em; display: inline-block"),
      tags$head(tags$style(HTML(".not_bold label {font-weight:normal; color: #37474F}"))),
      tags$div(numericInput(
             inputId = "outlier_cutoff",
             label = HTML("threshold"),
             value = 0,
             width = "100%"
           ), class = "not_bold",
           style = "margin-top: -2.0em; display: inline-block"),
      ## tags$div(p("cut-off"), style = "display: inline-block"),
      tags$div(tags$p(
             "- Free: each data has its own color-scale for the selected year",
             tags$br(),
             "- Fixed: all data share the same color-scale across the years"
           ), style = "color: #900C3F"),
      width = 9
    )
  )
)
