library(leaflet)

shinyUI(fluidPage(theme = "bootstrap.css",

                  tags$head(
                    tags$style(HTML("
                                    h1 {
                                    font-weight: 1000;
                                    line-height: 2;
                                    color: #fff;
                                    }

                                    "))
                    ),

                  headerPanel("Pollution And health Risk factor Geospatial Analysis SITE (PARGASITE)"
                  ),
                  mainPanel(
                    leafletOutput("map", width = "100%"),
                    p("Data source: United States Environmental Protection Agency (EPA). <aqs.epa.gov/aqsweb/airdata.download_files.html>")),
                  br(),
                  sidebarPanel(
                    h4("Map View"),
                    selectizeInput(inputId = "year",
                                   label = "Year",
                                   choices = c("2005":"2017"),
                                   selected = "2017",
                                   multiple = FALSE),
                    selectizeInput(inputId = "pollutant",
                                   label = "Pollutant",
                                   choices = c("PM2.5", "Ozone", "NO2", "SO2", "CO"),
                                   select = "PM2.5",
                                   multiple = FALSE),
                    p(textOutput("notes")),
                    h5(textOutput("latlong")),
                    h5(textOutput("pollutant_val")),
                    br(),
                    h4("Upload dataset to get corresponding pollution estimates"),
                    p("The file returned will have a column for each pollutant; the value will be an average of monthly estimates over the specified time period."),
                    fluidRow(column(6, selectizeInput('start_month', label = "Start month",
                                                      choices = c("Jan", "Feb", "March", "April", "May",
                                                                  "June", "July", "Aug", "Sept", "Oct",
                                                                  "Nov", "Dec"),
                                                      selected = "Jan",
                                                      multiple = FALSE)),
                             column(6, selectizeInput(inputId = "start_year",
                                                      label = "Start Year",
                                                      choices = c("2005":"2017"),
                                                      selected = "2015",
                                                      multiple = FALSE))),
                    fluidRow(column(6, selectizeInput('end_month', label = "End month",
                                                      choices = c("Jan", "Feb", "March", "April", "May",
                                                                  "June", "July", "Aug", "Sept", "Oct",
                                                                  "Nov", "Dec"),
                                                      selected = "March",
                                                      multiple = FALSE)),
                             column(6, selectizeInput(inputId = "end_year",
                                                      label = "End Year",
                                                      choices = c("2005":"2017"),
                                                      selected = "2015",
                                                      multiple = FALSE))),
                    fileInput("user_file", "Choose .csv file with Latitude and Longitude columns",
                              multiple = FALSE,
                              accept = c("text/csv",
                                         "text/comma-separated-values,
                                         text/plain",
                                         ".csv")),
                    downloadButton("finalDownload", "Download"))
))
