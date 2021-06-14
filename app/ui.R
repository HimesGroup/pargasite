#.libPaths("/home/rebecca/R/x86_64-pc-linux-gnu-library/3.4/")
#.libPaths("/home/maya/R/x86_64-pc-linux-gnu-library/3.4/")

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
                  
                  headerPanel("Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE)"
                  ),
                  mainPanel(
                    leafletOutput("map", width = "100%",height= 600),
                    p("Data source: United States Environmental Protection Agency (EPA). <aqs.epa.gov/aqsweb/airdata.download_files.html>")),
                    
                  br(),
                  sidebarPanel(
                    h4("Map View"),
                    selectizeInput(inputId = "year",
                                   label = "Year",
                                   choices = c("1997":"2019"),
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
                    hr(),
                    h4("Upload dataset to get corresponding pollution estimates"),
                    p("The file returned will have a column for each pollutant; the value will be an average of monthly estimates over the specified time period."),
                    fluidRow(
                      column(6, selectizeInput('start_month', label = "Start month",
                                               choices = c("Jan", "Feb", "March", "April", "May",
                                                           "June", "July", "Aug", "Sept", "Oct",
                                                           "Nov", "Dec"),
                                               selected = "Jan",
                                               multiple = FALSE)),
                      column(6, selectizeInput(inputId = "start_year",
                                               label = "Start Year",
                                               choices = c("1997":"2019"),
                                               selected = "2015",
                                               multiple = FALSE))),
                    fluidRow(
                      column(6, selectizeInput('end_month', label = "End month",
                                               choices = c("Jan", "Feb", "March", "April", "May",
                                                           "June", "July", "Aug", "Sept", "Oct",
                                                           "Nov", "Dec"),
                                               selected = "March",
                                               multiple = FALSE)),
                      column(6, selectizeInput(inputId = "end_year",
                                               label = "End Year",
                                               choices = c("1997":"2019"),
                                               selected = "2015",
                                               multiple = FALSE))),
                    h5(p("Choose .csv file with Latitude and Longitude columns. A sample input file can be downloaded",downloadLink("downloadData", "here."))),
                    fileInput("user_file", " ",
                              multiple = FALSE,
                              accept = c("text/csv",
                                         "text/comma-separated-values,
                                         text/plain",
                                         ".csv")),
                    downloadButton("finalDownload", "Download"),hr(),
                    h6(p("Greenblatt RE, Himes BE. Facilitating Inclusion of Geocoded Pollution Data into Health Studies. AMIA Jt Summits Transl Sci Proc. 2019;2019:553–561.(PMID:",
                       a("31259010",href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6568125/",target="_blank"),").", a("GITHUB",href="https://github.com/HimesGroup/pargasite",target="_blank")," repository.")))
))
