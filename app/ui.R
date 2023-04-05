#.libPaths("/home/rebecca/R/x86_64-pc-linux-gnu-library/3.4/")
#.libPaths("/home/maya/R/x86_64-pc-linux-gnu-library/3.4/")

library(leaflet)
library(shinyWidgets)

shinyUI(fluidPage(theme = "bootstrap.css",
                  setBackgroundColor("ghostwhite"),
                  tags$style(HTML("body {line-height: 1.75}")),
                  title= "Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE)",
                  titlePanel(h1(HTML(paste(h1(style = "color:black", "Pollution-Associated Risk Geospatial Analysis SITE (PARGASITE)"))), align = "left")),
                  tabsetPanel(
                    tabPanel(title = HTML(paste(h3(style = "color:black","USA"))), 
                             sidebarPanel(
                               h4("Map View"),
                               selectizeInput(inputId = "year",
                                              label = "Year",
                                              choices = c("1997":"2021"),
                                              selected = "2021",
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
                                                          choices = c("1997":"2021"),
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
                                                          choices = c("1997":"2021"),
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
                                    a("31259010",href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6568125/",target="_blank"),").", a("GITHUB",href="https://github.com/HimesGroup/pargasite",target="_blank")," repository."))),
                             leafletOutput("map", width = "60%",height= 600)
                    ), 
                    tabPanel(title = HTML(paste(h3(style = "color:black","MMSA"))), 
                             sidebarPanel(
                               h4("Map View"),
                               selectizeInput(inputId = "year_mmsa",
                                              label = "Year",
                                              choices = c("1997":"2021"),
                                              selected = "2021",
                                              multiple = FALSE),
                               selectizeInput(inputId = "pollutant_mmsa",
                                              label = "Pollutant",
                                              choices = c("PM2.5", "Ozone", "NO2", "SO2", "CO"),
                                              select = "PM2.5",
                                              multiple = FALSE),
                               p(textOutput("notes_mmsa")), 
                               h5(textOutput("latlong_mmsa")),
                               h5(textOutput("pollutant_val_mmsa")),
                               hr(),
                               h4("Use the download button to get pollution estimates corresponding to each MMSA and pollutant"),
                               p("The file returned will have three columns. The first and second column lists the GEOID and names of all the available MMSA and the third column returns the pollutant value corresponding to the MMSA. Change the input parameters (year and pollutant) to download the data for different years and pollutants."),
                               downloadButton("finalDownload_MMSA", "Download"),hr()
                             ),
                             leafletOutput("map_mmsa", width = "60%",height= 600)
                    ),
                    tabPanel(title = HTML(paste(h3(style = "color:black", "County"))), 
                             sidebarPanel(
                               h4("Map View"),
                               selectizeInput(inputId = "year_county",
                                              label = "Year",
                                              choices = c("1997":"2021"),
                                              selected = "2021",
                                              multiple = FALSE),
                               selectizeInput(inputId = "pollutant_county",
                                              label = "Pollutant",
                                              choices = c("PM2.5", "Ozone", "NO2", "SO2", "CO"),
                                              select = "PM2.5",
                                              multiple = FALSE),
                               p(textOutput("notes_county")),
                               h5(textOutput("latlong_county")),
                               h5(textOutput("pollutant_val_county")),
                               hr(),
                               h4("Use the download button to get pollution estimates corresponding to each county and pollutant"),
                               p("The file returned will have three columns. The first two columns lists the GOEID and names of all the available counties and the third column returns the pollutant value corresponding to the MMSA. Change the input parameters (year and pollutant) to download the data for different years and pollutants."),
                               downloadButton("finalDownload_county", "Download"),hr()
                             ),
                             leafletOutput("map_county", width = "60%",height= 600)
                    ),
                    tabPanel(title = HTML(paste(h3(style = "color:black", "About"))),
                             includeMarkdown("data/home.md")
                    ))
                  
)
)



