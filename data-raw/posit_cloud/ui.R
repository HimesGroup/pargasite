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
      tabsetPanel(
        tabPanel(
          "Map View",
          withSpinner(leafletOutput("us_map", height = "67vh")),
          hr(),
          radioButtons(
            inputId = "color",
            label = span("Color scale",
                         style = "font-weight: bold"),
            choices = list("As is", "Consistent"), inline = TRUE
          ),
          tags$div(checkboxInput(
                 inputId = "color_bounded",
                 label = "Upper bounded (useful when extreme outliers exist)",
                 value = FALSE,
                 width = "100%"
               ), style = "margin-top: -0.7em")
        ),
        tabPanel(
          "About",
          br(),
          h3("PARGASITE", style = "font-weight: bold"),
          p("Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE) is",
            "an R package to offer tools and Shiny application to estimate and",
            "visualize major pollutant levels (CO, NO2, SO2, Ozone, PM2.5 and PM10)",
            "covering the conterminous United States at user-defined time ranges.",
            "It help users to automatically retrieves pollutant data via the",
            "Environmental Protection Agency’s (EPA) Air Quality System (AQS)",
            "API service, filters the data by exceptional event (e.g., wildfire)",
            "status, performs spatial interpolations, and summarizes pollutant",
            "concentrations by geographic boundaries including State, County, ",
            "and Core-Based Statistical Area (CBSA)."),
          br(),
          h4("References", style = "font-weight: bold"),
          p("Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution",
            "Data into Health Studies. AMIA Jt Summits Transl Sci Proc.",
            "2019;2019:553–561. PMID:",
            a("31259010",href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6568125/",
              target="_blank"),
            ".")
        )
      ),
      width = 9
    )
  )
)
