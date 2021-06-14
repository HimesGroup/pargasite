#.libPaths("/home/rebecca/R/x86_64-pc-linux-gnu-library/3.4/")
#.libPaths("/home/maya/R/x86_64-pc-linux-gnu-library/3.4/")

library(leaflet)
library(shiny)
library(sf)
library(maps)
library(dplyr)
library(raster)
library(sp)
source("labelFormatFunction.R")
source("month_to_num.R")
source("getPollutionEstimates.R")

#set colors
#replace terrain.colors(8)
map_colors <- c("#8c2d04","#cc4c02","#ec7014","#fe9929","#fec44f","#fee391","#fff7bc","#ffffe5")

## load in annual bricks for full data
pm_yearly_brick_full <- brick("pargasite_rasters/Annual/10km_rasters/pm_yearly_brick_full_10km.tif")
ozone_yearly_brick_full <- brick("pargasite_rasters/Annual/10km_rasters/ozone_yearly_brick_full_10km.tif")
no2_yearly_brick_full <- brick("pargasite_rasters/Annual/10km_rasters/no2_yearly_brick_full_10km.tif")
so2_yearly_brick_full <- brick("pargasite_rasters/Annual/10km_rasters/so2_yearly_brick_full_10km.tif")
co_yearly_brick_full <- brick("pargasite_rasters/Annual/10km_rasters/co_yearly_brick_full_10km.tif")

pm_yearly_brick_cropped <- brick("pargasite_rasters/Annual/10km_rasters/pm_yearly_brick_full_10km_cropped.tif")
ozone_yearly_brick_cropped <- brick("pargasite_rasters/Annual/10km_rasters/ozone_yearly_brick_full_10km_cropped.tif")
no2_yearly_brick_cropped <- brick("pargasite_rasters/Annual/10km_rasters/no2_yearly_brick_full_10km_cropped.tif")
so2_yearly_brick_cropped <- brick("pargasite_rasters/Annual/10km_rasters/so2_yearly_brick_full_10km_cropped.tif")
co_yearly_brick_cropped <- brick("pargasite_rasters/Annual/10km_rasters/co_yearly_brick_full_10km_cropped.tif")

## load in annual bricks for Puerto Rico
pm_yearly_brick_full_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_pm_annual_1km_brick.tif")
ozone_yearly_brick_full_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_ozone_annual_1km_brick.tif")
no2_yearly_brick_full_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_no2_annual_1km_brick.tif")
so2_yearly_brick_full_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_so2_annual_1km_brick.tif")
co_yearly_brick_full_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_co_annual_1km_brick.tif")

pm_yearly_brick_cropped_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_pm_annual_1km_brick_cropped.tif")
ozone_yearly_brick_cropped_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_ozone_annual_1km_brick_cropped.tif")
no2_yearly_brick_cropped_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_no2_annual_1km_brick_cropped.tif")
so2_yearly_brick_cropped_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_so2_annual_1km_brick_cropped.tif")
co_yearly_brick_cropped_pr <- brick("pargasite_rasters/Annual/1km_rasters/pr_co_annual_1km_brick_cropped.tif")


#EPA sites
epa.sites <- read.csv("data/epa_site_locations.csv") 

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
              title = paste0(input$pollutant),
              labFormat = myLabelFormat(t.val = trunc.val()),
              position = "bottomleft") 
    } else {fmap() %>% 
        addLegend(pal = colorNumeric(map_colors, values(ras.t()), na.color = "transparent"),
                  values = values(ras.t()),
                  title = paste0(input$pollutant),
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
  
})

