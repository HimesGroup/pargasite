library(shiny)
library(sf)
library(maps)
library(dplyr)
library(raster)
library(sp)
#library(mapview)
source("labelFormatFunction.R")
source("month_to_num.R")
library(pargasite)

# ## load in all bricks
# pm_yearly_brick_full <- brick("http://public.himeslab.org/pargasite_data/pm_yearly_brick_full.tif")
# ozone_yearly_brick_full <- brick("http://public.himeslab.org/pargasite_data/ozone_yearly_brick_full.tif")
# no2_yearly_brick_full <- brick("http://public.himeslab.org/pargasite_data/no2_yearly_brick_full.tif")
# so2_yearly_brick_full <- brick("http://public.himeslab.org/pargasite_data/so2_yearly_brick_full.tif")
# co_yearly_brick_full <- brick("http://public.himeslab.org/pargasite_data/co_yearly_brick_full.tif")
# 
# pm_yearly_brick_cropped <- brick("http://public.himeslab.org/pargasite_data/pm_yearly_brick_cropped.tif")
# ozone_yearly_brick_cropped <- brick("http://public.himeslab.org/pargasite_data/ozne_yearly_brick_cropped.tif")
# no2_yearly_brick_cropped <- brick("http://public.himeslab.org/pargasite_data/no2_yearly_brick_cropped.tif")
# so2_yearly_brick_cropped <- brick("http://public.himeslab.org/pargasite_data/so2_yearly_brick_cropped.tif")
# co_yearly_brick_cropped <- brick("http://public.himeslab.org/pargasite_data/co_yearly_brick_cropped.tif")

full_usa = st_as_sf(map("state", plot = FALSE, fill = TRUE))

epa.sites <- read.csv("data/epa_site_locations.csv") 

shinyServer(function(input, output, session){

  poll.e <- reactive({
    switch(input$pollutant,
           "PM2.5" = pm_yearly_brick_full,
           "Ozone" = ozone_yearly_brick_full,
           "NO2" = no2_yearly_brick_full,
           "SO2" = so2_yearly_brick_full,
           "CO" = co_yearly_brick_full)
  })
  
  poll.c <- reactive({
    switch(input$pollutant,
           "PM2.5" = pm_yearly_brick_cropped,
           "Ozone" = ozone_yearly_brick_cropped,
           "NO2" = no2_yearly_brick_cropped,
           "SO2" = so2_yearly_brick_cropped,
           "CO" = co_yearly_brick_cropped)
  })

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
    poll.e[[(input$year-2004)]]
  })
  
  ras.c <- reactive({
    poll.c[[(input$year-2004)]]
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
  
  monthyear_start <- reactive({ paste0(month_to_num(input$start_month), "-", input$start_year) })
  monthyear_end <- reactive({ paste0(month_to_num(input$end_month), "-", input$end_year) })
  
  output$finalDownload <-
    downloadHandler(
      filename <- function() { "pargasite_file.csv" },
      content <- function(file){
        infile <- read.csv(input$user_file$datapath)
        outfile <- getPollutionEstimates.df.app(infile, monthyear_start(), monthyear_end())
        write.csv(outfile, file, row.names = FALSE)
      }
    )

})

