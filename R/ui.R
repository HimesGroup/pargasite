ui <- fluidPage(
  title = "PARGASITE",
  theme = shinythemes::shinytheme("darkly"),
  ## theme = "www/minty.css",
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
        label = span("Color scale (useful when outliers exist)",
                     style = "font-weight: bold"),
        choices = list("As is", "Upper bounded"), inline = TRUE)
    )
  )
)
