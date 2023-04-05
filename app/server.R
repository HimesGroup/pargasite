#.libPaths("/home/rebecca/R/x86_64-pc-linux-gnu-library/3.4/")
#.libPaths("/home/maya/R/x86_64-pc-linux-gnu-library/3.4/")

library(leaflet)
library(shiny)
library(shinyWidgets)
library(sf)
library(maps)
library(dplyr)
library(raster)
library(sp)
library(rgdal)
library(pargasite)
source("labelFormatFunction.R")
source("month_to_num.R")
source("getPollutionEstimates.R")
source("getPollutionEstimates_MMSA.R")
source("getPollutionEstimates_County.R")

#set colors
#replace terrain.colors(8)
map_colors <- c("#8c2d04","#cc4c02","#ec7014","#fe9929","#fec44f","#fee391","#fff7bc","#ffffe5")

## load in annual bricks for full data
pm_yearly_brick_full <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_pm_annual_10km_brick.tif")
ozone_yearly_brick_full <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_ozone_annual_10km_brick.tif")
no2_yearly_brick_full <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_no2_annual_10km_brick.tif")
so2_yearly_brick_full <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_so2_annual_10km_brick.tif")
co_yearly_brick_full <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_co_annual_10km_brick.tif")

pm_yearly_brick_cropped <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_pm_annual_10km_brickcropped.tif")
ozone_yearly_brick_cropped <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_ozone_annual_10km_brickcropped.tif")
no2_yearly_brick_cropped <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_no2_annual_10km_brickcropped.tif")
so2_yearly_brick_cropped <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_so2_annual_10km_brickcropped.tif")
co_yearly_brick_cropped <- brick("Pargasite_Rasters_upto_2021/Annual/Annual/latest_co_annual_10km_brickcropped.tif")

## load in annual bricks for Puerto Rico
pm_yearly_brick_full_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_pm_pr_annual_1km_brick.tif")
ozone_yearly_brick_full_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_ozone_pr_annual_1km_brick.tif")
no2_yearly_brick_full_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_no2_pr_annual_1km_brick.tif")
so2_yearly_brick_full_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_so2_pr_annual_1km_brick.tif")
co_yearly_brick_full_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_co_pr_annual_1km_brick.tif")

pm_yearly_brick_cropped_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_pm_pr_annual_1km_brickcropped.tif")
ozone_yearly_brick_cropped_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_ozone_pr_annual_1km_brickcropped.tif")
no2_yearly_brick_cropped_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_no2_pr_annual_1km_brickcropped.tif")
so2_yearly_brick_cropped_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_so2_pr_annual_1km_brickcropped.tif")
co_yearly_brick_cropped_pr <- brick("Pargasite_Rasters_upto_2021/Annual_PR/Annual/latest_co_pr_annual_1km_brickcropped.tif")


## load in annual bricks for MMSA data
pm_yearly_brick_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_PM_10km_brick.tif")
ozone_yearly_brick_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_Ozone_10km_brick.tif")
no2_yearly_brick_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_NO2_10km_brick.tif")
so2_yearly_brick_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_SO2_10km_brick.tif")
co_yearly_brick_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_CO_10km_brick.tif")

pm_yearly_brick_cropped_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_PM_10km_brickcropped.tif")
ozone_yearly_brick_cropped_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_Ozone_10km_brickcropped.tif")
no2_yearly_brick_cropped_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_NO2_10km_brickcropped.tif")
so2_yearly_brick_cropped_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_SO2_10km_brickcropped.tif")
co_yearly_brick_cropped_MMSA <- brick("Pargasite_Rasters_upto_2021/MMSA/MMSA_CO_10km_brickcropped.tif")

## load in annual bricks for County data
pm_yearly_brick_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_PM_10km_brick.tif")
ozone_yearly_brick_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_Ozone_10km_brick.tif")
no2_yearly_brick_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_NO2_10km_brick.tif")
so2_yearly_brick_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_SO2_10km_brick.tif")
co_yearly_brick_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_CO_10km_brick.tif")

pm_yearly_brick_cropped_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_PM_10km_brickcropped.tif")
ozone_yearly_brick_cropped_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_Ozone_10km_brickcropped.tif")
no2_yearly_brick_cropped_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_NO2_10km_brickcropped.tif")
so2_yearly_brick_cropped_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_SO2_10km_brickcropped.tif")
co_yearly_brick_cropped_county <- brick("Pargasite_Rasters_upto_2021/Counties/County_CO_10km_brickcropped.tif")

