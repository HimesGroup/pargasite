ui <- fluidPage(
  title = "PARGASITE",
  titlePanel(h2(
    "Pollution-Associated Risk Geospatial Analysis Site (PARGASITE)",
    style = "font-weight: bold; margin-bottom: 20px")
    ),
  tabsetPanel(
    tabPanel(
      "Pollutant Map",
      sidebarLayout(
        sidebarPanel(
          uiOutput("pollutant_ui"),
          width = 3
        ),
        mainPanel(
          conditionalPanel(
            paste0("(typeof input.month === 'undefined' && input.year.length == 1)",
                   " || ",
                   "(typeof input.month !== 'undefined' && input.month.length == 1)"),
            withSpinner(leafletOutput("smap", height = "67vh")),
            conditionalPanel(
              "input.summary === 'Grid'",
              hr(),
              uiOutput("grid_val_ui")
            )
          ),
          conditionalPanel(
            paste0("(typeof input.month === 'undefined' && input.year.length > 1)",
                   " || ",
                   "(typeof input.month !== 'undefined' && input.month.length > 1)"),
            withSpinner(uiOutput("mmap"))
          ),
          width = 9
        )
      )
    ),
    tabPanel(
      "About",
      br(),
      h3("PARGASITE", style = "font-weight: bold"),
      p("Pollution-Associated Risk Geospatial Analysis Site (PARGASITE) is",
        "an R package that offers tools to estimate and visualize levels of",
        "major pollutant levels (CO, NO2, SO2, Ozone, PM2.5 and PM10)",
        "across the conterminous United States for user-defined time ranges.",
        "It helps users to automatically retrieves pollutant data from the",
        "Environmental Protection Agency's (EPA) Air Quality System (AQS)",
        "API service. PARGASITE filters the data by exceptional event",
        "(e.g., wildfire) status, performs spatial interpolations, and",
        "summarizes pollutant concentrations by geographic boundaries",
        "including state, county, and Core-Based Statistical Area (CBSA)."),
      p("We have no affiliation with the EPA."),
      br(),
      h4("Contributors", style = "font-weight: bold"),
      p("Jaehyun Joo, Nisha Narayanan, Avantika Diwadkar, Rebecca Greenblatt, and Blanca Himes"),
      br(),
      h4("References", style = "font-weight: bold"),
      p("Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution",
        "Data into Health Studies. AMIA Jt Summits Transl Sci Proc.",
        "2019;2019:553-561. PMID: ",
        a("31259010",href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6568125/",
          target="_blank"),
        ".")
    )
  )
)
