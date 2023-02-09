getMMSALevelPollutantValue <- function(year, pollutant = "PM2.5") {
  
  install.packages("rgdal")
  library(rgdal)
  library(dplyr)
  
  Raster_PR_Full <- switch(pollutant,
                                "PM2.5" = download(pr_pm_annual_brick),
                                "Ozone" = download(pr_ozone_annual_brick),
                                "NO2" = download(pr_no2_annual_brick),
                                "SO2" = download(pr_so2_annual_brick),
                                "CO" = download(pr_co_annual_brick))
  Raster_US_Full <- switch(pollutant,
                                "PM2.5" = download(pm_yearly_brick_full),
                                "Ozone" = download(ozone_yearly_brick_full),
                                "NO2" = download(no2_yearly_brick_full),
                                "SO2" = download(so2_yearly_brick_full),
                                "CO" = download(co_yearly_brick_full))
  Raster_PR_Year <- raster::extract(Raster_PR_Full[[(as.numeric(year)-1996)]])
  Raster_US_Year <- raster::extract(Raster_US_Full[[(as.numeric(year)-1996)]])
  
  spts_PR <- rasterToPoints(Raster_PR_Year, spatial = TRUE)
  llprj <-  "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"
  llpts_PR <- spTransform(spts_PR, CRS(llprj))
  x_1 <- as.data.frame(llpts_PR)
  colnames(x_1) <- c("Pollutant_Value", "Longitude", "Latitude")
  spts_US <- rasterToPoints(Raster_US_Year, spatial = TRUE)
  llpts_US <- spTransform(spts_US, CRS(llprj))
  x_2 <- as.data.frame(llpts_US)
  colnames(x_2) <- c("Pollutant_Value", "Longitude", "Latitude")
  lat_long_poll <- rbind(x1,x2)
  lat_long <- data.frame(lat_long_poll$Longitude, lat_long_poll$Latitude)
  county_names <- latlong2county(lat_long)
  
  county_names <- strsplit(county_names, '[,]')
  county_names_unlist <- c()
  for (i in 1:length(county_names)) {
    if(!is.na(county_names[i])) {
      county_names[[i]] <- county_names[[i]][c(2,1)] 
      county_names_unlist[i] <- sapply(county_names[i], paste, collapse=",")} else {
        county_names_unlist[i] <- NA
      }}
  
  lat_long_poll$County <- county_names_unlist
  Pollutant_df <- lat_long_poll %>% group_by(County) %>% summarise(mean(PM_Value))
  colnames(Pollutant_df)[2] <- "Pollutant_Value"
  
  mmsa <- read.table(url("https://raw.githubusercontent.com/HimesGroup/pargasite/master/app/data/MMSA_2021_Edited.csv"), sep = ",", header = T)
  
  match(mmsa$county, Pollutant_df$County)
  MMSA <- c()
  z <- data.frame(
    X1 = mmsa_data$CBSA_Title[match(Pollutant_df$County, mmsa$county)]
  )
  
  Pollutant_df$MMSA <- z
  Pollutant_df <- Pollutant_df %>% group_by(MMSA) %>% summarise(mean(Pollutant_Value))
  colnames(Pollutant_df) <- c("MMSA", "Pollutant_Value")
  
  return(Pollutant_df)
}