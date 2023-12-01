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
      tags$div(checkboxInput(
             inputId = "color_bounded",
             label = "Upper bounded (useful when extreme outliers exist)",
             value = FALSE,
             width = "100%"
           ), style = "margin-top: -0.7em"),
      tags$div(tags$p(
             "- Free: each data has its own scale for the selected year",
             tags$br(),
             "- Fixed: all data share the same scale across the years"
           ), style = "color: #900C3F"),
      width = 9
    )
  )
)
