library(shiny)
library(leaflet)
library(sf)
library(maps)
library(ggplot2)
library(usmap)
library(dplyr)
library(raster)
library(sp)
library(akima)
library(maptools)
library(mapview)
library(rgdal)
source("../labelFormatFunction.R")
devtools::load_all("~/Dropbox (Personal)/EPID_research/pargasite") #will need to change this to github version!

full_usa = st_as_sf(map("state", plot = FALSE, fill = TRUE))

epa.sites <- read.csv("~/epa_data_2005to2015/epa_site_locations.csv")

shinyServer(function(input, output, session){

  year.e <- reactive({ pargasite:::bricks.years[[input$year]] })
  year.c <- reactive({ pargasite:::bricks.years.cropped[[input$year]] })

  sites <- reactive({ filter(epa.sites, year == as.numeric(input$year) )})

  output$notes <- reactive({
    switch(input$pollutant,
           "PM2.5" = "Mean PM2.5 24-hour average (2012 standard); Units = Micrograms/cubic meter",
           "Ozone" = "Mean Ozone 8-hour average (2015 standard); Units = Parts per million",
           "NO2" = "Mean nitrogen dioxide (NO2) 1-hour average; Units = Parts per billion",
           "SO2" = "Mean sulfur dioxide (SO2) 1-hour average (2010 standard); Units = Parts per billion",
           "CO" = "Mean carbon monoxide (CO) 1-hour average (1971 standard); Units = Parts per million"
    )
  })

  ras.e <- reactive({
    switch(input$pollutant,
           "PM2.5" = year.e()[[1]],
           "Ozone" = year.e()[[2]],
           "NO2" = year.e()[[3]],
           "SO2" = year.e()[[4]],
           "CO" = year.e()[[5]]
    )
  })

  ras.c <- reactive({
    switch(input$pollutant,
           "PM2.5" = year.c()[[1]],
           "Ozone" = year.c()[[2]],
           "NO2" = year.c()[[3]],
           "SO2" = year.c()[[4]],
           "CO" = year.c()[[5]]
    )
  })

  trunc.val <- reactive({
    switch(input$pollutant,
           "PM2.5" = 14,
           "Ozone" = 0.055,
           "NO2" = 40,
           "SO2" = 40,
           "CO" = 0.5
    )
  })

  ras.t <- reactive({
    reclassify(ras.c(), c(trunc.val(), Inf, trunc.val()))
  })

  palette = reactive({
    colorNumeric(rev(terrain.colors(8)), values(ras.t()), na.color = "transparent")
  })

  output$map <- renderLeaflet({
    leaflet(full_usa) %>% addTiles() %>%
      setView(-98.35, 39.5, zoom = 4) %>%
      addRasterImage(x = ras.t(), colors = palette(), method = "ngb") %>%
      addPolygons(color = "black", weight = 1, fillColor = "transparent") %>%
      addLegend(pal = colorNumeric(terrain.colors(8), values(ras.t()), na.color = "transparent"),
                values = values(ras.t()),
                labFormat = myLabelFormat(t.val = trunc.val()),
                position = "bottomleft") %>%
      addCircleMarkers(lng = sites()$Longitude, lat = sites()$Latitude, radius = 0.001, group = "Plot EPA Site Locations") %>%
      addLayersControl(overlayGroups = c("Plot EPA Site Locations"), options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("Plot EPA Site Locations"))
  })

  output$latlong <- renderText({
    if(!is.null(input$map_click)){
      paste0("(", round(input$map_click$lat,2), ", ", round(input$map_click$lng, 2), ")")
    }
  })

  output$pollutant_val <- renderText({
    if(!is.null(input$map_click)){
      if(!is.na(raster::extract(ras.e(), cbind(input$map_click$lng, input$map_click$lat)))) {
        paste0(input$pollutant, " estimate = ", round(raster::extract(ras.e(), cbind(input$map_click$lng, input$map_click$lat)),2))
      }
      else paste0("")
    }
  })

  output$finalDownload <-
    downloadHandler(
      filename <- function() { "pargasite_file.csv" },
      content <- function(file){
        infile <- read.csv(input$user_file$datapath)
        outfile <- pargasite::getPollutionEstimates.df(infile)
        write.csv(outfile, file, row.names = FALSE)
      }
    )

})

