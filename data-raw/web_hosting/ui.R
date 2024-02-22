ui <- fluidPage(
  title = "PARGASITE",
  titlePanel(h2(
    "Pollution-Associated Risk Geospatial Analysis Site (PARGASITE)",
    style = "font-weight: bold; margin-bottom: 20px")
    ),
  tabsetPanel(
    tabPanel(
      "Criteria Pollutants",
      sidebarLayout(
        sidebarPanel(
          uiOutput("pollutant_ui"),
          width = 3
        ),
        mainPanel(
          withSpinner(leafletOutput("us_map", height = "67vh")),
          hr(),
          radioButtons(
            inputId = "color",
            label = span("Color scale",
                         style = "font-weight: bold"),
            choices = list("Fixed", "Free"), inline = TRUE
          ),
          tags$div(checkboxInput(
                 inputId = "color_bounded",
                 label = "Upper bounded (useful when extreme outliers exist)",
                 value = FALSE,
                 width = "100%"
               ),
               style = "margin-top: -0.7em; margin-right: 0.5em; display: inline-block"
               ),
          tags$head(tags$style(HTML(".not_bold label {font-weight:normal; color: #37474F}"))),
          tags$div(numericInput(
                 inputId = "outlier_cutoff",
                 label = HTML("threshold"),
                 value = 0,
                 width = "100%"
               ), class = "not_bold",
               style = "margin-top: -2.0em; display: inline-block"),
          tags$div(tags$p(
                          "- Fixed: all data share the same color-scale across the years",
                          tags$br(),
                          "- Free: each data has its own color-scale for the selected year"
                        ), style = "color: #900C3F"),
          width = 9
        )
      )
    ),
    tabPanel(
      "AQI",
      sidebarLayout(
        sidebarPanel(
            fluidRow(
              column(
                12,
                h3("Choose AQI statistic to visualize",
                   style = "font-weight: bold; color: #DC4C64; margin-top:10px; margin-bottom: 15px"),
                selectizeInput(
                  inputId = "aqi_stat",
                  label = NULL,
                  choice = c("Median", "Max", "90th Percentile"),
                  selected = "Median",
                  multiple = FALSE
                ),
                h4("Data Info", style = "font-weight: bold; color: #332D2D"),
                p("Source: AQS Annual Summary Data",
                  style = "font-weight: bold; color: orange"),
                hr(),
                selectizeInput(
                  inputId = "aqi_year",
                  label = "Year",
                  choice = 1996:2022,
                  multiple = FALSE
                ),
                hr(),
                radioButtons(
                  inputId = "aqi_summary",
                  label = "Summarize by",
                  choices = c("County", "CBSA"),
                  inline = TRUE
                ),
                hr(),
                h4("AQI value", style = "font-weight: bold; color: #9CCC65"),
                h5(htmlOutput("aqi_val")),
                hr(),
                p(span("Good (0-50)", style = "font-weight: bold; background-color: #00e400"),
                  " Air quality is satisfactory, and air pollution poses little or no risk."),
                p(span("Moderate (51-100)", style = "font-weight: bold; background-color: #ffff00"),
                  paste0(" Air quality is acceptable. However, there may be a risk for some people, ",
                         "particularly those who are unusually sensitive to air pollution.")),
                p(span("Unhealthy for Sensitive Groups (101-150)",
                       style = "font-weight: bold; background-color: #ff7e00"),
                  paste0(" Members of sensitive groups may experience health effects. ",
                         "The general public is less likely to be affected.")),
                p(span("Unhealthy (151-200)",
                       style = "font-weight: bold; background-color: #ff0000"),
                  paste0(" Some members of the general public may experience health effects; ",
                         "members of sensitive groups may experience more serious health effects.")),
                p(span("Very Unhealthy (201-300)",
                       style = "font-weight: bold; background-color: #8f3f97"),
                  " Health alert: The risk of health effects is increased for everyone. "),
                p(span("Hazardous (> 301)",
                       style = "font-weight: bold; background-color: #7e0023"),
                  paste0(" Health warning of emergency condition: ",
                         "every is more likely to be affected."))
              )
            ),
          width = 3
        ),
        mainPanel(
          withSpinner(leafletOutput("aqi_map", height = "67vh")),
          width = 9
        )
      )
    ),
    tabPanel(
      "About",
      tags$br(),
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
      p("We have no affiliation with the EPA."),
      tags$br(),
      h4("Contributors", style = "font-weight: bold"),
      p("Jaehyun Joo, Nisha Narayanan, Avantika Diwadkar, Rebecca Greenblatt, and Blanca Himes"),
      tags$br(),
      h4("References", style = "font-weight: bold"),
      p("Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution",
        "Data into Health Studies. AMIA Jt Summits Transl Sci Proc.",
        "2019;2019:553–561. PMID:",
        tags$a("31259010",href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6568125/",
               target="_blank"),
        ".")
    )
  )
)