## load in annual bricks for Tract data
#pm_yearly_brick_tract<- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_PM_10km_brick.tif")
#ozone_yearly_brick_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_Ozone_10km_brick.tif")
#no2_yearly_brick_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_NO2_10km_brick.tif")
#so2_yearly_brick_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_SO2_10km_brick.tif")
#co_yearly_brick_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_CO_10km_brick.tif")

#pm_yearly_brick_cropped_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_PM_10km_brickcropped.tif")
#ozone_yearly_brick_cropped_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_Ozone_10km_brickcropped.tif")
#no2_yearly_brick_cropped_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_NO2_10km_brickcropped.tif")
#so2_yearly_brick_cropped_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_SO2_10km_brickcropped.tif")
#co_yearly_brick_cropped_tract <- brick("Pargasite_Rasters_upto_2021/Tracts/Tract_CO_10km_brickcropped.tif")

## load in annual bricks for ZIP data
#pm_yearly_brick_zip<- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_PM_10km_brick.tif")
#ozone_yearly_brick_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_Ozone_10km_brick.tif")
#no2_yearly_brick_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_NO2_10km_brick.tif")
#so2_yearly_brick_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_SO2_10km_brick.tif")
#co_yearly_brick_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_CO_10km_brick.tif")

#pm_yearly_brick_cropped_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_PM_10km_brickcropped.tif")
#ozone_yearly_brick_cropped_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_Ozone_10km_brickcropped.tif")
#no2_yearly_brick_cropped_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_NO2_10km_brickcropped.tif")
#so2_yearly_brick_cropped_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_SO2_10km_brickcropped.tif")
#co_yearly_brick_cropped_zip <- brick("Pargasite_Rasters_upto_2021/ZIP/ZIP/ZIP_CO_10km_brickcropped.tif")


## Load in shape files
MMSA_Shape <- sf::st_read("data/Shape_Files/Shape_Files/tl_2021_us_cbsa/tl_2021_us_cbsa.shp")
County_Shape <- sf::st_read("data/Shape_Files/Shape_Files/tl_2017_us_county/tl_2017_us_county.shp")
#Tract_Shape <- readOGR("data/Shape_Files/Shape_Files/tl_2021_us_tracts/tl_2021_us_tract.shp")
#ZIP_Shape <- sf::st_read("data/Shape_Files/Shape_Files/tl_2021_us_zcta520/tl_2021_us_zcta520.shp")

#EPA sites
epa.sites <- read.csv("data/epa_site_locations_upto_2021.csv") 

#Map
full_usa = st_as_sf(map("state", plot = FALSE, fill = TRUE))

shinyServer(function(input, output, session){
  
  #Standard output
  output$notes <- reactive({
    switch(input$pollutant,
           "PM2.5" = "Mean PM2.5 24-hour average (2012 standard); Units = Micrograms/cubic meter",
           "Ozone" = "Mean Ozone 8-hour average (2015 standard); Units = Parts per million",
           "NO2" = "Mean nitrogen dioxide (NO2) 1-hour average; Units = Parts per billion",
           "SO2" = "Mean sulfur dioxide (SO2) 1-hour average (2010 standard); Units = Parts per billion",
           "CO" = "Mean carbon monoxide (CO) 1-hour average (1971 standard); Units = Parts per million"
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
  
  #Units of measurement
  units <- reactive({
    switch(input$pollutant,
           "PM2.5" = "ug/m3",
           "Ozone" = "ppm",
           "NO2" = "ppb",
           "SO2" = "ppb",
           "CO" = "ppm"
    )
  })
  
  #EPA sites
  sites <- reactive({filter(epa.sites, year == as.numeric(input$year) )})
  
  #FULL USA
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
  
  
  #Reactive elements to get data
  ras.e <- reactive({
    poll.e()[[(as.numeric(input$year)-1996)]]
  })
  
  ras.c <- reactive({
    poll.c()[[(as.numeric(input$year)-1996)]]
  })
  
  ras.t <- reactive({
    reclassify(ras.c(), c(trunc.val(), Inf, trunc.val()))
  })
  
  
  #Puerto Rico only
  poll.epr <- reactive({
    switch(input$pollutant,
           "PM2.5" = pm_yearly_brick_full_pr,
           "Ozone" = ozone_yearly_brick_full_pr,
           "NO2" = no2_yearly_brick_full_pr,
           "SO2" = so2_yearly_brick_full_pr,
           "CO" = co_yearly_brick_full_pr)
  })
  
  poll.cpr <- reactive({
    switch(input$pollutant,
           "PM2.5" = pm_yearly_brick_cropped_pr,
           "Ozone" = ozone_yearly_brick_cropped_pr,
           "NO2" = no2_yearly_brick_cropped_pr,
           "SO2" = so2_yearly_brick_cropped_pr,
           "CO" = co_yearly_brick_cropped_pr)
  })
  
  
  #Reactive elements to get data
  ras.epr <- reactive({
    poll.epr()[[(as.numeric(input$year)-1996)]]
  })
  
  ras.cpr <- reactive({
    poll.cpr()[[(as.numeric(input$year)-1996)]]
  })
  
  ras.tpr <- reactive({
    reclassify(ras.cpr(), c(trunc.val(), Inf, trunc.val()))
  })
  
  #Color palette for rasters
  #USA
  palette = reactive({
    colorNumeric(rev(map_colors), c(values(ras.t()),values(ras.tpr())), na.color = "transparent")
  })
  
  #PR
  palette.pr = reactive({
    colorNumeric(rev(map_colors), values(ras.tpr()), na.color = "transparent")
  })
  
  #Warning message for Puerto Rico
  message <- paste(sep = "<br/>",
                   "No values available",
                   "for Puerto Rico")
  
  #Base map
  fmap <- reactive({
    leaflet(full_usa) %>% addTiles() %>%
      setView(-98.35, 39.5, zoom = 4) %>%
      addRasterImage(x = ras.t(), colors = palette(), method = "ngb", opacity = 0.7) %>%
      addPolygons(color = "black", weight = 1, fillColor = "transparent") %>%
      addCircleMarkers(lng = sites()$Longitude, lat = sites()$Latitude, radius = 0.001, group = "Plot EPA Site Locations") %>%
      addLayersControl(overlayGroups = c("Plot EPA Site Locations"), options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("Plot EPA Site Locations"))
  })
  
  #Add Puerto Rico raster if values available
  output$map <- renderLeaflet({
    if(!all(is.na(values(ras.tpr())))){
      fmap() %>%
        addRasterImage(x = ras.tpr(), colors = palette.pr(), method = "ngb", opacity = 0.7) %>%
        addLegend(pal = colorNumeric(map_colors, c(values(ras.t()),values(ras.tpr())), na.color = "transparent"),
                  values = c(values(ras.t()),values(ras.tpr())),
                  title = paste0(input$pollutant," (",units(),")"),
                  labFormat = myLabelFormat(t.val = trunc.val()),
                  position = "bottomleft") 
    } else {fmap() %>% 
        addLegend(pal = colorNumeric(map_colors, values(ras.t()), na.color = "transparent"),
                  values = values(ras.t()),
                  title = paste0(input$pollutant," (",units(),")"),
                  labFormat = myLabelFormat(t.val = trunc.val()),
                  position = "bottomleft") %>%
        addPopups(-66.48, 18.24, message,options = popupOptions(closeButton = TRUE)) 
    }
  })
  
  
  ##Display values on clicking
  output$latlong <- renderText({
    if(!is.null(input$map_click)){
      paste0("(", round(input$map_click$lat,2), ", ", round(input$map_click$lng, 2), ")")
    } else paste0("")
  })
  
  output$pollutant_val <- renderText({
    if(!is.null(input$map_click)){
      if(!is.na(raster::extract(ras.e(), cbind(input$map_click$lng, input$map_click$lat)))) {
        paste0(input$pollutant, " estimate = ", round(raster::extract(ras.e(), cbind(input$map_click$lng, input$map_click$lat)),2))
      }else if(!is.na(raster::extract(ras.epr(), cbind(input$map_click$lng, input$map_click$lat)))) {
        paste0(input$pollutant, " estimate = ", round(raster::extract(ras.epr(), cbind(input$map_click$lng, input$map_click$lat)),2))
      }
      else paste0("")
    }})
  
  
  #Monthly data
  monthyear_start <- reactive({ paste0(month_to_num(input$start_month), "-", input$start_year) })
  monthyear_end <- reactive({ paste0(month_to_num(input$end_month), "-", input$end_year) })
  
  #Download results
  output$finalDownload <-
    downloadHandler(
      filename <- function() { paste("pargasite-", Sys.Date(), ".csv", sep="") },
      content <- function(file){
        infile <- read.csv(input$user_file$datapath)
        outfile1 <- getPollutionEstimates.df.app(as.data.frame(infile), monthyear_start(), monthyear_end(),"USA")
        outfile2 <- getPollutionEstimates.df.app(as.data.frame(infile), monthyear_start(), monthyear_end(),"PR")
        outfile <- rbind(outfile1, outfile2)
        outfile <- outfile[rowSums(is.na(outfile)) <= 4,]
        outfile$Time_range <- toString(paste0(monthyear_start(), " to ", monthyear_end()))
        write.csv(outfile, file, row.names = FALSE)
      }
    )
  
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "pargasite_sample_input_file.csv"
    },
    content = function(file) {
      #cat("\n", file = "data/pargasite_sample_input_file.csv", append = TRUE)
      sample_input <- read.csv("data/pargasite_sample_input_file.csv")
      write.csv(sample_input, file,row.names = FALSE, quote = FALSE)
    }
  )
  
  #MMSA
  output$notes_mmsa <- reactive({
    switch(input$pollutant_mmsa,
           "PM2.5" = "Mean PM2.5 24-hour average (2012 standard); Units = Micrograms/cubic meter",
           "Ozone" = "Mean Ozone 8-hour average (2015 standard); Units = Parts per million",
           "NO2" = "Mean nitrogen dioxide (NO2) 1-hour average; Units = Parts per billion",
           "SO2" = "Mean sulfur dioxide (SO2) 1-hour average (2010 standard); Units = Parts per billion",
           "CO" = "Mean carbon monoxide (CO) 1-hour average (1971 standard); Units = Parts per million"
    )
  })
  
  trunc_val_mmsa <- reactive({
    switch(input$pollutant_mmsa,
           "PM2.5" = 14,
           "Ozone" = 0.055,
           "NO2" = 40,
           "SO2" = 40,
           "CO" = 0.5
    )
  })
  
  poll_e_mmsa <- reactive({
    switch(input$pollutant_mmsa,
           "PM2.5" = pm_yearly_brick_MMSA,
           "Ozone" = ozone_yearly_brick_MMSA,
           "NO2" = no2_yearly_brick_MMSA,
           "SO2" = so2_yearly_brick_MMSA,
           "CO" = co_yearly_brick_MMSA)
  })
  
  poll_c_mmsa <- reactive({
    switch(input$pollutant_mmsa,
           "PM2.5" = pm_yearly_brick_cropped_MMSA,
           "Ozone" = ozone_yearly_brick_cropped_MMSA,
           "NO2" = no2_yearly_brick_cropped_MMSA,
           "SO2" = so2_yearly_brick_cropped_MMSA,
           "CO" = co_yearly_brick_cropped_MMSA)
  })
  
  
  #Reactive elements to get data
  ras_e_mmsa <- reactive({
    poll_e_mmsa()[[(as.numeric(input$year_mmsa)-1996)]]
  })
  
  ras_c_mmsa <- reactive({
    poll_c_mmsa()[[(as.numeric(input$year_mmsa)-1996)]]
  })
  
  ras_t_mmsa <- reactive({
    reclassify(ras_c_mmsa(), c(trunc_val_mmsa(), Inf, trunc_val_mmsa()))
  })
  
  #Color palette for rasters
  #USA
  palette_mmsa = reactive({
    colorNumeric(rev(map_colors), values(ras_t_mmsa()), na.color = "transparent")
  })
  
  MMSA_shape <- sf::as_Spatial(MMSA_Shape)
  MMSA_shape <- spTransform(x = MMSA_shape, CRSobj = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  #Base MMSA map
  
  fmap_mmsa <- reactive({
    leaflet(MMSA_shape) %>% addTiles() %>%
      setView(-98.35, 39.5, zoom = 4) 
  })
  
  output$map_mmsa <- renderLeaflet ({
    fmap_mmsa() %>%
      addRasterImage(x = ras_t_mmsa(), colors = palette_mmsa(), method = "ngb", opacity = 0.7) %>%
      addPolygons(color = "black", weight = 1, fillColor = "transparent") %>%
      addCircleMarkers(lng = sites()$Longitude, lat = sites()$Latitude, radius = 0.001, group = "Plot EPA Site Locations") %>%
      addLayersControl(overlayGroups = c("Plot EPA Site Locations"), options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("Plot EPA Site Locations"))
  })
  ##Display values on clicking
  output$latlong_mmsa <- renderText({
    if(!is.null(input$map_mmsa_click)){
      paste0("(", round(input$map_click$lat,2), ", ", round(input$map_click$lng, 2), ")")
    } else paste0("")
  })
  
  output$pollutant_val_mmsa <- renderText({
    if(!is.null(input$map_mmsa_click)){
      if(!is.na(raster::extract(ras_e_mmsa(), cbind(input$map_mmsa_click$lng, input$map_mmsa_click$lat)))) {
        paste0(input$pollutant_mmsa, " estimate = ", round(raster::extract(ras_e_mmsa(), cbind(input$map_mmsa_click$lng, input$map_click$lat)),2))
      }
      else paste0("")
    }})
  poll_mmsa <- reactive({paste0(input$pollutant_mmsa)})
  year_mmsa <- reactive({as.numeric(input$year_mmsa)})
  #Download results
  output$finalDownload_MMSA <-
    downloadHandler(
      filename <- function() { paste("pargasite-MMSA", Sys.Date(), ".csv", sep="") },
      content <- function(file){
        outfile <- getPollutionEstimates_MMSA(poll_mmsa(), year_mmsa(), MMSA_Shape)
        write.csv(outfile, file, row.names = FALSE)
      }
    )
  
  #County
  output$notes_county <- reactive({
    switch(input$pollutant_county,
           "PM2.5" = "Mean PM2.5 24-hour average (2012 standard); Units = Micrograms/cubic meter",
           "Ozone" = "Mean Ozone 8-hour average (2015 standard); Units = Parts per million",
           "NO2" = "Mean nitrogen dioxide (NO2) 1-hour average; Units = Parts per billion",
           "SO2" = "Mean sulfur dioxide (SO2) 1-hour average (2010 standard); Units = Parts per billion",
           "CO" = "Mean carbon monoxide (CO) 1-hour average (1971 standard); Units = Parts per million"
    )
  })
  
  trunc_val_county <- reactive({
    switch(input$pollutant_county,
           "PM2.5" = 14,
           "Ozone" = 0.055,
           "NO2" = 40,
           "SO2" = 40,
           "CO" = 0.5
    )
  })
  
  poll_e_county <- reactive({
    switch(input$pollutant_county,
           "PM2.5" = pm_yearly_brick_county,
           "Ozone" = ozone_yearly_brick_county,
           "NO2" = no2_yearly_brick_county,
           "SO2" = so2_yearly_brick_county,
           "CO" = co_yearly_brick_county)
  })
  
  poll_c_county <- reactive({
    switch(input$pollutant_county,
           "PM2.5" = pm_yearly_brick_cropped_county,
           "Ozone" = ozone_yearly_brick_cropped_county,
           "NO2" = no2_yearly_brick_cropped_county,
           "SO2" = so2_yearly_brick_cropped_county,
           "CO" = co_yearly_brick_cropped_county)
  })
  
  
  #Reactive elements to get data
  ras_e_county <- reactive({
    poll_e_county()[[(as.numeric(input$year_county)-1996)]]
  })
  
  ras_c_county <- reactive({
    poll_c_county()[[(as.numeric(input$year_county)-1996)]]
  })
  
  ras_t_county <- reactive({
    reclassify(ras_c_county(), c(trunc_val_county(), Inf, trunc_val_county()))
  })
  palette_county = reactive({
    colorNumeric(rev(map_colors), values(ras_t_county()), na.color = "transparent")
  })
  #Base County map
  full_usa_county = st_as_sf(map("county", plot = FALSE, fill = TRUE))
  fmap_county <- reactive({
    leaflet(full_usa_county) %>% addTiles() %>%
      setView(-98.35, 39.5, zoom = 4) 
  })
  
  output$map_county <- renderLeaflet ({
    fmap_county() %>%
      addRasterImage(x = ras_t_county(), colors = palette_county(), method = "ngb", opacity = 0.7) %>%
      addPolygons(color = "black", weight = 1, fillColor = "transparent") %>%
      addCircleMarkers(lng = sites()$Longitude, lat = sites()$Latitude, radius = 0.001, group = "Plot EPA Site Locations") %>%
      addLayersControl(overlayGroups = c("Plot EPA Site Locations"), options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("Plot EPA Site Locations"))
  })
  
  ##Display values on clicking
  output$latlong_county <- renderText({
    if(!is.null(input$map_county_click)){
      paste0("(", round(input$map_county_click$lat,2), ", ", round(input$map_county_click$lng, 2), ")")
    } else paste0("")
  })
  
  output$pollutant_val_county <- renderText({
    if(!is.null(input$map_county_click)){
      if(!is.na(raster::extract(ras_e_county(), cbind(input$map_county_click$lng, input$map_county_click$lat)))) {
        paste0(input$pollutant_county, " estimate = ", round(raster::extract(ras_e_county(), cbind(input$map_county_click$lng, input$map_county_click$lat)),2))
      }
      else paste0("")
    }})
  poll_county <- reactive({paste0(input$pollutant_county)})
  year_county <- reactive({as.numeric(input$year_county)})
  #Download results
  output$finalDownload_county <-
    downloadHandler(
      filename <- function() { paste("pargasite-County", Sys.Date(), ".csv", sep="") },
      content <- function(file){
        outfile <- getPollutionEstimates_County(poll_county(), year_county(), County_Shape)
        write.csv(outfile, file, row.names = FALSE)
      }
    )
})



